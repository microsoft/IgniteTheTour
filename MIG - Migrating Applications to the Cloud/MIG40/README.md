**Note: this repo gets sync'd to https://github.com/Microsoft/IgniteTheTour/tree/master/MIG%20-%20Migrating%20Applications%20to%20the%20Cloud/MIG40**

# MIG40: Optimizing your app's infrastructure for new cloud options

This session demonstrates how to move your application off a VM and into containers in the cloud, where you’ll gain deployment flexibility and repeatable builds.  You’ll then learn how to move your application secrets into Azure KeyVault, where you’ll have fine-grained control over your keys, secrets, and policies. Finally, you’ll see how to move scheduled tasks into the Serverless era with Azure Functions.

This repo contains the source code for running the session demos. See installation instructions below.

## Getting Started

We're assuming you are running this demo on a Mac OS X Machine. If you aren't, you'll need to change how you install the pre-requisites. Please see the linked documentation in each item for instructions on how to install it on your system.

### Prerequisites

#### CLIs

* [Homebrew](https://brew.sh/) - this is the CLI tool that we'll use to install the tools below
* The `az` CLI. See [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest&wt.mc_id=msignitethetour-github-mig40) for how to install it
* [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?wt.mc_id=msignitethetour-github-mig40). Install with the following:

```console
$ brew tap azure/functions
$ brew install azure-functions-core-tools
```

* The [`jq`](https://stedolan.github.io/jq/) tool. Install with the following:

```console
brew install jq
```

* A local Docker daemon and properly configured `docker` CLI. See [here](https://docs.docker.com/docker-for-mac/) for installation instructions

#### Sendgrid

The 4th demo (to create reports with [Azure Functions](https://azure.microsoft.com/en-us/services/functions/?WT.mc_id=msignitethetour-github-mig40)) uses SendGrid to send out emails. If you don't already have a Sendgrid account, you'll need to [open one](https://sendgrid.com/) under the "free tier". Once you have one:

* Create a [new API key](https://app.sendgrid.com/settings/api_keys) with "Full Access" and set it in an environment variable called `SENDGRID_API_KEY`
* Create a new [transactional template](https://sendgrid.com/dynamic_templates) in "code" mode:
    * Name it whatever you like
    * Copy the contents of [./src/reports/SENDGRID_TEMPLATE.html](./src/reports/SENDGRID_TEMPLATE.html) into the template code
    * Set the template ID into an environment variable called `SENDGRID_TEMPLATE_ID`

Because these environment variables are specific to your account, they won't be automatically created or set in the `Makefile`. [direnv](https://direnv.net/) is a great tool to store and inject them into your shell for you. If you do use `direnv`, copy the [./envrc.example](./envrc.example) file into an `.envrc` to get started.

#### Environment Variables

All the variables that control resource naming are in `scripts/variables.sh`.

The `base` variable is added to many of the others to name things.  

The default resource group name is `base` + `the username part of your az login`, 
eg: `mig50brketels` for the Azure user `brketels@microsoft.com`

All of the scripts to setup, configure, and tear down the demo are wrapped in the `make setup` target to execute them.

If you want to run any of the scripts individually, source the `scripts/variables.sh` file first:

```console
$ source ./scripts/variables.sh
$ ./scripts/up/secrets.sh
```

## Setup & Teardown

Before you run any of the below demos, run:

```console
$ make setup
```

If you need to delete everything at any time (including at the end), run:

```console
$ make teardown
```

This will delete all the resources you've created.

### Demo 1 - Building and Pushing Images to Azure

#### 1.1 - Log in to ACR

Log in to [Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/services/container-registry?WT.mc_id=msignitethetour-github-mig40) with:

```console
$ make login
```

#### 1.2 - Build Docker Images Locally

Then, build the Docker images locally with:

```console
$ make docker-frontend docker-inventory docker-product
```

This command runs three targets, which will build images for the frontend, inventory service and product service

After it finishes, you can run:

```console
$ docker images
```

You'll see the images you just build. They will be prefixed with `twt-`

#### 1.3 - Build Docker Images in ACR

Build the docker images in ACR with:

```console
$ make acrbuild
```
This command builds all three images using [ACR tasks](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task).

You can see the built images with:

```console
$ make acrlist
```

### Demo 2 - Deploying to App Service for Linux

#### 2.1 - Deploy Images

Run the following to deploy the images you created in Demo 1 to App Service:

```console
$ make deploy
```

This command will create and configure 3 new apps in [Azure App Service for Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-intro?wt.mc_id=msignitethetour-github-mig40), and then show the preliminary logs.

After you see preliminary logs, the script will start tailing logs for the frontend service. When you see this, you can close the logs at any time with `ctrl+C`.

After you do that, the script will open the frontend service in your browser (using the Mac/Linux `open` CLI).

When you view the frontend in the browser, you'll see that products are being shown, so it's successfully communicating with the products service. **But inventory data is not showing up!**

The inventory service isn't running because it can't connect to the database, and it can't connect to the database because _we accidentally hard-coded the wrong DB connection string in the `scripts/up/deploy.sh` script_.

Let's fix that in the next demo.

### Demo 3 - Securely Deploying to App Service for Linux

#### 3.1 - Store Credentials

Run:

```console
$ make secrets
```

To store your credentials into [Azure KeyVault](https://azure.microsoft.com/en-us/services/key-vault?WT.mc_id=msignitethetour-github-mig40)

#### 3.2 - Deploy App with Secure Credentials

Run:

```console
$ make deploy-secure
```

To deploy the images you created in demo 1 to App Service. This command will create and configure 3 new apps in [Azure App Service for Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-intro?wt.mc_id=msignitethetour-github-mig40) and then show the preliminary logs.

After you see preliminary logs, the script will start tailing logs for the frontend service. When you see this, you can close the logs at any time with `ctrl+C`.

After you do that, the script will open the frontend service in your browser (using the Mac/Linux `open` CLI)

### Demo 4 - Running the Serverless Reports Generator

#### Option 1 - Run the Function in the Cloud

If you want to run the function in the cloud, run:

```console
$ make funcdeploy
```

This script will deploy the function to Azure with the timer trigger set to run every 24 hours. After the deploy, it will `curl` the function's URL to immediately instantiate the function. Shortly after the `curl`, you should get the report email.

#### Option 2 - Run the Function Locally:

If you'd rather run the function locally, run:

```console
$ make funcdeploy-local
```

This script will use the `func` tool to host the function in the local development environment. The function will be launched on the same 24 hour trigger. Follow the instructions in the script to `curl` a local URL in order to immediately instantiate the function.

Check out https://www.youtube.com/watch?v=3mp8AU88TSc for a full end-to-end demo of this working.

#### More Details

See [./src/reports/README.md](./src/reports/README.md) for details on how to run this demo.
