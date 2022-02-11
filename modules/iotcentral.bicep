
param iotCentralName string = 'iotcentralpatmon'
param location string = resourceGroup().location
param principalId string 

resource myIotCentralApp 'Microsoft.IoTCentral/iotApps@2021-06-01' = {
  name: iotCentralName
  location: location
  sku: {
    name: 'ST1'
   }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Store Analytics'
    subdomain: '${iotCentralName}domain'
    template: 'iotc-store'
  }
}

@description('This is the built-in Azure Digital Twins Data Owner role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource digitalTwintDataOwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'
}

// Grant Azure Digital Twins Data Owner role to user running script
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, principalId, digitalTwintDataOwnerRoleDefinition.id)
  properties: {
    roleDefinitionId: digitalTwintDataOwnerRoleDefinition.id
    principalId: principalId
  }
}
