#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
[System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")

#  collect data
$x = (Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | ConvertTo-Json 
Write-Host $x

#  set destination
$uri = "https://kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$db = "MyDatabase"
$t = "Counter"

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($s)
$p = [Kusto.Ingest.KustoQueuedIngestionProperties]::new($db, $t)
$p.Format = [Kusto.Data.Common.DataSourceFormat]::json 
# $p.IgnoreFirstRecord = $true
$r = $c.IngestFromStorageAsync($x,$p)
$r.Status
$r = $c.IngestFromDataReaderAsync($x,$p)
$r.Status

# MethodException: Cannot find an overload for "IngestFromDataReaderAsync" and the argument count: "2".
