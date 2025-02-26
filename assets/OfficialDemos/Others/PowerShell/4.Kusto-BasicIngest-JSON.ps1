#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Cloud.Platform.dll")
class T {
    [string] $json
    T(
        [string] $json
    ){
        $this.json=$json
    }
}

#  destination
$uri = "https://ingest-kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$db = "MyDatabase"
$t = "Counter_raw"

# kql https://aka.ms/adx.free
# .create table Counter_raw (json:dynamic)

#  get data
[T[]]$x = (Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | ConvertTo-Json 

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($s)
$p = [Kusto.Ingest.KustoQueuedIngestionProperties]::new($db, $t)
$dr = New-Object Kusto.Cloud.Platform.Data.EnumerableDataReader[T] ($x, 'json')
$r = $c.IngestFromDataReaderAsync($dr,$p)
$r
$r.Result.GetIngestionStatusCollection()
