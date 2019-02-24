**Note: this repo gets sync'd to https://github.com/Microsoft/IgniteTheTour/tree/master/MIG%20-%20Migrating%20Applications%20to%20the%20Cloud/MIG50**

# MIG50: Gain Higher Availability with Azure Kubernetes Service (AKS)

This session demonstrates taking your containerized application and deploying it to [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?WT.mc_id=msignitethetour-github-mig50) (AKS). You’ll walk away with a deep understanding of major Kubernetes concepts, how they translate to your app, and how to put it all to use with industry standard Kubernetes tooling. 

This repo contains the source code for running the session demos. See installation instructions below.

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
    $ brew install jq
    ```
* A local Docker daemon and properly configured `docker` CLI. See [here](https://docs.docker.com/docker-for-mac/) for installation instructions
* [MongoDB](https://www.mongodb.com/) to enable data to be uploaded into Cosmos DB. Install with the following:
    ```console
    $ brew install mongo
    ```
* The `psql` tool for seeding PostgreSQL data. To install it, run:
    ```console
    $ brew install postgresql
    ```

#### Environment Variables

All the variables that control resource naming are in `scripts/variables.sh`.

The `base` variable is added to many of the others to name things.  

The default resource group name is `base` + `the username part of your az login`, 
eg: `mig50brketels` for the Azure user `brketels@microsoft.com`

## Setup & Teardown

Before you run any of the below demos, run:

```console
$ make setup
$ make secrets
$ export KUBECONFIG=`pwd`/.kubeconfig
$ make setup-kubernetes
$ make setup-kubernetes2
$ make acrbuild
$ make secrets
$ make helm2
$ make setup-fd
```

If you've run this demo before, make sure to clean up the helm deployments with:

```console
$ make delete-helm-frontend delete-helm-product delete-helm-inventory
```

If you need to delete everything at any time (including at the end), run:

```console
$ make teardown
```

This will delete all the resources you've created.

### Demo 1 - Building and Pushing Images to Azure

Build the docker images in ACR:

```console
$ make acrbuild
```

This command builds all three images using ACR build tasks. You can see the built images using:

```console
$ make acrlist
```

### Demo 2 - Helm Deployment

To deploy the app to the first AKS cluster, run:

```console
$ make helm
```

>Note: in the setup, you already deployed the app to the second AKS cluster.

Now that the components are installed, let's look at a few of the resources that were installed.

First, run this to see the newly created pods:

```console
make list-pods
```

Next, run this to see the newly created ingress resources:

```console
$ make get-ingresses
```

Notice that these ingress resources come with host-names - very cool!

Let's open the one that has the `frontend-frontend` prefix in the browser. That will show the familiar running Tailwind inventory app, being served in AKS!

### Demo 3 - Azure Front Door Basics

First, create the Azure Front Door instance:

```console
$ make setup-fd
```

Then, you'll be able to see the Front Door instance in the Azure portal.

>Note: you already did this in the setup section because it takes some time for DNS to propagate. We're also doing it here to illustrate that this is a logical next step

When you're done, go to the [Front Doors section of the Azure portal](https://ms.portal.azure.com/#blade/HubsExtension/Resources/resourceType/Microsoft.Network%2Ffrontdoors) to see the new instance.

#### Why Doesn't the App Work?

If you try to access the Tailwind application via the Azure Front Door URL, you'll notice that the static frontend app loads, but there's no data. Oh no!

Let's explain why. First, when the static frontend loads in the browser, it tries to make API requests to get data from the ingress URLs from demo 2.

But the website loads from a _different URL_ than the API requests - it loads from the Front Door domain, and makes requests to the `frontend-frontend` domain from demo 2.

That difference violates the the [same origin policy](https://en.wikipedia.org/wiki/Same-origin_policy) that browsers implement, so the API calls fail.

We'll see how to solve this in the next demo.

### Demo 4 - Deploy the Multi-Region AKS Cluster with Front Door

First, configure the frontends to talk to the backends via the Front Door endpoint. This command will reconfigure the frontend to make backend API requests to the Azure Front Door URL:

```console
$ make helm-reinstall-frontend
```

Next, delete one of the frontends:

```console
$ make delete-one-helm-frontend
```

Finally, look at the Front Door instance in the Azure portal. Watch the health checks and notice that one of the frontend instances should start failing.

After that happens, all frontend traffic will be routed to the other, healthy AKS frontend.
