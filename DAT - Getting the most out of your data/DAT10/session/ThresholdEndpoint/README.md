# Tailwind Traders Data Processing Layer Azure Function

As part of the data processing layer of this demo, an Azure Function is provided as a notification endpoint to send updates on changes in supply and demand. The Function App, hosts the `notification_endpoint` HTTP function, which runs when an external HTTP request sends the product item and its quantity. For more information on how this fits in to the data processing architecture, refer to the [data ingestion walkthrough](../Data-ingestion-and-processing).

## Setup

The following instructions are a walkthrough of setting up an Azure Function with the provided demo code in this directory through the command line (cli).

### Prerequisites

* [Azure Subscription](https://azure.microsoft.com/free/?WT.mc_id=MSIgniteTheTour-github-dat10)
* [Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest&WT.mc_id=MSIgniteTheTour-github-dat10)
* [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2?WT.mc_id=MSIgniteTheTour-github-dat10)

### Instructions

```bash

# Function app and storage account names must be unique.

export azureFunctionRg="<AZURE-FUNCTION-RESOURCE-GROUP-NAME>"
export azureFunctionRegion="<AZURE-FUNCTION-REGION>"
export storageName="<AZURE-STORAGE-ACCOUNT-NAME>"
export functionAppName="<AZURE-FUNCTION-APP-NAME>"

az group create --name $azureFunctionRg --region $azureFunctionRegion

# Create a storage account for the function app
az storage account create \
  --name $storageName \
  --location $azureFunctionRegion \
  --resource-group $azureFunctionRg \
  --sku Standard_LRS

# Create a serverless function app in the resource group.
az functionapp create \
  --name $functionAppName \
  --storage-account $storageName \
  --consumption-plan-location $azureFunctionRegion \
  --resource-group $azureFunctionRg


# Go to the root directory of function code and publish function to funtion app
cd ThresholdEndpoint
func azure functionapp publish $functionAppName
  
```

Your function url will be `https://<functionappname>.azurewebsites.net/api/notification_endpoint`

## Teardown Instructions

The following command deletes the resource group and function app and its storage account has been created in it.

```bash
az group remove --name $azureFunctionRg
```
