#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")

#  destination
$uri = "https://ingest-kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$db = "MyDatabase"
$t = "Counter_raw"

#  get data
$timeout = new-timespan -Seconds 30
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout){
  (Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | ConvertTo-Json | Out-File Counter.json -Force -Append
  start-sleep -Seconds 1
}
$fp = 'C:\hiram_msft\ADXIoTAnalytics\assets\OfficialDemos\Others\PowerShell\Counter.json'

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($s)
$p = [Kusto.Ingest.KustoQueuedIngestionProperties]::new($db, $t)
$p.Format = [Kusto.Data.Common.DataSourceFormat]::json
$p.IgnoreFirstRecord = $false
$r = $c.IngestFromStorageAsync($fp,$p)
$r
$r.Result.GetIngestionStatusCollection()
