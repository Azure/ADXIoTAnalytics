#!/bin/bash

# Helper Functions
function banner() {
    clear
    echo '           _______   __           _   ______   ________            '
    echo '     /\   |  __ \ \ / /          | | |  _   | |__   ___|           '
    echo '    /  \  | |  | \ V /   ______  | | | |  | |    |  |              '
    echo "   / /\ \ | |  | |> <   |______| | | | |  | |    |  |              "
    echo '  / ____ \| |__| / . \           | | | |__| |    |  |              '
    echo ' /_/    \_\_____/_/_\_\          |_| |_____ |    |_ |              '
    echo '        |__   __| | |                   | |                        '
    echo '           | | ___| | ___ _ __ ___   ___| |_ _ __ _   _            '
    echo "           | |/ _ \ |/ _ \ '_ \` _ \ / _ \ __| '__| | | |          "
    echo '           | |  __/ |  __/ | | | | |  __/ |_| |  | |_| |           '
    echo '           |_|\___|_|\___|_| |_| |_|\___|\__|_|   \__, |           '
    echo '                                                   __/ |           '
    echo '                                                  |___/            '
}

function spinner() {
    local info="$1"
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  $info" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        echo -ne "\033[0K\r"
    done
}

function deletePreLine() {
    echo -ne '\033[1A'
    echo -ne "\r\033[0K"
}

# Service Specific Functions
function add_required_extensions() {
    az extension add --name azure-iot --only-show-errors --output none; \
    az extension update --name azure-iot --only-show-errors --output none; \
    az extension add --name kusto --only-show-errors --output none; \
    az extension update --name kusto --only-show-errors --output none
}

function create_resource_group() {
    az group create --name $rgName --location "East US" --only-show-errors --output none
}

function deploy_azure_services() {
    az deployment group create -n $deploymentName -g $rgName \
        --template-file main.bicep \
        --parameters deploymentSuffix=$randomNum principalId=$principalId @iotanalytics.parameters.json \
        --only-show-errors --output none
}

function get_deployment_output() {
    dtName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinName.value --output tsv)
    dtHostName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinHostName.value --output tsv)
    saName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.saName.value --output tsv)
    saKey=$(az storage account keys list --account-name $saName --query [0].value -o tsv)
    saId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.saId.value --output tsv)
    adxName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxName.value --output tsv)
    adxResoureId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxClusterId.value --output tsv)
    location=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.location.value --output tsv)
    eventHubNSId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventhubClusterId.value --output tsv)
    eventHubResourceId="$eventHubNSId/eventhubs/iotdata"
    eventHubHistoricId="$eventHubNSId/eventhubs/historicdata"
    iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value --output tsv)
    iotCentralAppID=$(az iot central app show -n $iotCentralName -g $rgName --query  applicationId --output tsv)
    numDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.deviceNumber.value --output tsv)
    eventHubConnectionString=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventHubConnectionString.value --output tsv)
}

function configure_ADX_cluster() {
    sed -i "s/<dtURI>/$dtHostName/g" config/configDB.kql ;\
    #sed -i "s/<saname>/$saName/g" config/configDB.kql ;\
    #sed -i "s/<sakey>/$saKey/g" config/configDB.kql ;\
    az storage blob upload -f config/configDB.kql -c adxscript -n configDB.kql \
        --account-key $saKey --account-name $saName --only-show-errors --output none  ;\
    blobURI="https://$saName.blob.core.windows.net/adxscript/configDB.kql"  ;\
    blobSAS=$(az storage blob generate-sas --account-name $saName --container-name adxscript \
        --name configDB.kql --permissions acdrw --expiry $tomorrow --account-key $saKey --output tsv)  ;\
    az kusto script create --cluster-name $adxName --database-name IoTAnalytics  \
        --force-update-tag "config1" --script-url $blobURI --script-url-sas-token $blobSAS \
        --resource-group $rgName --name 'configDB' --only-show-errors --output none  ;\
    az kusto data-connection event-hub create --cluster-name $adxName --name "IoTAnalytics" \
        --database-name "IoTAnalytics" --location $location --consumer-group '$Default' \
        --event-hub-resource-id $eventHubResourceId --managed-identity-resource-id $adxResoureId \
        --data-format 'JSON' --table-name 'StageIoTRawData' --mapping-rule-name 'StageIoTRawData_mapping' \
        --compression 'None' --resource-group $rgName --only-show-errors --output none

    az kusto data-connection event-grid create --cluster-name $adxName -g $rgName --database-name "IoTAnalytics" \
        --table-name "Thermostats" --name "HistoricalLoad" --ignore-first-record true --data-format csv  \
        --mapping-rule-name "Thermostats_mapping" --storage-account-resource-id $saId \
        --consumer-group '$Default' --event-hub-resource-id $eventHubHistoricId
    az storage blob upload -f config/Thermostat_January2022.csv -c adxscript -n Thermostat_January2022.csv \
        --account-key $saKey --account-name $saName --only-show-errors --output none  ;\
}

