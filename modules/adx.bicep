param adxName string
param location string = resourceGroup().location
param adxSKU string

resource adxCluster 'Microsoft.Kusto/clusters@2021-08-27' = {
  name: adxName
  location: location
  sku: {
    name: adxSKU
    tier: 'Standard'
    capacity: 2
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource adxDb 'Microsoft.Kusto/clusters/databases@2021-08-27' = {
  kind: 'ReadWrite'
  name: 'IoTAnalytics'
  location: location
  parent:adxCluster
  properties: {
    softDeletePeriod: 'P60D'
    hotCachePeriod: 'P365D'
  }
}

output adxClusterId string = adxCluster.id
output adxClusterIdentity string = adxCluster.identity.principalId
output adxName string = adxCluster.name

