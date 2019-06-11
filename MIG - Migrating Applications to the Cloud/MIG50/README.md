**Note: this repo gets sync'd to https://github.com/Microsoft/IgniteTheTour/tree/master/MIG%20-%20Migrating%20Applications%20to%20the%20Cloud/MIG50**

# MIG50: Consolidating Infrastructure with Azure Kubernetes Service (AKS)

This session demonstrates taking your containerized application and deploying it to [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?WT.mc_id=msignitethetour-github-mig50) (AKS). You’ll walk away with a deep understanding of major Kubernetes concepts, how they translate to your app, and how to put it all to use with industry standard Kubernetes tooling. 

This repo contains the source code for running the session demos. See installation instructions below.

## Getting Started

We're assuming you are running this demo on a macOS Machine. If you aren't, you'll need to change how you install the pre-requisites. Please see the linked documentation in each item for instructions on how to install it on your system.

### Prerequisites

#### CLIs
* A local Docker daemon and properly configured `docker` CLI. See [here](https://docs.docker.com/docker-for-mac/) for installation instructions

* Xcode - Available in the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)

  * Needed for mongodb and postgres install

* [Homebrew](https://brew.sh/) - this is the first CLI tool that we'll use to install the tools below
  
  To install homebrew, run the following command:
   `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
`
* To quickly get started with all pre-requisite tools you need to run the demo, you may run the following command after installing Homebrew and Xcode:
  `brew bundle`

* If you prefer to install the pre-requisite tools manually, you may run the following commands:
  
  * The `az` CLI. See [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest&wt.mc_id=msignitethetour-github-mig50) for how to install it or you can install with the following:
  ```console
    $ brew update && brew install azure-cli
    ```
  * [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?wt.mc_id=msignitethetour-github-mig50). Install with the following:

    ```console
    $ brew tap azure/functions
    $ brew update && brew install azure-functions-core-tools
    ```
  * The [`jq`](https://stedolan.github.io/jq/) tool. Install with the following:

    ```console
    $ brew update && brew install jq
    ```
  * The `kubectx` binary. See [here](https://github.com/ahmetb/kubectx) for how to install it or you can install with the following:
  ```console
    $ brew update && brew install kubectx
    ```
  * [MongoDB](https://www.mongodb.com/) to enable data to be uploaded into Cosmos DB. Install with the following:
    ```console
    $ brew update && brew install mongo
    ```
    NOTE: You may need to install Xcode for mongo install to succeed. Installing just the Command Line Tools is not sufficient.

  * The `psql` tool for seeding PostgreSQL data. To install it, run:
    ```console
    $ brew update && brew install postgresql
    ```

#### Environment Variables

All the variables that control resource naming are in `scripts/variables.sh`.

The `base` variable is added to many of the others to name things.  

The default resource group name is `base` + `the username part of your az login`, 
eg: `mig50brketels` for the Azure user `brketels@microsoft.com`

## Setup & Teardown

Before you run any of the below demos, change the necessary variables in the `scripts/variables.sh` file and then run:
`make demo`

The above single command will stand up the following Azure resources:
* 2 RGs
* 1 ACR
* CosmosDB
* Keyvault
* Azure Database for PostgreSQL server
* 2 AKS clusters with helm (Tiller) support
* deploys the helm releases for frontend, product and inventory to both clusters
* creates an Azure Frontdoor. 

The entire deployment will take between 45-60 minutes. 

If you prefer to setup the demo requirements individually, you can use the below commands as they are listed in order. (This is OPTIONAL and only needs to be run if you choose to _NOT_ run or have an error with: `make demo`.)

```console
$ make setup
$ make secrets
$ export KUBECONFIG=~/.kube/config
$ make setup-kubernetes
$ make setup-kubernetes2
$ make acrbuild
$ make helm
$ make helm2
$ make setup-fd
```

If you've run this demo before, make sure to reset your demo environment (restore the previously deleted frontend release on AKS cluster2) with:
```console
$ make resest-demo
```

Note: By default, when you run `make delete-one-helm-frontend` you will take down `frontend-frontend` on AKS Cluster2. `make reset-demo` will redeploy the helm chart for frontend on Cluster2 (westus) only.

If you need to reinstall all three helm packages (frontend, inventory, and product) you can use `make helm` for cluster1 (eastus) and `make helm2` for cluster2 (westus2).

If you need to delete _everything_ at any time (including at the end), run:

```console
$ make teardown
```
This will delete all the resources you've created and will also remove `mig50` and `mig502` from your `~/.kube/config` file.

### Demo Script

It is recommended you use a tool like [Keyboard Maestro](https://www.keyboardmaestro.com/main/) to store keyboard shortcuts for your demo. My shortcuts are below:

```
^1: make helm:
    - az account set --subscription "Ignite the Tour"
    - kubectx mig50
    - make helm
^2: k get pods:
    - kubectl get pods
^3: k get ingress:
    - kubectl get ingress
^4: make setup frontdoor
    - make setup-fd
^5: make helm front-door
    - make helm-reinstall-frontend
^6: make delete one front end
    - make delete-one-helm-frontend
^7: helm rollback frontend 
    - make helm-rollback-frontend
```
### Videos

Recorded Train-The-Trainer session *[here](https://msit.microsoftstream.com/video/9125c4d0-18cb-4f68-a3d2-a90e93ec0647)*
* Note: The recommended demo order is to delete one frontend, show Front Door in action, and then show the power of Helm rollback (and end on that note). However, you can really demo either way, depending on comfort level (just remember to reset the demo accordingly.) This video shows a demo with helm rollback and _then_ helm-delete-frontend.

Individual recording of stage-ready hands-on demo *[here](https://msit.microsoftstream.com/video/4c2d78f9-c32e-4f08-b1a1-b49c3fc62ab7)*
* This video shows the recommended demo with helm-delete-one-frontend and _then_ helm rollback.

### [OPTIONAL] Demo 0 - Building and Pushing Images to Azure (Think about the value, time may be better spent focusing on the next demos)

Build the docker images in ACR:

```console
$ make acrbuild
```

This command builds all three images using ACR build tasks. You can see the built images using:

```console
$ make acrlist
```

### Demo 1 - Helm Deployment

To deploy the app to the first AKS cluster, run:

```console
$ make helm
```

>Note: in the setup, you already deployed the app to the second AKS cluster with the `make helm2` command.

Now that the components are installed, let's look at a few of the resources that were installed.

First, run this to see the newly created pods:

```console
make list-pods
```
You could also use `^2` if you setup Keyboard Maestro using the above suggested keystrokes.

Next, run this to see the newly created ingress resources:

```console
$ make get-ingresses
```
You could also use `^3` if you setup Keyboard Maestro using the above suggested keystrokes.

Notice that these ingress resources come with host-names - very cool!

Let's open the one that has the `frontend-frontend` prefix in the browser. That will show the familiar running Tailwind inventory app, being served in AKS!

### Demo 2 - Azure Front Door Basics

First, create the Azure Front Door instance:

```console
$ make setup-fd
```
You could also use `^4` if you setup Keyboard Maestro using the above suggested keystrokes.

Then, you'll be able to see the Front Door instance in the Azure portal.

>Note: you already did this in the setup section because it takes some time for DNS to propagate. We're also doing it here to illustrate that this is a logical next step.

When you're done, go to the [Front Doors section of the Azure portal](https://ms.portal.azure.com/#blade/HubsExtension/Resources/resourceType/Microsoft.Network%2Ffrontdoors) to see the new instance.

#### Why Doesn't the App Work?

If you try to access the Tailwind application via the Azure Front Door URL, you'll notice that the static frontend app loads, but there's no data. Oh no!

Let's explain why. First, when the static frontend loads in the browser, it tries to make API requests to get data from the ingress URLs from demo 2.

But the website loads from a _different URL_ than the API requests - it loads from the Front Door domain, and makes requests to the `frontend-frontend` domain from demo 2.

That difference violates the the [same origin policy](https://en.wikipedia.org/wiki/Same-origin_policy) that browsers implement, so the API calls fail.

We'll see how to solve this in the next demo.

### Demo 3 - Deploy the Multi-Region AKS Cluster with Front Door

First, configure the frontends to talk to the backends via the Front Door endpoint. This command will reconfigure the frontend to make backend API requests to the Azure Front Door URL:

```console
$ make helm-reinstall-frontend
```
You could also use `^5` if you setup Keyboard Maestro using the above suggested keystrokes.

Next, delete one of the frontends:

```console
$ make delete-one-helm-frontend
```
You could also use `^6` if you setup Keyboard Maestro using the above suggested keystrokes.

Finally, look at the Front Door instance in the Azure portal. Watch the health checks and notice that one of the frontend instances should start failing.

After that happens, all frontend traffic will be routed to the other, healthy AKS frontend.

Next, let's see another way Helm as a package manager works - it allows us to roll back to a previous release.

```console
$ make helm-rollback-frontend
```
You could also use `^7` if you setup Keyboard Maestro using the above suggested keystrokes.

You'll notice once you roll back, the front door application won't show data anymore, but the frontend you did not delete will properly show data again because the `producturl=` and `inventoryurl=` values have been reverted back to hardcoded FQDNs.

### Tips
If you want to see as TXT and A records are autoprovisioned through the initial helm release of frontend, you can view the logs of the application http routing external dns pod by typing the following:

```console
k logs -n kube-system addon-http-application-routing-external-dns-
```
Use `tab` to autocomplete the remaining pod numbers. 

If you use bash, you can add the following to your .zshrc to enable autocomplete for Kubectl:

`source <(kubectl completion bash)`

If you use zsh, you can add the following to your .zshrc to enable autocomplete for Kubectl:

`source <(kubectl completion zsh)`

E.g:
```console
time="2019-06-07T23:34:33Z" level=info msg="Updating TXT record named 'inventory-inventory' to '"heritage=external-dns,external-dns/owner=default"' for Azure DNS zone 'c3254caa633f4e479080.westus2.aksapp.io'."
time="2019-06-07T23:34:34Z" level=info msg="Updating TXT record named 'product-product' to '"heritage=external-dns,external-dns/owner=default"' for Azure DNS zone 'c3254caa633f4e479080.westus2.aksapp.io'."
```

A bonus video of the above Helm and TXT record creation is [here](https://msit.microsoftstream.com/video/6ab17804-c679-4a68-9cf2-5b6f8da1bd42)