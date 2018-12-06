# MIG40: Modernizing your Application with Containers and Serverless

This session demonstrates how to move your application off a VM and into containers in the cloud, where you’ll gain deployment flexibility and repeatable builds.  You’ll then learn how to move your application secrets into Azure KeyVault, where you’ll have fine-grained control over your keys, secrets, and policies. Finally, you’ll see how to move scheduled tasks into the Serverless era with Azure Functions.

This repo contains the source code for running the session demos. See installation instructions below.

## Services Used

- Migrate web application from a VM to Azure Web App for Containers
- Store app secrets in Azure KeyVault
- Using Serverless functions for scheduled tasks

## Getting Started

We're assuming you are running this demo on a Mac OS X Machine. If you aren't, you'll need to change how you install the pre-requisites. Please see the linked documentation in each item for instructions on how to install it on your system.

### Prerequisites

#### CLIs

* [Homebrew](https://brew.sh/) - this is the CLI tool that we'll use to install the tools below
* The `az` CLI. See [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest&wt.mc_id=msignitethetour-github-mig40) for how to install it
* [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?wt.mc_id=msignitethetour-github-mig40). Install with the following:

    ```console
    brew tap azure/functions
    brew install azure-functions-core-tools
    ```
* The [`jq`](https://stedolan.github.io/jq/) tool. Install with the following:

    ```console
    brew install jq
    ```
* A local Docker daemon and properly configured `docker` CLI. See [here](https://docs.docker.com/docker-for-mac/) for installation instructions

#### Environment Variables

All the variables that control resource naming are in `scripts/variables.sh`.

The `base` variable is added to many of the others to name things.  

The default resource group name is `base` + `the username part of your az login`, 
eg: `mig50brketels` for the Azure user `brketels@microsoft.com`

All of the scripts to setup, configure, and tear down the demo are wrapped in a
Makefile with easy targets grouping them:
```make setup```

To run any of the scripts individually, source the scripts/variables.sh file first:
``` source ./scripts/variables.sh && ./scripts/up/secrets.sh```


Before you run any of the below demos, run `make setup`. If you need to delete everything at any time (including at the end), run `make teardown`. This will delete all the resources you've created.
## Setup

* Create the resources, databases, etc with `make setup`

### Demo 1 - Building and Pushing Images to Azure

* Log in to [Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/services/container-registry?WT.mc_id=msignitethetour-github-mig40) with `make login`
* Build the docker images locally with `make docker-frontend docker-inventory docker-product`
    * This command runs three targets, which will build images for the frontend, inventory service and product service
    * After it finishes, you can run `docker images` and see the three images that you just built. They'll be prefixed with `twt-`
* Build the docker images in ACR with `make acrbuild`
    * This command builds all three images using ACR build tasks
    * You can see the built images using `az acr repository list -n $(acrname) -g $(rg)`

### Demo 2 - Deploying to App Service for Linux

* Run `make deploy` to deploy the images you created in demo 1 to App Service
    * This command will create and configure 3 new apps in [Azure App Service for Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-intro?wt.mc_id=msignitethetour-github-mig40), and then show the preliminary logs
    * After you see preliminary logs, the script will start tailing logs for the frontend service. When you see this, you can close the logs at any time with `ctrl+C`
    * After you do that, the script will open the frontend service in your browser (using the Mac/Linux `open` CLI)

### Demo 3 - Securely Deploying to App Service for Linux

* Run `make secrets` to store your credentials into [Azure KeyVault](https://azure.microsoft.com/en-us/services/key-vault?WT.mc_id=msignitethetour-github-mig40)

* Run `make deploy-secure` to deploy the images you created in demo 1 to App Service
    * This command will create and configure 3 new apps in [Azure App Service for Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-intro?wt.mc_id=msignitethetour-github-mig40), and then show the preliminary logs
    * After you see preliminary logs, the script will start tailing logs for the frontend service. When you see this, you can close the logs at any time with `ctrl+C`
    * After you do that, the script will open the frontend service in your browser (using the Mac/Linux `open` CLI)

