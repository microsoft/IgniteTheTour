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
git clone https://github.com/microsoft/ignitethetour

# This repo has the database schema scripts
git clone https://github.com/Azure-Samples/tailwind-traders
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
pushd ~/source/ignitethetour/SRE - Operating applications and infrastructure in the cloud/SRE40/setup

# edit the params to meet your needs
code 0-params.sh

# Set up the first demo environment
./setup.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file for each section of the `setup.sh` file.  e.g. ./2-database.log.

You can test that the application works by navigating to the Front End App Service URL that is output in the Azure Cloud Shell.

## Scaling Up
Now we have our starter environment set up. Let's look at how we may first consider scaling. Scaling up is often the first thing one would consider. The below GIF shows how to scale up our web app.

1. Navigate to the resource group for our project, this should be similar to `SRE40-app-berlin` and select your app service plan from the overview.
2. Click on 'Scale out (App Service Plan)' on the left hand pane
3. Select Production, and then select the P1v2 instance type. 
4. Note that this tier also gives up the ability to autoscale up to 20 underlying instances.
4. Hit 'Apply' and see the change take effect.
5. Once the change is completed. You can see this has taken effect from the portal by looking at the overview pane of our App Service Plan.
6. You may also check the updated SKU via the azure cli by typing: 
    `az appservice plan list -g [your-resource-group-name] --output json`
    
