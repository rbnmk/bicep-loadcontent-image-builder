//Define Azure Files parmeters
param location string = 'westeurope'
param managedidentityName string
param resourceTags object = {}

resource mid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedidentityName
  location: location
  tags: resourceTags
}

output midName string = mid.name
output midId string = mid.id
output midPrincipalId string = mid.properties.principalId

