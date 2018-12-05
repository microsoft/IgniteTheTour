# SRE40 - Scaling for Growth and Resiliency 

Tailwind Traders has realized that it will need to focus on scaling their application and infrastructure to both handle more traffic than originally expected as well as increase resiliency in the case of failures. Their business demands reliability, so we'll explore how Azure products can help with delivering it.

In this module, you will learn about scaling our application and infrastructure for increased loads as well as how to distribute workloads with Azure Front Door and Azure Availability Zones to protect against localized failures

## Author

Dean Bryen | dean.bryen@microsoft.com | [@deanbryen](https://twitter.com/deanbryen)

## How To Use

## Setup Instructions 
All Instructions have been tried and tested in [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview?WT.mc_id=msignitethetour-github-sre40) It is recommended that you run the setup from there. 

### Obtaining the source code
```
mkdir ~/source
pushd ~/source

# Clone this repository first
git clone https://dev.azure.com/ignite-tour-lp5/ignite-tour-lp5-s4/_git/ignite-tour-lp5-s4-public

# This repo has the database schema scripts
git clone https://github.com/Azure-Samples/tailwind-traders
```

## Building the starter environment for Resiliency
First, we need to build our base application. We'll make it eventually look like the following diagram, but for now it comprises of the below. **You'll see there are a few things in the diagram, that we don't have listed below. that's what we're going to walkthrough here.**

### North Europe
- Azure app Service Plan (Basic Tier, Single B1 Instance)
    -   Node.js Front End Application
    -   .NET Core Inventory Application
    -   Node.js Product Application
- Azure SQL DB (Inventory DB)
- Azure CosmosDB (Product Catalog - MongoDB)

### West Europe
- Azure app Service Plan (Basic Tier, Single B1 Instance)
    -   Node.js Front End Application
    -   .NET Core Inventory Application
    -   Node.js Product Application
- Azure SQL DB (Inventory DB) - Read Replica Geo Replicated from North Europe instance


![Architecture](https://ignitethetour.blob.core.windows.net/assets/SRE40/global_architecture.png)

This repository provides some [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest?WT.mc_id=msignitethetour-github-sre40) scripts to get this starter environment setup. Follow the steps below to build the environment:

```
pushd ./ignite-tour-lp5-s4-public/setup

# edit the params to meet your needs
code 0-global-params.sh

# Set up the first demo environment
./setup-global.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file for each section of the `setup-global.sh` file.  e.g. ./2-database.log.

You can test that both of the applications work by navigating to the Front End App Service URL that is output in the Azure Cloud Shell.

### Teardown Instructions
To clean up our Azure account and remove the resources we have created during this walkthrough run the following commands in the Azure Cloud Shell. 

```
#remove the demo resource groups and their resources.
./cleanup-global.sh

#remove the directories from Cloud Shell.
rm ~/source/ignite-tour-lp5-s4-public/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/ignite-tour-lp5-s4-public/
```

### Building the starter environment for Scaling
First, we need to build our base application. This looks like the following diagram. and comprises of:

- Azure app Service Plan (Basic Tier, Single B1 Instance)
    -   Node.js Front End Application
    -   .NET Core Inventory Application
    -   Node.js Product Application
- Azure SQL DB (Inventory DB)
- Azure CosmosDB (Product Catalog - MongoDB)

![Architecture](https://ignitethetour.blob.core.windows.net/assets/SRE40/architecture.png)

This repository provides some [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest?WT.mc_id=msignitethetour-github-sre40) scripts to get this starter environment setup. Follow the steps below to build the environment:

```
pushd ./ignite-tour-lp5-s4-public/setup

# edit the params to meet your needs
code 0-params.sh

# Set up the first demo environment
./setup.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file for each section of the `setup.sh` file.  e.g. ./2-database.log.

You can test that the application works by navigating to the Front End App Service URL that is output in the Azure Cloud Shell.

## Teardown Instructions
To clean up our Azure account and remove the resources we have created during this walkthrough run the following commands in the Azure Cloud Shell. 

```
#remove the demo resource groups and their resources.
./cleanup.sh

#remove the directories from Cloud Shell.
rm ~/source/ignite-tour-lp5-s4-public/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/ignite-tour-lp5-s4-public/
```
