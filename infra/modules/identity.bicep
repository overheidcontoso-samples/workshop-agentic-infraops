@description('Location for resources')
param location string

@description('Managed Identity name')
param identityName string

// User-Assigned Managed Identity for the SRE Agent
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

// Outputs
output identityId string = userAssignedIdentity.id
output identityName string = userAssignedIdentity.name
output identityPrincipalId string = userAssignedIdentity.properties.principalId
