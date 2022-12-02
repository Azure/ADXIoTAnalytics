#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")

#  destination
$uri = "https://ingest-kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$db = "MyDatabase"
$t = "Counter"

#  get data
$fp = 'C:\hiram_msft\ADXIoTAnalytics\assets\OfficialDemos\Others\PowerShell\Counter.csv'
Remove-Item $fp -Force
$timeout = new-timespan -Seconds 30
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout){
  (Get-Counter).CounterSamples `
  | Select-Object Timestamp, Path, InstanceName, CookedValue `
  | ConvertTo-Csv  -NoTypeInformation `
  | Select-Object -Skip 1 `
  | Out-File $fp -Force -Append 
  start-sleep -Seconds 1
}

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($s)
$p = [Kusto.Ingest.KustoQueuedIngestionProperties]::new($db, $t)
$p.Format = [Kusto.Data.Common.DataSourceFormat]::csv
$p.IgnoreFirstRecord = $false
$r = $c.IngestFromStorageAsync($fp,$p)
$r
$r.Result.GetIngestionStatusCollection()
