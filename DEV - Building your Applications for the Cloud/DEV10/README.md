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

Change into the `deployment` directory and run `deploy.sh`.

#### Azure Key Vault

Azure Key Vault provides a centralized service for managing secrets for applications. Instead of passing secrets around in emails and messaging apps, secrets can be placed in Azure Key Vault by an administrator, and access to the secrets can be given to identities in Azure Active Directory such as users or applications. As secrets or access permissions change, we can modify them in Key Vault.

Azure Key Vault still requires the application to have a single secret: an AAD identity that it will use to access Key Vault. There is a feature in Azure Virtual Machines, App Serivce, and Functions called Managed Service Identity (MSI) that automatically provides an identity to the application that is managed by the platform and can be used by the application to access resources such as Key Vault. This removes the need for any secrets in the application.

Because there is now a centralized location for an application's secrets, different application deployments around the world can pull their secrets from a single Key Vault so we don't have to configure each deployment of the app with their own set of secrets.

#### Azure Cosmos DB

There are many features in Cosmos DB. The two we will focus on in this talk are its different APIs and global distribution.

Tailwind Traders' Product Service is built with Node.js. MongoDB is a popular database that all Node developers know how to use. Azure Cosmos DB supports many APIs, one of which is MongoDB. Tailwind Traders is able to use Cosmos DB by changing their Product Service's MongoDB connection string to point to Cosmos DB. This allows them to take advantage of a fully managed database, without worrying about servers, updates, sharding, backups, etc.

Cosmos DB makes it easy to replicate our data around the world. This allows applications deployed around the world to read from the nearest replica and achieve very low latency. With Cosmos DB multi-master write capability, we can also write to the nearest replicas. Replicating data in multiple Azure regions also provides resilience in the unlikely event of a regional failure. Cosmos DB can be configured with automatic failover that will select a new primary write region if the originally assigned primary write region is down.

#### Azure App Service

The simplest way to run applications on Azure is Azure App Service. We will use Web Apps for Linux to deploy the Product Service.

One easy way to deploy the application to App Service is using VS Code. With the [Azure Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack&WT.mc_id=msignitethetour-github-dev10) VS Code extension, we can create and deploy our application to App Service with a single command.

App Service allows us to run multiple instances of an application and it will load balance traffic across the running instances. This allows our application to be highly available within a region.

#### Azure Storage static websites

The frontend of our application is a React single page application with no server executable code. While we can serve static websites from Azure App Service, it is more efficient to use the new Static Websites feature of Azure Blob Storage.

We'll use VS Code to deploy the frontend to Static Websites in Blob Storage.

Static Websites can be placed behind a CDN or Azure Front Door to cache data closer to the customer. This also allows users to access a cached version if Blob storage goes down temporarily.

#### Azure Front Door

Azure Front Door Service provides a scalable and secure entry point for fast delivery of your global web applications. We will deploy the Product Service and frontend to multiple regions in Azure, and use Front Door as a proxy over the deployments so that each user will be routed from the Front Door instance closest to them to the Product Service or frontend instance that is closest to the Front Door location.

Front Door can be configured with TLS termination, health probes, caching, custom domains, free managed TLS, etc.

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
