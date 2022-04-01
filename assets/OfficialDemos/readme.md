# Demos E2E - (WIP, edit links)

- All official [demo scripts](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official) end-to-end.
- Additional, alternate demos available in [Backpocket](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Backpocket).

## Module 1.1 - Intro
1. Show how to provision an ADX cluster via portal.azure.com, like shown in steps 1-7 of https://aka.ms/adx.lab.  
2. Show how to scale a cluster
3. Show Insights blade
4. Run the https://aka.ms/adx.try Kusto queries below. 

### Run Script: [M01-Demo1-Intro.kql](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M01-Demo1-Intro.kql&version=GBmain) 


## Module 1.2 - Overview
1. IoT Data script
2. Step through the script in parts at a time like building blocks.
   1. multiline json object
   2. variable `d` of `dynamic` datatype
   3. `.set` creates new table from `d` by using the `<|` operator.
   4. proceed to the end and cover `mv-expand` from line `let op=`
   5. add a line to run each in part in steps after `iotPayload`.
   
3. Watch [readiness video](https://msit.microsoftstream.com/video/1776a78a-515f-481d-b03d-70f13628ef04?st=1421)
4. Connects to a [Hiram's](https://aka.ms/hiram) personal cluster, you can create one at https://aka.ms/adx.free
5. Data is in the script, nothing else is required.

### Run Script: [M01-Demo2-Overview.kql](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M01-Demo2-Overview.kql&version=GBmain) 


## Module 1.3 Ingestion
### Ingestion via One-Click UI (**Important**)
1. Show [one-click ingestion](https://docs.microsoft.com/en-us/azure/data-explorer/ingest-data-one-click).
2. Load [Thermostat_January2022.csv](https://github.com/Azure/ADXIoTAnalytics/blob/main/config/Thermostat_January2022.csv) to your [personal cluster](https://aka.ms/adx.free) into a new table.

### Ingestion via Az CLI 
3. Show by walking through Hands-On Lab file [configDB.kql line 9](https://github.com/Azure/ADXIoTAnalytics/blob/0c8ce64c00c8277a3510b69f4aa897ec0b87e89a/config/configDB.kql#L9) and [deploy.sh 95-98](https://github.com/Azure/ADXIoTAnalytics/blob/0c8ce64c00c8277a3510b69f4aa897ec0b87e89a/deploy.sh#L95), then [99-100](https://github.com/Azure/ADXIoTAnalytics/blob/0c8ce64c00c8277a3510b69f4aa897ec0b87e89a/deploy.sh#L99) which is how the upload **automatically** occurs during deployment.

### Ingestion via KQL
4. Show [`.ingest` example](https://docs.microsoft.com/azure/data-explorer/kusto/management/data-ingestion/ingest-from-storage) to load from blob.

### Run Script: [M01-Demo3-Ingestion.kql](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M01-Demo3-Ingestion.kql&version=GBmain) 


## Module 2.1 - IoT
1. This is the **main demo** of the workshop. 
2. If needed, [join this SG](https://idwebelements/GroupManagement.aspx?Group=adxdemoenv&Operation=join) to get access. See more: [here](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Backpocket/IoTCustomerStoriesWithADX/readme.md).
3. Synapse Data Explorer is **not required** to demo in this workshop. 
3. For this demo place emphasis on: 
   * Thermostat data
   * JSON
   * Render & Pin to dashboard. (toggle between both)
   * Series fill linear
   * Forecast
   * Anomalies
   * [ADX Dashboard](https://dataexplorer.azure.com/dashboards/474edab9-00cf-4b9e-b785-8669b90c01e4?startTime=24hours&endTime=now&Device_Id=637085868243706792) & [Grafana](https://kustografanademo.scus.azgrafana.io/d/RmU02Dtnz/iot-demo-dashboard?orgId=1&var-Devices=1iqisxd5v6e&var-Devices=1k4gso7qv5y&from=1637640911640&to=1637684111640)
   * Materialized Views
   * External Tables

### Run Script: [M02-Demo4-IoT.kql](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M02-Demo4-IoT.kql&version=GBmain) 


## Module 3 - Hands-on Lab 
* https://aka.ms/adx.iot, follow the [Readme.md](https://github.com/Azure/ADXIoTAnalytics#readme)
* For the instructor's lab, deploy it prior because it takes a few minutes for IoT Central to start ingesting raw data.
* If attendee(s) do not have an Azure subscription, or didn't sign-up for a trial prior:
   * You may grant them access using this [script](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/0_AddAccess.kql&version=GBmain) to your ADX cluster (ie. *adxpm#####.eastus*) to let them get their hands on ADX and run the lab KQL queries. (**Recommended**)
   * They may create a free personal cluster at https://aka.ms/adx.free, ingest the historical csv from the repo to a new table, and run the sample KQL queries. **Alternative**

###IMPORTANT: 
1. Before you start the HOL, show how to create an ADX cluster via the portal upto the validate section. 
2. Show the how to setup Azure CLI storage account if it’s the first time for the audience.
3. Show the Hands-On Lab materials and assist with any questions regarding the materials.
4. The secret sauce is in config, assets, kqlsample and deploy.sh.
5. The kqlsample contains challenges, participants should explore and to get the outputs.
4. Show IoT Central application: https://iotcentralpm10774domain.azureiotcentral.com/devices
Data Explorer
Dashboards
Rules
Data exports & destinations
5. Event Hubs Namespace Overview > Entities > Event Hubs
6. Event Grid System Topic > Name > HistoricData
7. Twin https://digitaltwinpm10774.api.eus.digitaltwins.azure.net, run query, and toggle the twin graph layouts
8. ADX 
Overview > Activity Log > Diagnose and solve problems > Query
Scale up/out > Configurations > Permissions
Databases > Permissions
Insights > Overview Top resource consumers. Key Metrics > Queries,  Ingestion, Streaming, Connections. Usage, Tables, Cache, Ingestion > Successful, Failed, Total latency, Ingestion utilization, Bound Scores > CPU, Ingest, Cache. Materialized Views
Advisor recommendations > Description > Actions > Details
Diagnostics settings > Edit
Logs > Cluster availability (KeepAlive) > Run 
Workbooks > ADX
9. Storage Account > Container > adxscript


https://dev.azure.com/CEandS/Azure-Data-Explorer/_wiki/wikis/ADX-with-IoT-Analytics/1105/Demos


### Exercise Script: [M03-HOL.kql](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M03-HOL.kql&version=GBmain) 


## Module 6 - ML
1. Requires having joined the SG mentioned above on IDWeb.
2. Show UnSupervised Learning talk about the Python code in lines 7-19
3. Run lines 26-31 to invoke custom UDF for KMeans clusters.
4. Mention how this adds capability to not possible with `autocluster()` and specify 3 clusters

### Run Script: [M03-Demo5-ML.kql](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M06-Demo5-ML.kql&version=GBmain) 


## Module 7 - Visuals
1. Requires having joined the SG mentioned above on IDWeb.
1. ADX Dashboard: [IoT Demo 01](https://dataexplorer.azure.com/dashboards/474edab9-00cf-4b9e-b785-8669b90c01e4?startTime=24hours&endTime=now&Device_Id=637085868243706792)
2. Edit query, run again. Emphasize the experience of toggling between queries over live data and dashboards.
3. Power BI: [Thermostat](https://msit.powerbi.com/links/heOSdYKjLz?ctid=72f988bf-86f1-41af-91ab-2d7cd011db47&pbi_source=linkShare)
4. Emphasize how Power BI uses Direct Query - very performant on ADX over massive amounts of data. 
5. Emphasize pining report visuals to Power BI Dashboards that join Finance & Ops insights.
6. Only demo this one if applicable to attendees: [Grafana IoT Demo Dashboard](https://kustografanademo.scus.azgrafana.io/d/RmU02Dtnz/iot-demo-dashboard?orgId=1&var-Devices=1iqisxd5v6e&var-Devices=1k4gso7qv5y&from=1637640911640&to=1637684111640)


## Module 9 - Advanced 
* Requires having joined the SG mentioned above on IDWeb.
* Congratulations, you made to the **FINAL** demo of the day.
* Methods to execute this demo:
   1. Preview mode **(Recommended)**. Open in your web browse the notebook [M09-Demo100-NYCTaxiGeoClustering.ipynb](https://dev.azure.com/CEandS/Azure-Data-Explorer/_git/ADX-with-IoT-Analytics?path=/Demos/Official/M09-Demo100-NYCTaxiGeoClustering.ipynb&version=GBmain).
   2. Azure Data Studio (Requires installing: Kusto extension and KQLMagic)
* The purpose is to find the best places to Park the taxi based on Pickup rides' latitude and longitude.
* Step through the code cells one at a time. 
