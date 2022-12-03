#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")

$uri = "https://adxpm10774.eastus.kusto.windows.net;Fed=True"
$db = "sentinel"
$t = "Counter_raw"

#  client
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateStreamingIngestClient($s)
$p = [Kusto.Ingest.KustoIngestionProperties]::new($db, $t)
$ms = [System.IO.MemoryStream]::new()
$sw = [System.IO.StreamWriter]::new($ms)
$sw.Write({(Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | ConvertTo-Json})
$r = $c.IngestFromStreamAsync($ms,$p)
$r
$r.Result.GetIngestionStatusCollection()

# Bug: Ingestion Status Skipped
