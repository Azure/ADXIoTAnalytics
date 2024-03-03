#  dependencies
$null = [System.Reflection.Assembly]::LoadFrom('C:\kustotools\tools\net472\Kusto.Data.dll')
$null = [System.Reflection.Assembly]::LoadFrom('C:\kustotools\tools\net472\Kusto.Ingest.dll')

$uri = "https://kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True" #cluster URI, because we can stream directly to the engine nodes.
$db = "MyDatabase"
$t = "Counter_raw"

# https://aka.ms/adx.free 
# https://learn.microsoft.com/azure/data-explorer/ingest-data-streaming?tabs=azure-portal#enable-streaming-ingestion-while-creating-a-new-cluster
# Run KQL:
# .create table Counter_raw (Data:dynamic)
# .show table Counter_raw policy streamingingestion
# .show database policy streamingingestion //if IsEnabled = true, table will inherit database policy.
# .alter table Counter_raw policy streamingingestion enable //not required if already enabled for the db. 

#  client
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateStreamingIngestClient($s)
$p = [Kusto.Ingest.KustoIngestionProperties]::new($db, $t)
$p.Format = [Kusto.Data.Common.DataSourceFormat]::multijson

while (1 -eq 1) {
{
  Write-Output "This is an infinite loop. Press Ctrl+C to stop."
  
  # $p.IgnoreFirstRecord = $true
  $ms = [System.IO.MemoryStream]::new()
  $sw = [System.IO.StreamWriter]::new($ms)
  $text = (Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | % { @{Data = $_} } | ConvertTo-Json
  # echo $text
  $ms.Position = 0
  $sw.Write($text)
  $sw.Flush()
  $ms.Position = 0
  # echo $ms
  $r = $c.IngestFromStreamAsync($ms,$p)
  $r
  #$r.Result.GetIngestionStatusCollection()

  Start-Sleep -Seconds 1
}
