param saname string
param location string = resourceGroup().location
param eventHubId string 

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  kind: 'StorageV2'
  location: location
  name: saname
  sku: {
    name: 'Standard_LRS'
  }
  properties: {}

}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${saname}/default/adxscript'
  dependsOn: [
    storageaccount
  ]
}

resource eventgrid 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: 'BlobCreate'
  location: location
  properties: {
    source: storageaccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }

  resource eventSub 'eventSubscriptions' = {
    name: 'HistoricData'
    properties: {
      destination: {
        endpointType: 'EventHub'
        properties: {
          resourceId: eventHubId
        }
      }
      filter: {
        includedEventTypes: [
          'Microsoft.Storage.BlobCreated'
        ]
        enableAdvancedFilteringOnArrays: true
      }
      eventDeliverySchema: 'EventGridSchema'
      retryPolicy: {
        maxDeliveryAttempts: 30
        eventTimeToLiveInMinutes: 1440
      }
    }
  }
}



output saName string = storageaccount.name
output saId string = storageaccount.id
