function Import-CsvToADX {
    <#
    .SYNOPSIS
        A PowerShell cmdlet to ingest CSV to Azure Data Explorer.
    .DESCRIPTION
        A PowerShell cmdlet to ingest CSV to Azure Data Explorer
    .EXAMPLE
        PS C:\> Import-CsvToADX -IngestUrl '' -ApplicationClientID '' -ApplicationClientKey '' -Authority '' -DatabaseName '' -TableName '' -FilePath ''
        Explanation of what the example does
    .NOTES
        Author: Chendrayan Venkatesan
        https://www.powershellgallery.com/packages/PowerShell.Azure.Data.Explorer/0.0.4/Content/functions%5CImport-CsvToADX.ps1
    #>
    [CmdletBinding()]
    param (
        [System.String]
        $IngestUrl,

        [System.Guid]
        $ApplicationClientID,

        [system.String]
        $ApplicationClientKey,

        [System.Guid]
        $Authority,

        [System.String]
        $DatabaseName,

        [System.String]
        $TableName,

        [System.String]
        $FilePath
    )
    
    try {
        $KustoConnectionStringBuilder = [Kusto.Data.KustoConnectionStringBuilder]::new($IngestUrl,$DatabaseName)
        # .WithAadApplicationKeyAuthentication(
        #     $ApplicationClientID,
        #     $ApplicationClientKey,
        #     $Authority
        # )
        $KustoClient = [Kusto.Ingest.KustoIngestFactory]::CreateQueuedIngestClient(
            $KustoConnectionStringBuilder
        )
        $IngestionProperties = [Kusto.Ingest.KustoQueuedIngestionProperties]::new(
            $DatabaseName, 
            $TableName
        )
        $IngestionProperties.Format = [Kusto.Data.Common.DataSourceFormat]::csv 
        $IngestionProperties.IgnoreFirstRecord = $true
        $IngestionResult = $KustoClient.IngestFromStorageAsync(
            $FilePath,
            $IngestionProperties
        )
        $IngestionResult.Result.GetIngestionStatusCollection()
    }
    catch {
        throw $($Exception)
    }
}