![Scaling Up](https://ignitethetour.blob.core.windows.net/assets/SRE40/scaling-up.gif)

## Scaling Out
Scaling out (adding more instances) gives us greater scale and flexibility, especially when we start doing it automatically. Let's look, first, at how you'd do this manually for App Service.

1. Navigate to the same `SRE40-app-berlin` resource group and again, select your App Service Plan.
2. Then select 'Scale out (App Service Plan)' in the left hand menu.
3. We're going to scale out from `1` to `2` underlying instances for our app service plan. Do this by moving the slider and clicking Save.
4. You can see the change has taken effect by looking at the Overview pane of our App Service Plan.
5. Again you could show that you can get the same results from the CLI by running:   
    `az appservice plan list -g [your-resource-group-name] --output json`  and looking at the `capacity` attribute.

![Scaling Out](https://ignitethetour.blob.core.windows.net/assets/SRE40/scaling-out.gif)

We could also scale out our app service plan using Infrastructure as code such as [Azure ARM Templates](https://docs.microsoft.com/en-us/azure/templates/?WT.mc_id=msignitethetour-github-sre40). In order to do so, we would simply update the `capacity` attribute in our template as per below:

<pre><code>
{
      "apiVersion": "2016-09-01",
      "name": "[variables('hostingPlanName')]",
      "type": "Microsoft.Web/serverfarms",
      "location": "[parameters('location')]",
      "properties": {
        "name": "[variables('hostingPlanName')]",
        "workerSizeId": "1",
        "reserved": true,
        "numberOfWorkers": 0,
        "hostingEnvironment": ""
      },
      "sku": {
        "Tier": "PremiumV2",
        "Name": "P1v2",
        <font color="red">"Capacity": <b>5</b></font>
      }
    } 
</code></pre>

## Autoscaling
Of course we really want our underlying App Service Plan to just scale automatically for us. Here's how we could configure that. 

1. Navigate to the same `SRE40-app-berlin` resource group and again, select your App Service Plan.
2. Then select 'Scale out (App Service Plan)' in the left hand menu.
3. Click on 'Enable Autoscaling'.
4. Give your scaling configuration a name.
5. Select 'Add a Rule'. We're going to scale based on memory so we'll configure the blade with
    - Time Aggregation: Average
    - Metric name: Memory
    - Leave the rest as default, it should be 10 minute duration for an average of 70% memory utilization and 5 minutes for scale down.
6. Click 'Add'
7. Change the instance limits to reflect our desired number of instances.
    - Minimum: 2
    - Maximum: 20
    - Default: 2  
8. Click Save.
9. You can confirm that your Autoscale setting have taken effect by running:  
`az monitor autoscale list -g [your-resource-group-name] --output json`

![Autoscale](https://ignitethetour.blob.core.windows.net/assets/SRE40/autoscale.gif)

## Teardown Instructions
To clean up our Azure account and remove the resources we have created during this walkthrough run the following commands in the Azure Cloud Shell. 

```
#remove the demo resource groups and their resources.
./cleanup.sh

#remove the directories from Cloud Shell.
rm ~/source/ignitethetour/SRE - Operating applications and infrastructure in the cloud/SRE40/setup/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/ignitethetour
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
pushd ~/source/ignitethetour/SRE - Operating applications and infrastructure in the cloud/SRE40/setup

# edit the params to meet your needs
code 0-global-params.sh

# Set up the first demo environment
./setup-global.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file for each section of the `setup-global.sh` file.  e.g. ./2-database.log.

You can test that both of the applications work by navigating to the Front End App Service URL that is output in the Azure Cloud Shell.

### Adding Azure Front Door
[Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor/?WT.mc_id=msignitethetour-github-sre40) gets us instant global failover and high availability. 

1. Search for 'Front Doors' to navigate to the service
2. Click 'Add' to create a front door
3. Under Basics
    1. Select your subscription
    2. Select your `SRE40-app-global-berlin` resource group that was created in the setup script.
    3. Click Next
4. In the Front Door Designer, click the + to add a frontend host
    1. This needs a globally unique name. You can use the same as your resource group. 
5. Click the + on step 2 to create the backend pool
    1. name: `lp5s4-backend-pool`
    2. Click on Add a backend
        1. Backend host type: `App Service`
        2. Select your primary region frontend app
        3. Leave the other settings as default
        4. Click 'Add'
    3. Repeat step 2 again to add another backend for your secondary front end
    4. Health Probe Path: /index.html
    5. Leave other settings as default and click 'Add'
6. Click the + on step 3, the routing rules section
    1. Basic Rule
    2. Name: `SRE40-routing-rule`
    3. Your frontend hosts and backend pool should match the two you just created.
    4. Leave the rest as default, we're going to match everything so `/*`
    5. CLick 'Add'
7. The Front Door will now be created. you can navigate the `http://[your-frontend-host-name].azurefd.net/index.html` to show that this is working
8. You can test the global resiliency is working, by stopping one of your Front End Applications and seeing that the Front Door URL is still returning content.

![GIF](https://ignitethetour.blob.core.windows.net/assets/SRE40/front-door.gif)

We could also add our Azure Front Door by using Infrastructure as code such as [Azure ARM Templates](https://docs.microsoft.com/en-us/azure/templates/?WT.mc_id=msignitethetour-github-sre40). In order to do so, we would aa a `Microsoft.Network/frontdoors` resource as per the below JSON.

```
{
    "apiVersion": "2018-08-01",
    "type": "Microsoft.Network/frontdoors",
    "name": "[parameters('resourceName')]",
    "location": "[parameters('location')]",
    "tags": {},
    "properties": {
        "friendlyName": "lp5s4frontendglobaldean",
        "enabledState": "Enabled",
        "healthProbeSettings": [
            {
                "name": "healthProbeSettings",
                "properties": {
                    "path": "/index.html",
                    "protocol": "Http",
                    "intervalInSeconds": 30
                },
                "id" : "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/healthProbeSettings/healthProbeSettings-1543520551538"
            }
        ],
        "loadBalancingSettings": [
            {
                "name": "loadBalancingSettings",
                "properties": {
                    "sampleSize": 4,
                    "successfulSamplesRequired": 2,
                    "additionalLatencyMilliseconds": 0
                },
                "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/loadBalancingSettings/loadBalancingSettings-1543520551538"
            }
        ],
        "frontendEndpoints": [
            {
                "name": "lp5s4frontendglobaldean-azurefd-net",
                "properties": {
                    "hostName": "lp5s4frontendglobaldean.azurefd.net",
                    "sessionAffinityEnabledState": "Disabled",
                    "sessionAffinityTtlSeconds": 0,
                    "webApplicationFirewallPolicyLink": null,
                    "customHttpsConfiguration": null
                },
                "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/frontendEndpoints/lp5s4frontendglobaldean-azurefd-net"
            }
        ],
        "backendPools": [
            {
                "name": "backendpoollp5s4",
                "properties": {
                    "backends": [
                        {
                            "address": "tw-frontend-lp5s4-dean-primary.azurewebsites.net",
                            "enabledState": "Enabled",
                            "httpPort": 80,
                            "httpsPort": 443,
                            "priority": 1,
                            "weight": 50,
                            "backendHostHeader": "tw-frontend-lp5s4-dean-primary.azurewebsites.net"
                        },
                        {
                            "address": "tw-frontend-lp5s4-dean-secondary.azurewebsites.net",
                            "enabledState": "Enabled",
                            "httpPort": 80,
                            "httpsPort": 443,
                            "priority": 1,
                            "weight": 50,
                            "backendHostHeader": "tw-frontend-lp5s4-dean-secondary.azurewebsites.net"
                        }
                    ],
                    "loadBalancingSettings": {
                        "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/loadBalancingSettings/loadBalancingSettings-1543520551538"
                    },
                    "healthProbeSettings": {
                        "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/healthProbeSettings/healthProbeSettings-1543520551538"
                    }
                },
                "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/backendPools/backendpoollp5s4"
            }
        ],
        "routingRules": [
            {
                "name": "lp5s4routingrule",
                "properties": {
                    "frontendEndpoints": [
                        {
                            "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/frontendEndpoints/lp5s4frontendglobaldean-azurefd-net"
                        }
                    ],
                    "acceptedProtocols": [
                        "Http",
                        "Https"
                    ],
                    "patternsToMatch": [
                        "/*"
                    ],
                    "customForwardingPath": null,
                    "forwardingProtocol": "MatchRequest",
                    "enabledState": "Enabled",
                    "backendPool": {
                        "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/backendPools/backendpoollp5s4"
                    },
                    "cacheConfiguration": null
                },
                "id": "/subscriptions/cd400f31-6f94-40ab-863a-673192a3c0d0/resourceGroups/lp5s4-app-global-dean/providers/Microsoft.Network/frontdoors/lp5s4frontendglobaldean/routingRules/lp5s4routingrule"
            }
        ]
    }
}
```

### Making CosmosDB Global
CosmosDB is the simplest way to get a global distributed managed database in the cloud.  

One thing to consider here is consistency. We are using Strong consistency for this example but be aware that this comes with performance trade offs. There is more detailed documentation available [here](https://docs.microsoft.com/en-us/azure/cosmos-db/consistency-levels-choosing?WT.mc_id=msignitethetour-github-sre40).

1. Navigate to your `SRE40-db-global-berlin` resource group
2. Select your Cosmos DB Account
3. Click on the image of the Map
4. Select the West Europe region on the map
5. Click Save
6. Your data will now be replicated,
**NOTE IT WILL TAKE SOME TIME FOR THIS TO TAKE EFFECT, BECAUSE IT IS REPLICATING DATA**

![GIF](https://ignitethetour.blob.core.windows.net/assets/SRE40/global-cosmos.gif)

We could also add CosmosDB replication using Infrastructure as code such as [Azure ARM Templates](https://docs.microsoft.com/en-us/azure/templates/?WT.mc_id=msignitethetour-github-sre40). In order to do so, we would simply add an additional `location` to the `locations` array in our `Microsoft.DocumentDB/databaseAccounts` resource as per below:

<pre><code>
{
      "apiVersion": "2015-04-08",
      "type": "Microsoft.DocumentDB/databaseAccounts",
      "name": "[parameters('databaseAccountName')]",
      "location": "[parameters('location')]",
      "properties": {
        "name": "[parameters('databaseAccountName')]",
        "databaseAccountOfferType": "[variables('offerType')]",
        "consistencyPolicy": {
          "defaultConsistencyLevel": "strong"
        },
        "locations": [
          {
            "locationName": "[parameters('location')]",
            "failoverPriority": 0
          }<font color="red">,
          {
            "locationName": "[parameters('secondaryLocation')]",
            "failoverPriority": 1
          }</font>
        ]
      }
    }
</code></pre>

### Teardown Instructions
To clean up our Azure account and remove the resources we have created during this walkthrough run the following commands in the Azure Cloud Shell. 

```
#remove the demo resource groups and their resources.
./cleanup-global.sh

#remove the directories from Cloud Shell.
rm ~/source/ignitethetour/SRE - Operating applications and infrastructure in the cloud/SRE40/setup/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/ignitethetour
```
