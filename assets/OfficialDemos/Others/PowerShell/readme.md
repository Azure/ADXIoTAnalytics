# PowerShell Samples

Basic examples to read/write (ingest) using PowerShell. This is **NOT** meant to be an enterprise-agent collection solution. This demos ingestion using PowerShell and Kusto .Net SDK. 

Examples include: 
- ingesting an **array from memory** 
- ingesting a **local csv file** 
- and **streaming** - COMMING SOON.

ref: 
- https://learn.microsoft.com/en-us/azure/data-explorer/kusto/api/netfx/kusto-ingest-client-reference
- https://github.com/Azure/azure-kusto-samples-dotnet
- https://www.powershellgallery.com/packages/PowerShell.Azure.Data.Explorer/0.0.4/Content/functions%5CImport-CsvToADX.ps1

##  Pre-reqs:

```
Invoke-WebRequest -Uri https://nuget.org/api/v2/package/Microsoft.Azure.Kusto.Tools -OutFile Microsoft.Azure.Kusto.Tools.zip
Expand-Archive .\Microsoft.Azure.Kusto.Tools.zip -Destination "C:\Microsoft.Azure.Kusto.Tools\" -Force
Remove-Item .\Microsoft.Azure.Kusto.Tools.zip -force
```
Install PowerShell 7: 
```
winget install --id Microsoft.Powershell --source winget
```

Next step:
1. create another version of 4.Kusto-BasicIngest-JSON.ps1 to collect for 30s and post once, reusing client continuously. :white_check_mark:
2. add from local storgage example :white_check_mark:
3. add streaming example
