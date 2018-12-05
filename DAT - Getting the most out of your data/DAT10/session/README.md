# Dealing with a Massive Onset of Data Ingestion

How does a large company like Tailwind Traders build their data ingestion and processing pipelines, and chooses appropriate technologies to drive their business forward? This repo solves this problem by building a scalable and flexible end-to-end architecture that is capable of receiving massive amounts of data from variety of sources in real-time, and processing it.

## What's Inside

This repo contains instructions and code to recreate the demo in the Microsoft Ignite | The Tour session titled _Dealing with a Massive Onset of Data Ingestion_.  

## Azure Services Used

- Event Hubs
- IoT Hub
- Cosmos DB
- Azure Databricks
- Azure Blob Storage
- Azure Functions

## Prerequisites

* [Azure Subscription](https://azure.microsoft.com/free/?WT.mc_id=MSIgniteTheTour-github-dat10)
* [Docker](https://docs.docker.com/install/)
* [Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest&WT.mc_id=MSIgniteTheTour-github-dat10)
* [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2?WT.mc_id=MSIgniteTheTour-github-dat10)
* [Python 2.7x OR Python 3.x](https://www.python.org/downloads/)

## Instructions

1. Create the cash register data generator with the following instructions found [here](DataGenerator/)
2. Create the data ingestion layer with the following instructions found [here](Data-ingestion-and-processing/)

## Learn More/Resources

[IoT Hub](https://docs.microsoft.com/en-us/azure/iot-hub/about-iot-hub?WT.mc_id=MSIgniteTheTour-github-dat10)

[Microsoft Learn: Enable reliable messaging for Big Data applications using Azure Event Hubs](https://docs.microsoft.com/en-us/learn/modules/enable-reliable-messaging-for-big-data-apps-using-event-hubs/index?WT.mc_id=MSIgniteTheTour-github-dat10)

[Azure Databricks](https://docs.microsoft.com/en-us/azure/azure-databricks/?WT.mc_id=MSIgniteTheTour-github-dat10)

[Azure-IoT-Edge-Bogus-Data-Generator](http://aka.ms/iotdatagenerator)

[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/?WT.mc_id=MSIgniteTheTour-github-dat10)

[Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/?WT.mc_id=MSIgniteTheTour-github-dat10)
