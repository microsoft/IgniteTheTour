# Tailwind Traders Data Generator

Tailwind Traders operates a number of physical retail locations in addition to an online store.  To supplement the development of real-time data ingestion services, the development team has created a special IoT Edge module which generates cash register data for use in tuning and testing of these services.

## Prerequisites

* [Docker](https://docs.docker.com/install/) - Allows for local deployment of a containerized IoT Edge device
* [Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest?&WT.mc_id=MSIgniteTheTour-github-dat10) - Used for creating an IoT Hub in Azure and registering a new IoT Edge device with the IoT Hub
* [Python 2.7x OR Python 3.x](https://www.python.org/downloads/) - Required for installation of the Azure Cli IoT Extension

## Steps to run the data generator on Windows / MAC / Linux

### 1. Login and set subscription with Azure Cli

Open a terminal / command line session and login to azure with:

    az login 

Next, locate your intended subscription with:

    az account list

Set the azure cli to use your intended subscription with:

    az account set --subscription <SUBSCRIPTION_ID> 

### 2. Create an Azure IoT Hub

Create a resource group:
    
You must replace `<RESOURCEGROUP_NAME>` and may optionally change the location parameter.  
    
You can view a list of available locations by running this command:

    az account list-locations -o table

To create the resource group, execute the following:

    az group create --name <RESOURCEGROUP_NAME> --location eastus

Create the IoT Hub:

This command creates an IoT hub in the S1 pricing tier for which you are billed. For more information, see [Azure IoT Hub pricing](https://azure.microsoft.com/pricing/details/iot-hub/?WT.mc_id=MSIgniteTheTour-github-dat10).

    az iot hub create --name <IOTHUB_NAME> --resource-group <RESOURCEGROUP_NAME> --sku S1


### 3. Install the Azure Cli IoT Extension and Create a New IoT Edge Device

Install the Azure Cli IoT Extension:

    az extension add --name azure-cli-iot-ext

Create a new IoT Edge Device:

The following will create an IoT Edge device with a device-id of 'DataGenerator'.  

You must replace `<IOTHUB_NAME>` with the name of the IoT Hub created in the previous step.

    az iot hub device-identity create --device-id DataGenerator --hub-name <IOTHUB_NAME> --edge-enabled

### 4. Set the Modules for the Newly Created IoT Edge Device

This step will apply a configuration to the IoT Edge Device with device-id `DataGenerator` as specified in [deployment.template.json](./deployment.template.json).  

This specification includes a module named `IoTEdgeBogusDataGenerator` which will be pulled from [toolboc/azure-iot-edge-bogus-data-generator](https://hub.docker.com/r/toolboc/azure-iot-edge-bogus-data-generator/) and a route named `IoTEdgeBogusDataGeneratorToIoTHub` which forwards all messages from the `IoTEdgeBogusDataGenerator` module to the associated IoTHub.  

You must replace `<IOTHUB_NAME>` with the name of the IoT Hub created earlier.

    az iot edge set-modules --hub-name <IOTHUB_NAME> --device-id DataGenerator --content ./deployment.template.json

### 5. Create a containerized IoT Edge Device using the DataGenerator ConnectionString

This step will create a containerized IoT Edge Device using the [azure-iot-edge-device-container](https://hub.docker.com/r/toolboc/azure-iot-edge-device-container/).  The docker image includes all of the prerequisites necessary to run the IoT Edge runtime on AMD64 and ARM32 compatible devices.  It only requires that Docker is present on the host machine.

Obtain the Device Connection String for the DataGenerator device:

You must replace `<IOTHUB_NAME>` with the name of the IoT Hub created earlier.

    az iot hub device-identity show-connection-string --device-id DataGenerator --hub-name <IOTHUB_NAME>

Copy the connection string value (It should begin with *"Hostname="*)

Start an instance of the azure-iot-edge-device-container with:

You must replace `<IoTHubDeviceConnectionString>` with the value of the connection string obtained earlier.

    docker run --name DataGenerator -d --privileged -e connectionString=<IoTHubDeviceConnectionString> toolboc/azure-iot-edge-device-container

The container may take some time to start, once running, it will begin to communicate with the IoT Hub where it will obtain the module configuration created in the previous step.  

You can verify that the `IoTEdgeBogusDataGenerator` module is running by first obtaining the container's internal ip address with:

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' DataGenerator

Next, run the following command:

You must replace `<IP_ADDRESS>` with the value of the ip address obtained in the previous command.

    docker exec DataGenerator iotedge -H http://<IP_ADDRESS>:15580 list

You should see an output similar to:

    NAME                       STATUS           DESCRIPTION      CONFIG
    IoTEdgeBogusDataGenerator  running          Up 15 minutes    toolboc/azure-iot-edge-bogus-data-generator
    edgeHub                    running          Up 15 minutes    mcr.microsoft.com/azureiotedge-hub:1.0
    edgeAgent                  running          Up 15 minutes    mcr.microsoft.com/azureiotedge-agent:1

### 6. Cleaning Up

To stop the DataGenerator container, run the following:

    docker stop DataGenerator

To remove the DataGenerator container instance from Docker, run the following after stopping the container:

    docker rm DataGenerator

## Additional Resources

* [Azure IoT Edge Bogus Data Generator Repository](https://github.com/toolboc/azure-iot-edge-bogus-data-generator) - The source repo for the `IoTEdgeBogusDataGenerator` module
* [Azure IoT Edge Device Container](https://github.com/toolboc/azure-iot-edge-device-container) - The source repo for the containerized IoT Edge Device
* [IoTEdge-DevOps](https://github.com/toolboc/IoTEdge-DevOps) - A living repository of best practices and examples for developing [Azure IoT Edge](https://docs.microsoft.com/en-us/azure/iot-edge/?WT.mc_id=MSIgniteTheTour-github-dat10) solutions doubly presented as a hands-on-lab.
