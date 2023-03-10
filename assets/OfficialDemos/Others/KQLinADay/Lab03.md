## Lab 3
### By using https://aka.ms/LADemo try to execute following tasks: 

1. How do I investigate the type of data in perf table?
   - Query Perf table take any 10 rows
```
Perf
| take 10;
```
2. How do I get the latest 10 rows from Perf table?
   - Query Perf table take latest 10 rows
```
Perf
| top 10 by TimeGenerated;
```
3. How do I get the list of various objects along with sample count for the counters?
   - Query Perf Table, count rows by combination of ObjectName, CounterName
```
Perf
| summarize count() by ObjectName, CounterName;
```
4. How do I get the exceptions during past 24 hours?
   - Query AppExceptions Table newer than 1 day
```
AppExceptions 
| where TimeGenerated >= ago(1d);
```
5. How do I get the latest 10 high or medium security alerts since Jan 1st, along with the 
time elapsed since the issue happened?
   - Query SecurityAlert Table where AlertSeverity is either High or Medium, and calculate HowLong ago events happened, howMuchTime passed since january  1st ,  than show 10 newest (and oldest) rows 
```
SecurityAlert
| where AlertSeverity in ("High", "Medium")
| extend HowLongAgo=( now() - TimeGenerated )
       , TimeSinceStartOfYear=( TimeGenerated - datetime(2021-01-01) )
| project AlertName 
        , AlertSeverity
        , DisplayName  
        , TimeGenerated 
        , HowLongAgo 
        , TimeSinceStartOfYear 
| top 10 by HowLongAgo asc;
```
6. How do I get the distribution of the number of security alerts generated throughout the day?
   - Query SecurityAlert Table, and show distribution of number of rows collected in each hour
```
SecurityAlert
| where AlertSeverity in ("High", "Medium")
| extend _HourOfday = hourofday(TimeGenerated) 
| summarize count() by _HourOfday
| order by  _HourOfday asc;
```
7. How do I get the list of alert with the severity and duration ordered by duration ascending?
   - Query SecurityAlert Table, show StartTime , EndTime and calculate duration. Order rows by duration
```
SecurityAlert
|  extend _duration=( EndTime - StartTime )
| project AlertName 
        , AlertSeverity
        , DisplayName , 
    _duration
| order by _duration asc;
```
8. How do I get the count of each activity per month for the last 365 days?
   - Query SecurityEvent Table in last 365 days, and show distribution of count of rows in each month
```
SecurityEvent
| where TimeGenerated >=ago(365d)
| extend MonthGenerated = startofmonth(TimeGenerated)
| project Activity
        , MonthGenerated 
| summarize EventCount=count() 
         by MonthGenerated  , Activity
| sort by MonthGenerated, Activity;
```
9. How do I get the number of security alert during easter?
   - Query SecurityEvent Table , and show number of rows collected per day this easter , (2021-04-01 to 2021-04-05)
```
SecurityEvent
| where TimeGenerated between (datetime(2021-04-01)..datetime(2021-04-05))  //easter holidays but BEWARE!!
//| where TimeGenerated between (datetime(2021-04-01)..datetime(2021-04-06))  //easter holidays OK!!
| extend dayGenerated = startofday(TimeGenerated)
| project dayGenerated 
| summarize EventCount=count()  by dayGenerated 
| sort by dayGenerated asc
```
10. How do I get the time at which Processor Time is greater than 70?
    - Query Perf  table where counterName is "% Processor Time" and CounterValue bigger than 70
```
Perf
| where CounterName == "% Processor Time" 
| where CounterValue between ( 70.0 .. 100.0 )
//| distinct Computer</code></pre></div>
```
11. How do I get the dates at which the Excptions are generated?
    - Query distinct dates from AppExceptions table
```
AppExceptions
| distinct floor( TimeGenerated,1d);
```
12. How go I get the list of dates at which the exception generated. However, I want to differntiate the other date as "another date" and current date as Today?
    - Query distinct dates from AppExceptions table, but current day should be represented as today, and all others as "anotherday"
