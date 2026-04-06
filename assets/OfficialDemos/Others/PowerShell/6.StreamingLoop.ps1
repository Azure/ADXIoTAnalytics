#  dependencies
try { $null = [System.Reflection.Assembly]::LoadFrom('C:\kustotools\tools\net472\Kusto.Data.dll') } catch {}
try { $null = [System.Reflection.Assembly]::LoadFrom('C:\kustotools\tools\net472\Kusto.Ingest.dll') } catch {}
try { $null = [System.Reflection.Assembly]::LoadFrom('C:\kustotools\tools\net472\Azure.Core.dll') } catch {}

$verbose = 0  # set to 1 to echo status per ingestion

$uri = "https://trd-cff114afmpqwdjz7ux.z0.kusto.fabric.microsoft.com;Fed=True" #cluster URI, because we can stream directly to the engine nodes.
# $uri = "https://trd-3yh68y911w8pmue9mg.z6.kusto.fabric.microsoft.com;Fed=True" #bcdr2
$db = "EH1"
$t = "Counter_raw"

# https://aka.ms/adx.free 
# https://learn.microsoft.com/azure/data-explorer/ingest-data-streaming?tabs=azure-portal#enable-streaming-ingestion-while-creating-a-new-cluster
# Run KQL:
# .create table Counter_raw (Data:dynamic)
# .show table Counter_raw policy streamingingestion
# .show database policy streamingingestion //if IsEnabled = true, table will inherit database policy.
# .alter table Counter_raw policy streamingingestion enable //not required if already enabled for the db. 

# device identity (stable across sessions)
$deviceId = @{
  ComputerName = $env:COMPUTERNAME
  MachineGuid  = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography').MachineGuid
}

#  client
$s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
$c = [Kusto.Ingest.KustoIngestFactory]::CreateStreamingIngestClient($s)
$p = [Kusto.Ingest.KustoIngestionProperties]::new($db, $t)
$p.Format = [Kusto.Data.Common.DataSourceFormat]::multijson

# Counter samples loop (runs in background thread - shares loaded assemblies)
$counterJob = Start-ThreadJob -ScriptBlock {
  param($uri, $db, $t, $verbose, $deviceId)
  $s = [Kusto.Data.KustoConnectionStringBuilder]::new($uri, $db)
  $c = [Kusto.Ingest.KustoIngestFactory]::CreateStreamingIngestClient($s)
  $p = [Kusto.Ingest.KustoIngestionProperties]::new($db, $t)
  $p.Format = [Kusto.Data.Common.DataSourceFormat]::multijson

  while ($true) {
    $ms = [System.IO.MemoryStream]::new()
    $sw = [System.IO.StreamWriter]::new($ms)
    $text = (Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | % { @{Data = $_; Device = $deviceId} } | ConvertTo-Json
    $sw.Write($text)
    $sw.Flush()
    $ms.Position = 0
    try {
      $r = $c.IngestFromStreamAsync($ms, $p).GetAwaiter().GetResult()
      if ($verbose) {
        $ing = $r.GetIngestionStatusCollection() | Select-Object -First 1
        Write-Output "[Counter $(Get-Date -Format 'HH:mm:ss.fff')] Status: $($ing.Status) | IngestionTime: $($ing.Timestamp)"
      }
    } catch {
      throw "[Counter] Fatal error: $($_.Exception.Message)"
    } finally {
      $sw.Dispose()
      $ms.Dispose()
    }
  }
} -ArgumentList $uri, $db, $t, $verbose, $deviceId

Write-Host "Running... (verbose=$verbose) Press Ctrl+C to stop."

# CIM data loop (runs in foreground)
try {
  while ($true) {
    # Check counter job for errors
    if ($counterJob.State -eq 'Failed') {
      Receive-Job -Job $counterJob -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ }
      throw "Counter job failed. Aborting."
    }
    if ($verbose) {
      Receive-Job -Job $counterJob -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ }
    }

    $ms = [System.IO.MemoryStream]::new()
    $sw = [System.IO.StreamWriter]::new($ms)
    $cimData = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor | Select-Object * | % { @{Data = $_; Device = $deviceId} }
    $text = $cimData | ConvertTo-Json -Depth 30
    $sw.Write($text)
    $sw.Flush()
    $ms.Position = 0
    try {
      $r = $c.IngestFromStreamAsync($ms, $p).GetAwaiter().GetResult()
      if ($verbose) {
        $ing = $r.GetIngestionStatusCollection() | Select-Object -First 1
        Write-Host "[CIM     $(Get-Date -Format 'HH:mm:ss.fff')] Status: $($ing.Status) | IngestionTime: $($ing.Timestamp)"
      }
    } catch {
      throw "[CIM] Fatal error: $_"
    } finally {
      $sw.Dispose()
      $ms.Dispose()
    }

    Start-Sleep -Milliseconds 10
  }
} finally {
  Write-Host "Stopping counter job..."
  Stop-Job -Job $counterJob -ErrorAction SilentlyContinue
  Remove-Job -Job $counterJob -Force -ErrorAction SilentlyContinue
  Write-Host "Stopped."
}
