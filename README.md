# ADX IoT Analytics Demo
Azure Data Explorer can provide valuable insights into your Iot workloads. In the following Demo we look at thermostat IoT Devices that are in 3 different office buildings.

The following will deploy the following:
- IoT Central Store Analytics Template 
  - 36 thermostat devices being created and simulated
  - Setup Export to Event Hub of telemetry data
- Event Hub 
  - Data exported from IoT Central
  - ADX Data Connection to ingest data
- Azure Digital Twins
  - Office, Floors, and Thermostat twins
  - Atlanta, Dallas, Seattle offices with 6 Floors in each
  - 36 Thermostat twins created spread across the 3 offices with 2 on each floor
- Azure Data Explorer
  - StageIoTRaw table where data lands from Event Hub to get new data
  - Thermastat table with update policy to transform raw data
  - Historical data from January 2022 loaded into Thermostat table
  - Two functions
    - GetDevicesbyOffice: query ADT by Office names to get all DeviceIds at the office
    - GetDevicesbyOfficeFloor: query ADT by Office and Floor to get all Devices on that floor 

## Deployment instructions

On the [Azure Cloud Shell](https://shell.azure.com/) run the following commands to deploy the solution:
1. Login to Azure
    ```bash
    az login
    ```

2. If you have more than one subscription, select the appropriate one:
    ```bash
    az account set --subscription "<your-subscription>"
    ```

3. Get the latest version of the repository
    ```bash
    git clone https://github.com/Azure/ADXIoTAnalytics.git
    ```
    Optionally, You can update the patientmonitoring.parameters.json file to personalize your deployment.

4. Deploy solution
    ```bash
    cd ADXIoTAnalytics
    . ./deploy.sh
    ```

5. Explore the data in ADX. Here is some sample queries to get you started! [KQL Sample](kqlsample/Sample.kql)

### Example:
![SampleCLIOutput](assets/SampleCLIOutput.png "SampleCLIOutput")



## Files used in the solution

- **asssets folder**: contains the following files:
  - AutomationPresentation.gif: quick explanation of the solution
  - Connected_Devices.pbix : sample report to visualize the data

- **config folder**: contains the configDB.kql that includes the code required to create the Azure Data Explorer tables and functions

- **dtconfig folder**: contains the files necessary to configure the Azure Digital Twins service:
  - Departments.json
  - Facility.json
  - KneeBrace.json
  - VirtualPatch.json

- **modules folder**: contains the [Azure Bicep](https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/) necessary to deploy and configure the resource resources used in the solution:
  - adx.bicep: ADX Bicep deployment file
  - digitaltwin.bicep: Digital Twin Bicep deployment file
  - eventhub.bicep: Event Hub Bicep deployment file
  - iotcentral.bicep: IoT Central Bicep deployment file
  - storage.bicep: Storage Bicep deployment file. This account is used as temporary storage to download ADX database configuration scripts)

- deploy.sh: script to deploy the solution. THe only one you need to run 
- main.bicep: main Bicep deployment file. It includes all the other Bicep deployment files (modules)
- patientmonitoring.parameters.json: parameters file used to customize the deployment
- README.md: This README file

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
