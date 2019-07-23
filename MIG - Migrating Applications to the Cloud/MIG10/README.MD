**NOTE:** This repo uses the same code as [DEV10](https://github.com/microsoft/IgniteTheTour/tree/master/DEV%20-%20Building%20your%20Applications%20for%20the%20Cloud/DEV10), so you should clone the source from [that repo](https://github.com/microsoft/IgniteTheTour). Read down on this page for a little more info on how to setup the project in DEV10 for this session.

# Migrating Web Applications To Azure
_This project uses the exact same assets as DEV10. It focuses on deploying those assets to Azure with Azure Container Registry and Azure Web Apps for Containers._ 

[Watch A Recording](https://microsoft.sharepoint.com/:v:/t/CloudDevAdvocacy/ERBM2XpSONBFrMZmOgdXH2gBlhRw5RgVe8NEhJ49BM5vxQ?e=e6phxE)  

### What it does

Deploy 3 web-based applications (2 API's, one front end) to Azure Web Apps for Containers

[Get an Azure account](https://azure.microsoft.com/en-us/free/search/?&OCID=AID719825_SEM_AvIozCH4&lnkd=Google_Azure_Brand&gclid=Cj0KCQiAuf7fBRD7ARIsACqb8w5I_HoGm0rU-Wz1WN8LCirFrKYX0e0E-Ja3R3Dif02iigv1JF3r65caAtdhEALw_wcB)  
  
**_Deploy to Azure Button would be somewhere here, if applicable_**  

## Services Used
- [Azure Container Services](https://azure.microsoft.com/en-us/services/container-registry/?WT.mc_id=ignitetour-github-mig10)
- [Azure Web App For Containers](https://azure.microsoft.com/en-us/services/app-service/containers/?WT.mc_id=ignitetour-github-mig10)
- [Azure VNet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview?WT.mc_id=ignitetour-github-mig10)

## How to Publish/Deploy Manually (if applicable)
  ### Prerequisites:
  - [Docker Engine Community Edition](https://www.docker.com/products/docker-engine)
  
  ### Instructions
  1. Follow the instructions in DEV10 to setup the application. Note that for this project you will need a SQL Server and Comsos DB instance that are already populated with data. To create those instances, follow the instructions... 
  1. Create a new Azure Container Registry (ACR)

      ![Azure Portal with Azure Container Registry buttons highlighted](images/create-acr-1.png)
  1. Name the registry. Create a new Resource Group if you need to. It's a good idea to keep this ACR and the web applications created later in the same Resource Group for easy cleanup so you don't incure unexpected charges.

      ![New Azure Container Registry screen in Azure Portal](images/create-acr-2.png)
  
  1. Once the registry has been created, go to the Access Keys menu item. Copy the "Login server" name and enable the admin user, setting the username and password.
  
      ![Azure Container Registry access keys screen](images/create-acr-3.png)

  1. Open a terminal instance and login to ACR with Docker

      ```
      docker login --username <username> --password <password> <login server>
      ```
  
  1. Go the "src/frontend" directory of the DEV10 repo and build the application as a Docker image

      ```
      docker build -t [your login servername]/frontend:latest
      ```

  1. Repeat this for both "src/products-service" and "src/inventory-service"

      ```
      docker build -t [your login servername]/products-service:latest
      ```

      ```
      docker build -t [your login servername]/inventory-service:latest
      ```

  1. Push each of these images to ACR

      ```
      docker push [your login servername]/frontend:latest
      docker push [your login servername]/products-service:latest
      docker push [your login servername]/inventory-service:latest
      ```
  
  1. Create a new Web App for Containers with the Azure Portal

      ![Azure Portal creating a new Web App for Containers](images/create-web-app-1.png)

      ![New Web App for Containers screen in Azure Portal](images/create-web-app-2.png)

  1. Click on the "Configure Container" section and select "Azure Container Registry" and then select the registry that you created earlier, as well as the "frontend" container.

      ![Configure Container screen in Azure Portal](images/create-web-app-3.png)

  1. Click "Apply" and then "Create" on the previous screen to finish creating the web app. View the "Overview" tab to get the URL to your service.

  1. Repeat these steps for both the products-service and inventory-service.


### Create Envrionment Variables

  1. Add SQL Server connection string to inventory-service, go to App Service for inventory-service.  

    * Select "Application Settings." Scroll down to "Connection Strings" and create new connections string with 
    * CONNECTION STRING NAME "InventoryContext", 
    * the VALUE is the full connection string, "Server=tcp:server-example-sqldb.database.windows.net,1433;Initial Catalog=example-example-sqldb;Persist Security Info=False;User ID=example;Password=example;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30" and TYPE "SQLAzure"

Save these Settings, move on to product-service App-Service.  

Select "Application Settings." Scroll down to "Application setting and create the following APP SETTING NAME and VALUE for your app:
    
    * DB_CONNECTION_STRING, ```mongodb://example-northwind:Ywk16bEy0yNMdOI4NMqvEVENT1najbzq0Iam6R3SpsDyOL2exE9Yx0UlL4mmOrard8GZrkN2lDkahpuaxBqeEQ==@tailwind-northwind.documents.azure.com:10255/tailwind?ssl=true&replicaSet=globaldb```
        * SEED_DATA, true
Save and then create frontend variables, these are the https urls of the product-service and inventory-service.
  
  * Select "Application Settings." Scroll down to "Application setting and create the following APP SETTING NAME and VALUE for your app:
    * INVENTORY_SERVICE_BASE_URL, https://twt-inventory-api.azurewebsites.net/
    * PRODUCT_SERVICE_BASE_URL, https://twt-product-api.azurewebsites.net/


View the application with the URL of the frontend serivce https url, EXAMPLE: https://twt-frontend-prod.azurewebsites.net

## Learn More/Resources

* [Use a custom Docker image for Web App for Containers](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image?WT.mc_id=ignitetour-github-mig10)


## Learn More/Resources

* [Use a custom Docker image for Web App for Containers](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image?WT.mc_id=ignitetour-github-mig10)




