# MIG50: Consolidating Infrastructure with Azure Kubernetes Service

This session demonstrates taking your containerized application and deploying it to Azure Kubernetes Service (AKS). You’ll walk away with a deep understanding of major Kubernetes concepts, how they translate to your app, and how to put it all to use with industry standard Kubernetes tooling. 

This repo contains the source code for running the session demos. See installation instructions below.

## Services Used

- Azure Kubernetes Service
- FrontDoor
- Cosmos DB

## Getting Started

We're assuming you are running this demo on a Mac OS X Machine. If you aren't, you'll need to change how you install the pre-requisites. Please see the linked documentation in each item for instructions on how to install it on your system.

### Prerequisites

#### CLIs

* [Homebrew](https://brew.sh/) - this is the CLI tool that we'll use to install the tools below
* The `az` CLI. See [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest&wt.mc_id=msignitethetour-github-mig50) for how to install it
* [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?wt.mc_id=msignitethetour-github-mig50). Install with the following:

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

### Step 1 - Building and Pushing Images to Azure

* Build the docker images in ACR with `make acrbuild`
    * This command builds all three images using ACR build tasks
    * You can see the built images using `az acr repository list -n $(acrname) -g $(rg)`

### Step 2 - Setup Azure Kubernetes Service

* Create an [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?WT.mc_id=msignitethetour-github-mig50) cluster with `make setup-kubernetes`
* Create a second [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?WT.mc_id=msignitethetour-github-mig50) cluster with `make setup-kubernetes2`

### Step 3 - Deploy

* Run `make helm` to deploy the images you created in step 1 to the first cluster
* Run `make helm2` to deploy the images you created in step 1 to the second cluster

### Step 4 - Load Balancing

* Run `make setup-fd` to deploy [Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor?wt.mc_id=msignitethetour-github-mig50)
