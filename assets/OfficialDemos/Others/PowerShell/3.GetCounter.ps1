cd .\assets\OfficialDemos\Others\PowerShell

Get-Counter | Format-Table

# but I want a JSON
# https://stackoverflow.com/questions/53301704/convert-powershell-table-to-json-with-column-1-as-key-and-column-2-as-value

Get-Counter | ConvertTo-Csv

Get-Counter | ConvertTo-Json | Out-File Counter.json

.\Counter.json
# We only need CounterSamples from Get-Counter

(Get-Counter).CounterSamples | sele| ConvertTo-Json

# Important columns 
(Get-Counter).CounterSamples | Select-Object Timestamp, Path, InstanceName, CookedValue | ConvertTo-Json | Out-File Counter.json

.\Counter.json

# Next, create table & mapping kql via https://dataexplorer.azure.com/oneclick