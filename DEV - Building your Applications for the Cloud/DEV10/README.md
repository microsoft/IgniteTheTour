# DEV10: Designing Resilient Cloud Applications

![Build status](https://dev.azure.com/devrel/Ignite-Tour-LP1S1/_apis/build/status/LP1S1%20Build)

This session introduces Tailwind Traders and the application that you'll see in other demos in this tour. You'll also learn about how to build resilient cloud applications at global scale that will withstand failures in sections.

## Source code

This repo contains these parts of the Tailwind Traders application. 

* Frontend
* Product Service
* Inventory Service
* Report Service

> This is the most up to date version of these services. Other sessions may use this code directly or its derivatives.


## Services Used

* Azure App Service - Web App for Containers
* Azure Key Vault
* Azure SQL Database, Azure Database for PostgreSQL
* Azure Cosmos DB
* Azure Front Door
* Azure Container Registry

  
## Deployment

### Main resources

There is an automated script that will deploy a resource group, plus the Frontend, and Inventory and Product services.

#### Prerequisites

* Azure CLI (logged in and subscription selected)
* Bash (if in WSL, ensure files do not have Windows line endings)

#### Deployment

Set three environment variables: 

RESOURCE_GROUP_NAME

RESOURCE_PREFIX

SQL_ADMIN_PASSWORD


Change into the `deployment` directory and run `deploy.sh`.

##### Deployment Tips

-Review the [minimum password requirements](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-2017) for SQL_ADMIN_PASSWORD 

-For best results, run the deployment script from Azure cloud shell:

Go to https://shell.azure.com/
type 
`git clone https://github.com/microsoft/IgniteTheTour.git`

Navigate to the `/DEV - Building your Applications for the Cloud/DEV10/deployment` directory (Type `code .` to see the directory structure)
Type `./deploy.sh`

If you get this message:

`$'\r': command not found`

Run this command to convert carriage returns:
 
`sed -i 's/\r$//' deploy.sh`



## Train the Trainer content

### Session Abstract

Building a resilient application means leaning on the distributed nature of the cloud. In this talk, we’ll show you how Tailwind Traders reduced single point of failure by deploying backend services to multiple regions using Azure App Service and Azure Traffic Manager. We’ll then create a CDN using Azure Blob Storage to deliver static assets such as images and frontend code. Finally, we’ll deploy our data with full geo-redundancy using Cosmos DB and Azure SQL Database. 

Once we’ve set everything up, we’ll test it out and see how our application handles, and recovers from, catastrophic failure.

### Session Story Summary

Tailwind Traders is a global company that requires its applications to be accessible worldwide and be resilient to failures.

#### Introduction

Tailwind Traders is has an inventory management application that is comprised of a single page application frontend, and two backend services for managing product and inventory data. We'll look at how the different parts of the application interact with each other, and how we leverage services in Azure to make the app resilient.

> Note: We will now talk about a few different Azure services. Make sure we tie each back to how they make it easy to build an application that is distributed and resilient.

#### Azure Key Vault

Azure Key Vault provides a centralized service for managing secrets for applications. Instead of passing secrets around in emails and messaging apps, secrets can be placed in Azure Key Vault by an administrator, and access to the secrets can be given to identities in Azure Active Directory such as users or applications. As secrets or access permissions change, we can modify them in Key Vault.

Azure Key Vault still requires the application to have a single secret: an AAD identity that it will use to access Key Vault. There is a feature in Azure Virtual Machines, App Serivce, and Functions called Managed Service Identity (MSI) that automatically provides an identity to the application that is managed by the platform and can be used by the application to access resources such as Key Vault. This removes the need for any secrets in the application.

Because there is now a centralized location for an application's secrets, different application deployments around the world can pull their secrets from a single Key Vault so we don't have to configure each deployment of the app with their own set of secrets.

Presenter notes:
* Familiarize yourself [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/?WT.mc_id=msignitethetour-github-dev10) capabilities
* Libraries such as [ms-rest-azure](https://www.npmjs.com/package/ms-rest-azure) (Node) and [Microsoft.Azure.Services.AppAuthentication](https://www.nuget.org/packages/Microsoft.Azure.Services.AppAuthentication?WT.mc_id=msignitethetour-github-dev10) (.NET) know how to use MSI, and can be used with Key Vault libraries to authenticate easily with MSI. On your local machine or environments with no MSI enabled, these libraries have alternate methods of authenticating the application so your code doesn't have to change.
* Currently there is no automated way for an app to pull in secrets when they are changed in Key Vault. You must restart each instance of the app manually as secrets are retrieved at app startup.
* When updating secrets in Key Vault, you need to create a new version of the secret. The behavior for enabling/disabling can be confusing so leave old versions enabled for simplicity.
* There is now a way for App Service to reference Key Vault secrets [directly in app settings](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?WT.mc_id=msignitethetour-github-dev10) (no need to use a Key Vault client in the app).

#### Azure Cosmos DB

There are many features in Cosmos DB. The two we will focus on in this talk are its different APIs and global distribution.

Tailwind Traders' Product Service is built with Node.js. MongoDB is a popular database that all Node developers know how to use. Azure Cosmos DB supports many APIs, one of which is MongoDB. Tailwind Traders is able to use Cosmos DB by changing their Product Service's MongoDB connection string to point to Cosmos DB. This allows them to take advantage of a fully managed database, without worrying about servers, updates, sharding, backups, etc.

Cosmos DB makes it easy to replicate our data around the world. This allows applications deployed around the world to read from the nearest replica and achieve very low latency. With Cosmos DB multi-master write capability, we can also write to the nearest replicas. Replicating data in multiple Azure regions also provides resilience in the unlikely event of a regional failure. Cosmos DB can be configured with automatic failover that will select a new primary write region if the originally assigned primary write region is down.

Presenter notes:
* Cosmos DB can be configured to failover the write region based on each region's priority. If multi-master writes is enabled, there are no failover priorities as the application will simply write to the nearest available replica.
* In many cases we can simply point a MongoDB application at Cosmos DB and it should work. However, you should have a good understanding of what operations are not supported and which are in preview (or requires a feature flag to be enabled, such as the aggregation pipeline).
* Common follow up questions when talking about MongoDB API and geo-replication:
    - [How to read from secondaries when using Cosmos DB?](https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-readpreference?WT.mc_id=msignitethetour-github-dev10)
    - [What operations are supported in Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-feature-support?WT.mc_id=msignitethetour-github-dev10)

#### Azure App Service

The simplest way to run applications on Azure is Azure App Service. We will use Web Apps for Linux to deploy the Product Service.

One easy way to deploy the application to App Service is using VS Code. With the [Azure Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack&WT.mc_id=msignitethetour-github-dev10) VS Code extension, we can create and deploy our application to App Service with a single command.

App Service allows us to run multiple instances of an application and it will load balance traffic across the running instances. This allows our application to be highly available within a region.

Presenter notes:
* The demo is to deploy Product Service to Azure App Service with VS Code. However, if you are more comfortable with .NET, use the Inventory Service with VS Code or Visual Studio. There are also Dockerfiles included with each project; you can also do the demo with Azure Container Registry and Web Apps for Containers.

#### Azure Storage static websites

The frontend of our application is a React single page application with no server executable code. While we can serve static websites from Azure App Service, it is more efficient to use the new Static Websites feature of Azure Blob Storage.

We'll use VS Code to deploy the frontend to Static Websites in Blob Storage.

Static Websites can be placed behind a CDN or Azure Front Door to cache data closer to the customer. This also allows users to access a cached version if Blob storage goes down temporarily.

Presenter notes:
* Static Websites is now generally available (as of Dec 12, 2018).

#### Azure Front Door

Azure Front Door Service provides a scalable and secure entry point for fast delivery of your global web applications. We will deploy the Product Service and frontend to multiple regions in Azure, and use Front Door as a proxy over the deployments so that each user will be routed from the Front Door instance closest to them to the Product Service or frontend instance that is closest to the Front Door location.

Front Door can be configured with TLS termination, health probes, caching, custom domains, free managed TLS, etc.

Presenter notes:
* Azure Front Door is currently in preview.
* Front Door has a lot of capabilities. Make sure to read about all of what it can do [here](https://docs.microsoft.com/en-us/azure/frontdoor/?WT.mc_id=msignitethetour-github-dev10).
* Be sure to know the difference between Front Door, CDN, and Traffic Manager.


## Additional resources

#### Azure Front Door

The Azure Front Door portion of the deployment is currently not automated, although the app may be created in additional regions using the above automated script that will serve as multiple backends for the Azure Front Door deployment.

#### Azure Key Vault

Both the Product and Inventory services can pull their secrets from Azure Key Vault. See the READMEs ([Product Service](src/product-service/README.md), [Inventory Service](src/inventory-service/README.md)).


## Learn More / Resources

* [Distribute your data globally with Azure Cosmos DB](https://docs.microsoft.com/learn/modules/distribute-data-globally-with-cosmos-db/?WT.mc_id=msignitethetour-github-dev10) (Microsoft Learn)
* [Build and store container images with Azure Container Registry](https://docs.microsoft.com/learn/modules/build-and-store-container-images/?WT.mc_id=msignitethetour-github-dev1) (Microsoft Learn)
* [Host a web application with Azure App service](https://docs.microsoft.com/learn/modules/host-a-web-app-with-azure-app-service/?WT.mc_id=msignitethetour-github-dev1) (Microsoft Learn)
* [Provision an Azure SQL database to store application data](https://docs.microsoft.com/learn/modules/provision-azure-sql-db/?WT.mc_id=msignitethetour-github-dev1) (Microsoft Learn)
* [Azure Front Door](https://docs.microsoft.com/azure/frontdoor/?WT.mc_id=msignitethetour-github-dev1) (Microsoft Docs)