```
AppExceptions
| extend day = iif(floor(TimeGenerated, 1d)==floor(now(), 1d), "today", "anotherday")
```
13. How go I get the list of dates at which the exception generated. However, I want to differntiate the other date as "another date" and current date as Today and I want to use startofday function?
    - Query distinct dates from AppExceptions table, but current day should be represented as today , and all others as "anotherday", but use startofday function
```
AppExceptions
| extend day = iif(startofday(TimeGenerated)==startofday(now()), "today", "anotherday")
```
14. How do I get the list of %age free space for the computers. Label the free space less than 10 as too low?
    - Query Perf table where CounterName is "% Free Space" and calculate description field: show OK if value is bigger than 10, and "Too low" for lower values
```
Perf
| where CounterName == "% Free Space"
| extend description = iif( CounterValue <= 10 ,  "Too low", "OK")
| project Computer
        , CounterName
        , CounterValue 
        , description 
| top 10 by description desc
```
15. How do I get % of free space broken down into more granular percentage ranges?
    - Query Perf table where CounterName is "% Free Space" and calculate description field : show different messages if value is loer than 10, between 10 and 30, between 30 and 50 and bigger than 50
```
Perf
| where CounterName == "% Free Space"
| extend description = case( CounterValue < 10, "less than 10 pct left"
                         , CounterValue < 30, "between 10 and 30 pct left"
                         , CounterValue < 50, "between 10 and 30 pct left"
                         , "No problems, more than 50% left"
                         )
| project Computer
        , CounterName
        , CounterValue 
        , description
```
16. How do I get the alerts generated by a client machine? 
    - Query SecurityAlert table where SourceComputerId is not empty
```
SecurityAlert
|  where  isempty( SourceComputerId ) == false
```
17. How do I get the alerts generated by client machine and alerts generated by non client machines?
    - Query SecurityAlert table and show SourceComputerID field, if it is empty state "unknown"
```
SecurityAlert
| extend SourceComputer = iif( isempty(SourceComputerId), "unknown", SourceComputerId)
```
18. How do I get the exceptions generated month, compare it with the previous month with month in ascending order?
    - Query AppExceptions Table in last 365 days , show count of rows per month , month and number of rows in previous month, sort by month in ascending order
```
AppExceptions
| where TimeGenerated between ( ago(365d) .. now() )
| summarize EventCount = count() by calMonth=startofmonth(TimeGenerated) 
| sort by calMonth asc
| extend MonthNumber = datetime_part("month", calMonth)
| extend YearNumber = datetime_part("year", calMonth)
//|serialize or sort 
| extend prvVal =  prev(MonthNumber)
```
19. How do I get the list of exceptions generated previous month and compare it with next month over the last 365 days?
    - Query AppExceptions Table in last 365 days , show count of rows per month , month and number of rows in previous month, and month difference to previous month sort by month in ascending order
```
AppExceptions
| where TimeGenerated between ( ago(365d) .. now() )
| summarize EventCount = count() by calMonth=startofmonth(TimeGenerated) 
| sort by calMonth asc
| extend MonthNum = datetime_part("month", calMonth)
| extend YearNum = datetime_part("year", calMonth)
| extend PreviousMonthValue  =  prev(EventCount)
| extend ValueGrowth  = EventCount- prev(EventCount)
| project  YearNum, MonthNum, EventCount,PreviousMonthValue,  ValueGrowth
```
20. How do I get the input bytes rate for each computers network adapter for last 3 hours?
    - Show in Perf Table total number of "Bytes Received/sec" when ObjectName is "Network Adapter" in previous 3 hours per each computer 
```
Perf
| where TimeGenerated >= ago(3h) 
| where ObjectName == "Network Adapter"
| where CounterName == "Bytes Received/sec" 
| summarize BytesRecPerHour = sum(CounterValue) 
         by Computer, bin(TimeGenerated, 1h)
| sort by Computer asc, TimeGenerated asc
| serialize BytesRecToCurrentHour = row_cumsum(BytesRecPerHour)
```
