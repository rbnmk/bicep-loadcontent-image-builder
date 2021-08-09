param imageTemplateName string
param userAssignedIdentityName string
param location string = resourceGroup().location
param resourceTags object = {}
@allowed([
  'VHD'
])
param distributeTo string = 'VHD'

var inlineScript = [
  {
    type: 'PowerShell'
    name: 'PowerShellScript'
    runAsSystem: true
    runElevated: true
    inline: [
      loadTextContent('../scripts/jumphost-config.ps1')
    ]
    validExitCodes: [
      0
      3010 // Reboot required
    ]
  }
]

// Default windows customizers for Azure VMs
var default_windows_customizers = [
  {
    type: 'WindowsRestart'
    restartTimeout: '15m'
  }
  {
    type: 'WindowsUpdate'
    searchCriteria: 'IsInstalled=0'
    filters: [
      'exclude: $_.Title -like "*Preview*"'
      'include: $true'
    ]
  }
  {
    type: 'PowerShell'
    runElevated: true
    name: 'DeprovisioningScript'
    inline: [
      '((Get-Content -path C:\\DeprovisioningScript.ps1 -Raw) -replace "Sysprep.exe /oobe /generalize /quiet /quit", "Sysprep.exe /oobe /generalize /quit /mode:vm" ) | Set-Content -Path C:\\DeprovisioningScript.ps1'
    ]
  }
]

// Select the distribution method
// For this example we are only using VHD
var distribute = {
  VHD: [
    {
      type: 'VHD'
      runOutputName: imageTemplateName
    }
  ]
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userAssignedIdentityName
}

resource imageTemplateName_resource 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: imageTemplateName
  location: location
  tags: resourceTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 120
    vmProfile: {
      vmSize: 'Standard_D8_v4'
      osDiskSizeGB: 127
    }
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-datacenter'
      version: 'latest'
    }
    customize: union(inlineScript, default_windows_customizers)
    distribute: distribute[distributeTo]
  }
  dependsOn: []
}
