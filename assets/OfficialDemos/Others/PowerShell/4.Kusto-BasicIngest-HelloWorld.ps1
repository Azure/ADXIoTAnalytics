#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Cloud.Platform.dll")
class T {
    [string] $column1
    T(
        [string] $column1
    ){
        $this.column1=$column1
    }
}

#  destination
$uri = "https://ingest-kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$db = "MyDatabase"
$t = "MyTable"

# kql https://aka.ms/adx.free
# .create table MyTable (column1:string)

#  get data
[T[]]$x = 'hello world!'

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($s)
$p = [Kusto.Ingest.KustoQueuedIngestionProperties]::new($db, $t)
$dr = New-Object Kusto.Cloud.Platform.Data.EnumerableDataReader[T] ($x, 'column1')
$r = $c.IngestFromDataReaderAsync($dr,$p)
$r
$r.Result.GetIngestionStatusCollection()
