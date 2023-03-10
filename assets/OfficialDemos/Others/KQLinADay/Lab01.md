By using https://aka.ms/LADemo try to execute following tasks:

1. How do I query AppExceptions table ?
- Query AppExceptions table
```
AppExceptions 
//use comments
```
2. How do I limit the number of rows in the result?
- Query any 10 rows from table AppExceptions
```
AppExceptions 
| take 10
```
3. How do I query the number of rows in AppExceptions table?
- Query number of rows in AppExceptions Table
```
AppExceptions // note the default time range (24h)
| count
```
4. How do I find out the severity level of the logs generated?
- List all unique values of field SeverityLevel from Table AppExceptions
```
AppExceptions
| distinct SeverityLevel
```
5. How can I associate the client with the severitylevel of exceptions?
- List all unique combinations of fiels SeverityLevel and ClientType from Table AppExceptions
```
AppExceptions
| distinct SeverityLevel, ClientType
```
6. How do I filter the data for clients of type 'PC' for last 24 hours?
- List all rows in AppExceptions table we have in previous 1 day where ClientType is "PC"
```
AppExceptions
| where  TimeGenerated >= ago(1d)
| where  ClientType =="PC"
```
7. How do I find out number of logs generated by PC clients?
- How many rows in AppExceptions table we have in previous 1 day where ClientType is "PC"
```
AppExceptions
| where  TimeGenerated >= ago(1d)
| where  ClientType =="PC"
| count
```
8. How do I filter my data for clients of type 'PC' from outside of United States. I am specially interested in Browser, the city, the country , the model of the computer and the OperatingSystem?  I want the data sorted by time desc.
- List ClientBrowser, ClientCity, ClientCountryOrRegion , ClientModel, ClientOS  fields values found in AppExceptions Table where ClientType is "PC" in previous 1 day and ClientCountryOrRegion is not "United States"
```
AppExceptions
| where  TimeGenerated >= ago(1d)
| where  ClientType =="PC"
| where ClientCountryOrRegion  != "United States" 
| project ClientBrowser, ClientCity, ClientCountryOrRegion , ClientModel, ClientOS
```
9. How do I get the list of city and country with column name formatted for my reporting purposes?
- List City and Org fields values found in AppExceptions Table  where ClientTYpe is "PC" in previous 1 day and ClientCountryOrRegion is not "United States". City is created from ClientCity field and Org is concatenating ClientCity and ClientCountryOrRegion
```
AppExceptions
| where  TimeGenerated >= ago(1d)
| where  ClientType =="PC"
| where ClientCountryOrRegion  != "United States" 
| project City =ClientCity, Org= strcat(ClientCity , " - ", ClientCountryOrRegion)
```
10. How do I get the first 10 rows from AppException table for PC?
- List first 10 rows from AppExceptions table where ClientTYpe is "PC" in previous 1 day sorted by TimeGenerated
```
AppExceptions
| where  TimeGenerated <= ago(1d)
| where  ClientType =="PC"
| top 10 
| order by TimeGenerated desc
```
11. How do I list the AppExceptions in last 10 days?
- List number of AppExceptions in last 10 days
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| count
```
12. How do I get number of exceptions from New York or from Approleinstance – 'RETAILVM01'?
- List number of AppExceptions in last 10 days where ClientCity is "New York" or  AppRoleInstance is "RetailVM01"
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| where ClientCity =="New York" or AppRoleInstance == "RETAILVM01"
| count ;
```
13. How do I filter the exception records for the outer message starting with "input" for last 10 days? Can I get the count of records?
- List number of AppExceptions in last 10 days where Find all rows in AppExceptions table in last 10 days where OuterMessage field starts with "Input". How many rows?
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| where OuterMessage  startswith "input"
//| count ;
```
14. How do I filter the exception records for the outer message starting with "SQL" for last 10 days? Can I get the count of records?
- Find number of rows in AppExceptions table in last 10 days where OuterMessage is mentioning SQL.
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| where OuterMessage contains "SQL"
| count ;
```
15. How do I filter the exception records for the outer message starting with "SQL"(all caps)?
- List all rows in AppExceptions table in last 10 days where OuterMessage is mentioning  SQL but not sql
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| where OuterMessage  contains_cs "SQL"
//| count ;
```
16. How do I filter the exception records for the outer message starting with "Format"(exact case)?
- List all rows in AppExceptions table in last 10 days where OuterMessage is ending with casesensitive "Format".
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| where OuterMessage  endswith_cs "Format"
//| count ;
```
17. How do I filter the exceptionrecords that has filter in any of the columns?
- List all rows in AppExceptions table in last 10 days having SQL in any column
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| search "SQL";
```
18. How do I filter the exceptionrecords where problemId starts with "System"?
- List all rows in AppExceptions table in last 24 hours having ProblemId startsWith "System"
```
AppExceptions
| where  TimeGenerated >= ago(24h)
| search ProblemId: "System*"
//| distinct  ProblemId
```
19. How do I generate a report the number of exceptions per city in last 10 days?
- Count number of rows in table AppExceptions in last 10 days per ClientCity
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| summarize count() by ClientCity
```
20. How do I determine the city and the severitylevel  of the exception with the client type as "Browser"?
- Count number of rows in table AppExceptions in last 10 days per ClientCity and SeverityLevel if Client Type is "Browser"
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| summarize countif(ClientType=="Browser") by ClientCity, SeverityLevel
```
21. How do I generate the report for the count of exceptions per clientbrowser per city?
- Count number of rows in table AppExceptions in last 10 Show TotalCount of rows in table AppExceptions in last 10 days per ClientCity and ClientBrowser. TotalCount is calculated using function `count()`
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| summarize TotalCount = count() by ClientCity, ClientBrowser
```
22. How do I generate the report of count of exceptions and average severitylevel for each client city?
- Show TotalCount and Average of severityLevel of rows in table AppExceptions in last 10 days per ClientCity. 
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| summarize count() , avg(SeverityLevel) by ClientCity
```
23. How do I get the number of rows in AppExcption table per day for last 10 days?
- Show number of rows in table AppExceptions in last 10 days per day
```
AppExceptions
| where  TimeGenerated >= ago(10d)
| summarize count()  by bin(TimeGenerated , 1d)</code></pre></div>
```
24. Lets get the timegenerated columns as Day, month and year so that we can use these fields in our reporting?
- Create Field showing day number , monthnumber and year year from field TimeGenerated in last 10 days in AppExceptions table and show any 10 rows
```
AppExceptions
| extend _Day=dayofmonth(TimeGenerated)  
| extend _Month= monthofyear(TimeGenerated)  
| extend _Year=getyear(TimeGenerated)  
| where  TimeGenerated >= ago(10d)
| take 10
```
25. How do I get the number of exceptions for each day, month and year?  Getting the data for last 10 days will suffice.
- Create Field showing day number , monthnumber and year year from field TimeGenerated in last 10 days in AppExceptions table and show number of rows per daynumber , month and year
```
AppExceptions
| extend _Day=dayofmonth(TimeGenerated)  
| extend _Month= monthofyear(TimeGenerated)  
| extend _Year=getyear(TimeGenerated)  
| where  TimeGenerated >= ago(10d)
| summarize count()  by _Year, _Month, _Day
```