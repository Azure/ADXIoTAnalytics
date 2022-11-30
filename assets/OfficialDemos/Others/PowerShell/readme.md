# PowerShell Samples

Basic examples to read/write (ingest) using PowerShell

ref: 
- https://learn.microsoft.com/en-us/azure/data-explorer/kusto/api/netfx/kusto-ingest-client-reference
- https://github.com/Azure/azure-kusto-samples-dotnet

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