function create_digital_twin_models() {
    az dt model create -n $dtName --from-directory ./dtconfig  --only-show-errors --output none ; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Office;1" --twin-id Dallas --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Office;1" --twin-id Seattle --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Office;1" --twin-id Atlanta --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL1 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL2 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL3 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL4 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL5 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL6 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA1 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA2 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA3 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA4 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA5 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA6 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL1 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL2 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL3 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL4 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL5 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL6 --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F1'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL1' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F2'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL2' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F3'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL3' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F4'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL4' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F5'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL5' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F6'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL6' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F1'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA1' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F2'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA2' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F3'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA3' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F4'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA4' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F5'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA5' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F6'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA6' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F1'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL1' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F2'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL2' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F3'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL3' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F4'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL4' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F5'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL5' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F6'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL6' \
        --only-show-errors --output none; \
}

function deploy_thermostat_devices() {
    for (( c=1; c<=$numDevices; c++ ))
    do
        deviceId=$(cat /proc/sys/kernel/random/uuid)
        az iot central device create --device-id $deviceId --app-id $iotCentralAppID \
            --template dtmi:m43gbjjsrr5:fp1yz0dm0qs --simulated --only-show-errors --output none

        floornum=$(expr $c % 18)
        
        floor=${floors[$floornum]}
            
        az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Thermostat;1" --twin-id $deviceId \
            --only-show-errors --output none ;\
        az dt twin relationship create -n $dtName --relationship-id "contains${deviceId}" \
            --relationship 'floorcontainsdevices' --source $floor --target $deviceId --only-show-errors --output none
    done
}

function configure_IoT_Central_output() {
    az iot central export destination create --app-id $iotCentralAppID --dest-id 'eventHubExport' \
        --type eventhubs@v1 --name 'eventHubExport' \
        --authorization '{"type": "connectionString", "connectionString": "'$eventHubConnectionString'" }' \
        --only-show-errors --output none  ; \
    az iot central export create --app-id $iotCentralAppID --export-id 'iotEventHubExport' \
        --display-name 'iotEventHubExport' --source 'telemetry' --destinations '[{"id": "eventHubExport"}]' \
        --only-show-errors --output none
}

# Define required variables
randomNum=$RANDOM
currentDate=$(date)
tomorrow=$(date +"%Y-%m-%dT00:00:00Z" -d "$currentDate +1 days")
deploymentName=ADXIoTAnalyticsDeployment$randomNum
rgName=ADXIoTAnalytics$randomNum
principalId=$(az ad signed-in-user show --query objectId -o tsv)

# Setup array to utilize when assiging devices to departments and patients
floors=('DAL1' 'DAL2' 'DAL3' 'DAL4' 'DAL5' 'DAL6' 'SEA1' 'SEA2' 'SEA3' 'SEA4' 'SEA5' 'SEA6' 'ATL1' 'ATL2' 'ATL3' 'ATL4' 'ATL5' 'ATL6')

banner # Show Welcome banner

echo '1. Starting solution deployment'
add_required_extensions & # Install/Update required eztensions
spinner "Installing IoT Extensions"
create_resource_group & # Create parent resurce group
spinner "Creating Resource Group"
deploy_azure_services & # Create all additional services using main Bicep template
spinner "Deploying Azure Services"

echo "2. Starting configuration for deployment $deploymentName"
get_deployment_output  # Get Deployment output values

# Start Configuration
configure_ADX_cluster & # Configure ADX cluster
spinner "Configuring ADX Cluster"
# Get/Refresh IoT Central Token 
az account get-access-token --resource https://apps.azureiotcentral.com --only-show-errors --output none
create_digital_twin_models & # Create all the models from folder in git repo
spinner "Creating model for Azure Digital Twins $dtName"

# Complete configuration
echo "Creating $numDevices Smart Knee Brace devices on IoT Central: $iotCentralName ($iotCentralAppID) and Digital Twins: $dtName"
deploy_thermostat_devices # Deploy Thermostat simulated devices
configure_IoT_Central_output & # On IoT Central, create an Event Hub export and destination with json payload
spinner " Creating IoT Central App export and destination on IoT Central: $iotCentralName ($iotCentralAppID)"

echo "3. Configuration completed"