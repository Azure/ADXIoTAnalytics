#  dependencies
$pkgroot = "C:\Microsoft.Azure.Kusto.Tools\tools\net5.0"
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Data.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Ingest.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$pkgroot\Kusto.Cloud.Platform.dll")
class T {
    [datetime] $Timestamp
    [string] $Path
    [string] $InstanceName
    [double] $CookedValue
    T(
        [datetime] $timestamp,
        [string] $path,
        [string] $instanceName,
        [double] $cookedValue
    ){
        $this.Timestamp=$timestamp
        $this.Path=$path
        $this.InstanceName=$instanceName
        $this.CookedValue=$cookedValue
    }
}

#  collect data
[T[]]$x = (Get-Counter).CounterSamples | ForEach-Object -Process { [T]::new(
    $_.Timestamp,
    $_.Path ,
    $_.InstanceName ,
    $_.CookedValue
)}
# $x.GetType().GetElementType()
# $x[0].GetType()

#  destination
$uri = "https://ingest-kvc43f0ee6600e24ef2b0e.southcentralus.kusto.windows.net;Fed=True"
$db = "MyDatabase"
$t = "Counter"

#  ingest
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient($s)
$p = [Kusto.Ingest.KustoQueuedIngestionProperties]::new($db, $t)
$dr = New-Object Kusto.Cloud.Platform.Data.EnumerableDataReader[T] ($x, 'Timestamp', 'Path', 'InstanceName', 'CookedValue')
$r = $c.IngestFromDataReaderAsync($dr,$p)
$r.Result.GetIngestionStatusCollection()
