Write-Host "Working On Chocolatey!"
Invoke-Expression ((New-Object -TypeName net.webclient).DownloadString("https://chocolatey.org/install.ps1"))
choco feature enable -n allowGlobalConfirmation
Write-Host "Chocolatey Installed"

Write-Host "Installing tools using Chocolatey!"
choco install googlechrome powershell-core notepadplusplus.install az.powershell azure-cli bicep microsoftazurestorageexplorer vscode sql-server-management-studio --yes --no-progress
Write-Host "Installing tools using Chocolatey Complete!"

Write-Host "Installing RSAT"
Install-WindowsFeature -IncludeAllSubFeature RSAT
Write-Host "Installing RSAT Complete"
