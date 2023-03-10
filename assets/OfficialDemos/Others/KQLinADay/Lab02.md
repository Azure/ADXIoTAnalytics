## Lab2
### By using https://aka.ms/LADemo try to execute following tasks: 

1. How do I query any 10 records from the Alert table ?
   - Query any 10 records from "Query" Field from Alert table
```
Alert
| take 10
| project  Query;
```
2. How do I get the query that caused the alert?
   - Query Alert table, and use split function to break Query field into 4 parts
```
Alert
| extend _Query =split (Query, " | ")
| project _Table = _Query[0], 
    _WhereClauses = _Query[1],
    _WhereClauses2 = _Query[2],
    _WhereClausesFinal = _Query[3];
```
3. What were the assemblies loaded in the application?
   - Query assembly field from AppExceptions table
```
AppExceptions
| project Assembly;
```
4. How do I get the version, culture and key of the assemblies?
   - Query AppExceptions table and  use parse function to break field Assembly into parts
```
AppExceptions
| parse Assembly with *  
    "Version=" _version 
    "Culture=" _myCulture
    "PublicKeyToken" _myPKT
| project Assembly, _version, _myCulture, _myPKT
| top 10 by _version desc;
```
5. How do I get the perfcounters and the partition name from the instance machines?
   - Query PerfTable table and use matches regex "[A-Z]:" to get disk name from InstanceName column 
```
Perf
| where ObjectName == "LogicalDisk"
 |where InstanceName matches regex "[A-Z]:"
| project Computer 
        , CounterName 
        , extract("([A-Z]):", 0, InstanceName);
```
6. Are there any alerts generated from Microsoft Defender advanced threat protection? Do we have the json generated?
   - Query SecurityAlert table to show ExtendedProperties Field where ProviderName is MDATP, and extract  JSON content of the field.
```
SecurityAlert
| where ProviderName =="MDATP"
| extend ExtProps=todynamic(ExtendedProperties)
| project ExtendedProperties, ExtProps;
```
7. How do I get the report for important elements in the Extended properties field?
   - Query SecurityAlert table to show ExtendedProperties Query SecurityAlert table where ProviderName is MDATP and extract all fielde from JSON field ExtendedProperties
```
SecurityAlert
| where ProviderName =="MDATP"
| extend ExtProps=todynamic(ExtendedProperties)
| project ExtendedProperties ,AlertName, TimeGenerated
        , ExtProps["Windows Defender ATP link"] 
        , ExtProps["File Name"]
        , ExtProps["File Path"]
        , ExtProps["File Sha256"]
        , ExtProps["Machine Name"]
        , ExtProps["Machine Domain"]
        , ExtProps["User Name"]
        , ExtProps["User Domain"]
        , ExtProps["resourceType"]
        , ExtProps["ServiceId"]
        , ExtProps["ReportingSystem"];
```
8. How do I get the report for the all the fields of the ExtendedProperies field?
   - Query SecurityAlert table where ProviderName is MDATP and extract all fielde from JSON field ExtendedProperties and extract ALL individual values
```
SecurityAlert
| where ProviderName =="MDATP"
| extend ExtProps=todynamic(ExtendedProperties)
| extend ExtProps2=todynamic(ExtProps["Windows Defender ATP link"])
| extend ExtProps22=replace(@'\"',@'"', tostring(ExtProps2))
| extend ExtProps3=todynamic(ExtProps22)
| project ExtendedProperties ,AlertName, TimeGenerated
        , ExtProps["Windows Defender ATP link"] 
        , ExtProps["File Name"]
        , ExtProps["File Path"]
        , ExtProps["File Sha256"]
        , ExtProps["Machine Name"]
        , ExtProps["Machine Domain"]
        , ExtProps["User Name"]
        , ExtProps["User Domain"]
        , ExtProps["resourceType"]
        , ExtProps["ServiceId"]
        , ExtProps["ReportingSystem"]
        , ExtProps3["displayValue"]
        , ExtProps3["kind"]
        , ExtProps3["value"]
        , ExtProps3["alertBladeVisible"]
        , ExtProps3;
```
9. How do I get a report of the extendedproperties and the machine that generated the alert?
   - Query SecurityAlert  table where ProviderName is MDATP Query SecurityAlert table where ProviderName is MDATP and extract MachineName from ExtendedProperies using extract function
```SecurityAlert 
| where ProviderName =="MDATP"
| extend _MachineName=extract('"Machine Name": "(.*)"', 1, ExtendedProperties)
| extend _WinDEf=extract('"Windows Defender ATP link": "(.*)"', 1, ExtendedProperties)
| project ExtendedProperties, _WinDEf, _MachineName
| order by  _MachineName asc;
```
10. How do I list all the assemblies loaded in the application?
    - Query AppExceptions table , show just Assembly field
```
AppExceptions 
| distinct Assembly;
```
11. How do I get the list of all the properties of the Assemblies?
    - Query AppExceptions table and parse all elements from Assembly field divided by comma
```
AppExceptions 
| extend flds = parse_csv(Assembly)
| project flds

//or

AppExceptions 
| extend flds = parse_csv(Assembly)
| extend _assemblyVersion=split(flds[1], "=",1)
| extend _assemblyCulture=split(flds[2], "=",1)
| extend _assemblyPKT=split(flds[3], "=",1)
| project   _assemblyName=flds[0],
            _assemblyVersion,
            _assemblyCulture,
            _assemblyPKT;</code></pre></div>
```
