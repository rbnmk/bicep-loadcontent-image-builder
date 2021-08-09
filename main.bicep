targetScope = 'subscription'

param resourceGroupName string = 'blog-azure-image-builder'
param resourceGroupLocation string = 'WestEurope'
param templateName string = 'server2019jumphost'

var managedIdentityName = '${templateName}-id'

// Create the Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

// Create the Managed Identity that will be used by the Azure Image Builder template
module managedIdentity 'modules/managedIdentity.bicep' = {
  name: '${managedIdentityName}-deployment'
  scope: resourceGroup
  params: {
    managedidentityName: managedIdentityName
  }
}

// Assign the Contributor role to the earlier created Managed Identity
module roleAssignment 'modules/rg-roleassignment.bicep' = {
  name: '${managedIdentityName}-role-assignment'
  scope: resourceGroup
  params: {
    principalId: managedIdentity.outputs.midPrincipalId
  }
}

// Deploy the Image Template to Azure
module imageTemplate 'modules/vm-image-template-pwsh.bicep' = {
  name: '${templateName}-deployment'
  scope: resourceGroup
  params: {
    imageTemplateName: templateName
    userAssignedIdentityName: managedIdentity.outputs.midName
  }
}
