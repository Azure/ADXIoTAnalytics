# PowerShell Samples

Basic examples to read/write (ingest) using PowerShell. This is not meant to be an enterprise-agent collection solution. This demos ingestion using PowerShell and Kusto .Net SDK. 

Examples include: 
- ingesting an **array from memory** 
- ingesting a **local csv file** 
- and **streaming**

ref: 
- https://learn.microsoft.com/en-us/azure/data-explorer/kusto/api/netfx/kusto-ingest-client-reference
- https://github.com/Azure/azure-kusto-samples-dotnet
- https://www.powershellgallery.com/packages/PowerShell.Azure.Data.Explorer/0.0.4/Content/functions%5CImport-CsvToADX.ps1

##  Pre-reqs:
1. Install PowerShell 7: 
```
winget install --id Microsoft.Powershell --source winget
```
2. Install Kusto Tools:
```
Invoke-WebRequest -Uri https://nuget.org/api/v2/package/Microsoft.Azure.Kusto.Tools -OutFile Microsoft.Azure.Kusto.Tools.zip
Expand-Archive .\Microsoft.Azure.Kusto.Tools.zip -Destination "C:\kustotools\" -Force
Remove-Item .\Microsoft.Azure.Kusto.Tools.zip -force
```

## Troubleshooting:
1. If you get unable to load Azure.Core then try these steps.
```
Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Azure.Core/1.38.0 -OutFile Azure.Core.zip
Expand-Archive .\Azure.Core.zip -Destination "C:\kustotools\azurecore\" -Force
Remove-Item .\Azure.Core.zip -force
```



Next step:
1. create another version of 4.Kusto-BasicIngest-JSON.ps1 to collect for 30s and post once, reusing client continuously. :white_check_mark:
2. add from local storgage example :white_check_mark:
3. add streaming example :white_check_mark:
