#  dependencies
$packagesRoot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
[System.Reflection.Assembly]::LoadFrom("$packagesRoot\Kusto.Data.dll")

#  destination
$IngestUrl = "https://kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$DatabaseName = "MyDatabase"
$TableName = "Counter"
$FilePath

#  function
$KustoConnectionStringBuilder = [Kusto.Data.KustoConnectionStringBuilder]::new($IngestUrl,$DatabaseName)
$KustoClient = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($KustoConnectionStringBuilder)
$IngestionProperties = [Kusto.Ingest.KustoQueuedIngestionProperties]::new(
    $DatabaseName, 
    $TableName
)
$IngestionProperties.Format = [Kusto.Data.Common.DataSourceFormat]::csv 
$IngestionProperties.IgnoreFirstRecord = $true
$IngestionResult = $KustoClient.IngestFromStorageAsync(
    $FilePath,
    $IngestionProperties
)
$IngestionResult.Result.GetIngestionStatusCollection()


