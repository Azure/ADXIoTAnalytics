param digitalTwinName string
param location string = resourceGroup().location
param principalId string

resource digitaltwin 'Microsoft.DigitalTwins/digitalTwinsInstances@2020-12-01' = {
  name: digitalTwinName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

//Get Azure Digital Twins Data Owner role definition
@description('This is the built-in Azure Digital Twins Data Owner role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource digitalTwintDataOwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
 scope: subscription()
 name: 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'
}

// Grant Azure Digital Twins Data Owner role to user running script
resource dtroleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, principalId, digitalTwintDataOwnerRoleDefinition.id)
  properties: {
    roleDefinitionId: digitalTwintDataOwnerRoleDefinition.id
    principalId: principalId
  }
}

output digitalTwinName string = digitaltwin.name
output digitalTwinHostName string = digitaltwin.properties.hostName
