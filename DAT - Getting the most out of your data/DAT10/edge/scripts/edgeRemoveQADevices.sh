#!/bin/bash

# IoT Edge Remove QA Devices Script
# Requires jq & azure cli - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

iothub_name=$1
environment=$2

az_iot_ext_install_status=$(az extension show --name azure-cli-iot-ext)
az_iot_ext_install_status_len=${#az_iot_ext_install_status}

if [ $az_iot_ext_install_status_len -eq 0 ]
then
    az extension add --name azure-cli-iot-ext
fi

az iot hub query --hub-name $iothub_name --query-command "SELECT * FROM devices WHERE tags.environment = '$environment'" | jq -r .[].deviceId | xargs --no-run-if-empty -L 1 az iot hub device-identity delete --hub-name $iothub_name --device-id