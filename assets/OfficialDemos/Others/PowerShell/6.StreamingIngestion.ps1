#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")

$uri = "https://adxpm10774.eastus.kusto.windows.net;Fed=True"
$db = "sentinel"
$t = "Counter_raw"

# https://aka.ms/adx.free (upgrade to Azure cluster)
# https://learn.microsoft.com/azure/data-explorer/ingest-data-streaming?tabs=azure-portal#enable-streaming-ingestion-while-creating-a-new-cluster
# Run KQL:
# .create table Counter_raw (Data:dynamic)
# .alter table Counter_raw policy streamingingestion enable

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
