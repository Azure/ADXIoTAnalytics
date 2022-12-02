#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")

$ms = [System.IO.MemoryStream]::new()
$sr = [System.IO.StreamReader]::new($ms)
$sw = [System.IO.StreamWriter]::new($sr)
$x = $sw.Read({(Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | ConvertTo-Json})

$uri = "https://adxpm10774.eastus.kusto.windows.net;Fed=True"
$db = "sentinel"
$t = "Counter_raw"

#  kql
#  .create table Counter_raw (x:dynamic)

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateStreamingIngestClient($s)
$p = [Kusto.Ingest.KustoIngestionProperties]::new($db, $t)
$r = $c.IngestFromStreamAsync($x,$p)
$r

# Bug: $r returns Status Faulted
