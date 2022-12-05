#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")

$uri = "https://adxpm10774.eastus.kusto.windows.net;Fed=True"
$db = "sentinel"
$t = "Counter_raw2"

#  client
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateStreamingIngestClient($s)
$p = [Kusto.Ingest.KustoIngestionProperties]::new($db, $t)
$p.Format = [Kusto.Data.Common.DataSourceFormat]::multijson
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
$r.Result.GetIngestionStatusCollection()
