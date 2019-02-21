# Demos

> IMPORTANT: Before starting the demos, make sure that you have completed the [Preparation steps](01-Preparation.md).

## Creating the Cosmos DB instance in Cloud Shell

> IMPORTANT: We execute this demo early because it takes a moment to create the Cosmos DB instance. This is a change from the recorded dry runs. Here we create the Cosmos DB instance first using Cloud Shell, then we switch to the slides to talk about Cosmos. This gives Azure enough time to finish with the instance creation. Then in the next demo we will go back to the portal and migrate the data using bash.

[Raw video of the demo available here](https://1drv.ms/v/s!As15SQCXjw37s8Fzl7UV5gzk2p94CA)

- Go to the Dashboard in the Azure portal.
- Open the Cloud shell, explain.
- Create the Cosmos DB with the following script:

*Part 1: Define variables*
```bash
RESOURCE_GROUP_COSMOS='lp2s2-cosmosdbgroup'
LOCATION_COSMOS='eastus'
ACCOUNT_NAME_COSMOS='lp2s2cosmosdbaccount'
```

*Part 2: Set the subscription*
```bash
az account set --subscription 'Ignite the Tour'
```

*Part 3: Create the resource group*
```bash
az group create --name $RESOURCE_GROUP_COSMOS --location $LOCATION_COSMOS
```

- In the portal, show that the Resource group was created, but that it is empty.
- Explain the script below:
    - One location only. We could already create multiple locations here but we'll do this later in the portal.
    - MongoDB API (the `kind` directive).
    - Consistency level. There are 5 of those, show them later in the portal. There is a small video explaining the consistency levels.
    - Multi-write is enabled. Explain that this will guarantee write-latency below 10ms.

*Part 4: Create the Cosmos DB instance*
```bash
az cosmosdb create \
    --resource-group $RESOURCE_GROUP_COSMOS \
    --name $ACCOUNT_NAME_COSMOS \
    --kind MongoDB \
    --locations "East US"=0 \
    --default-consistency-level "ConsistentPrefix" \
    --enable-multiple-write-locations true
```

- In the portal, refresh the Resource group view, and show that the Cosmos DB instance exists, with Status = Creating

- Go back to the slides to explain the CosmosDB and talk about the migration.

> Normally the time used on the slides is enough for the DB to come online. In case the DB takes too long to be created, you can switch to [the BAK Cosmos DB instance](http://gslb.ch/ignite-tour-setup-05) and use this one instead. So far however this has not been necessary.

## Migrating the Mongo DB into Cosmos DB

> Note: On Windows, I use Ubuntu (on the Windows Subsystem for Linux) to do the migration. This is just to show multiple tools, and the WSL is awesome. If you are on Mac, you can use the bash console instead but since this is a Microsoft audience, you should also talk a little about the WSL (there is a slide about that). If you prefer you can also run the scripts here in the Cloud Shell.

[Raw video of the demo available here](https://1drv.ms/v/s!As15SQCXjw37s8F1yQ8SZukm7wpk6A)

- Go back to the portal, to the Cosmos DB instance.
- Show that it is now Online.

> Normally the time used on the slides is enough for the DB to come online. In case the DB takes too long to be created, you can switch to [the BAK Cosmos DB instance](http://gslb.ch/ignite-tour-setup-05) and use this one instead. So far however this has not been necessary.

- Give a tour of the Cosmos DB instance.
    - Show that there is one geographical set of data in Eastern US only.
- Go to Ubuntu / Bash
- SSH into the Mongo DB VM

```bash
ssh 'azureuser@'137.117.33.211
```

- Show to the audience that you are not SSHed into the MongoDB VM.
    - Execute the dump. Explain that here we are using native mongo tools that they know and love, but that the Database migration service also supports migrating Mongo to Cosmos.

```bash
mongodump --collection inventory --db tailwind
```

- Change folder into /dump/tailwind and show the files.
    - The BSON contain a binary export of the JSON documents.
    - The JSON contains metadata.

```bash
cd dump
cd tailwind
ls
```

- In the portal, open the Connection String tab of the new Cosmos DB instance.
- Go to the commands.txt file and prepare the script for the restore.
    - Copy the host value from the Connection String tab and replace the HOST part in the script below. Make sure to leave the port `10255` unchanged.
    - Copy the username from the Connection String tab and replace the USER part in the script below.
    - Copy the password from the Connection String tab and replace the PASSWORD part in the script below.
- Copy the modified script into Bash and execute.

```bash
mongorestore --host HOST:10255 -u USER -p PASSWORD --ssl --sslAllowInvalidCertificates inventory.bson --numInsertionWorkersPerCollection 4 --batchSize 24 --db tailwind --collection inventory
```

- After the migration is complete, go back to the Cosmos DB instance to the Collections/Browse tab and refresh the view. Show that now a collection named inventory is available.
    - Change to `Replicate data globally`.
    - Explain what it does, create a set of data in Western US (for disaster recovery), in Europe, in a place close to where the presentation is taking place...
    - Show the Metrics tab.
        - Show the Latency, explain the SLA.
        - Show the Availability, explain the SLA.
    - Show the consistency levels (`Default consistency` tab). There are 5 of them. A small video shows the difference between them directly in the portal tab.
- Go back to Connection String and copy the connection string.
- Go to the [Product Service](http://gslb.ch/ignite-tour-setup-04). Explain that this is a NodeJS service.
    - Go to the `Application settings` tab.
    - Under the `Application settings` section, show the existing connection string `COSMOSDB_OR_MONGODB_CONNECTION_STRING` pointing to the Mongo DB VM (we tell the audience that this is "on premise". Actually it is in Azure, but we tell the audience that "this data server runs under the CEO's desk...").
    - Replace with the copied connection string.
    - Show that even though the connection string is now pointing to the CosmosDB instance, it is using the MongoDB port because it's using MongoDB API.
    - Save.
- Go to [the front end site](http://lp2s2-frontend.azurewebsites.net/).
    - Refresh the view and show that it still works without changing anything. However how do we prove that we are using the new database?
    - Scroll down and show that we have 500 articles now.
- Go to [the new-article.json file](https://github.com/Azure-Samples/ignite-tour-lp2s2/blob/master/demos/new-article.json) in the text editor.
    - Explain that this will create a new article named `This is a test article` at 999 USD, supplied by the `Azure Advocates`.
    - Copy the JSON from this file.
    - Switch to the Cosmos DB instance.
    - Go to Data Explorer.
    - Show the existing documents in the inventory DB.
    - Create a new document.
    - Paste the copied JSON.
    - Save.
    - Go back to the front end site.
    - Refresh the view.
    - Scroll to the bottom and show the new article.

Explain that this migration has a flaw: During the time that the migration takes, it is possible that some users modified the data in the database. To be safe, we should have switched the website off, then migrate, then switch it on again, which means that we lose money during the time that the site is off.

This is a good introduction to the "online" migration feature of the Database migration service. The "online" migration means that you don't need to switch the website off, which minimized downtime. The DMS will keep the source and target databases synchronized at all times, until the time where we are ready to switch the connection string. 

## Data Migration Service, part 1

For this demo, we will use [the Data migration assistant](https://www.microsoft.com/en-us/download/details.aspx?id=53595) to assess the migration. then we will start the database migration service. We execute this demo before the slides about the SQL Database managed instance, this is to give to the migration enough time to complete.

[Raw video of the demo available here](https://1drv.ms/v/s!As15SQCXjw37s8F2Hot2O8oatqfP_w)

- Open the Data migration assistant.
- Create a new project.
- Name the new project `tailwind`.
- Select the source server type `SQL server`.
- Select the target server type `Azure SQL Database Managed Instance`.
- Create the project.
- Explain the features that we will test here (database compatibility, features parity, etc).

> Note that SQL Database Managed Instance is a LOT more expensive than Azure SQL Database (about 10 times more expensive per month) but two features make it worthwhile for enterprises: Increased compatibility (up to 99% compatible even with very old versions of SQL server, all the way down to 2005), and increased security (no public IPs, everything is private, runs on own VNET, VPN / Express route available etc).

- Configure the migration
    - For `server name`, use the IP address `13.68.175.168` of the VM on which the SQL Server 2012 source data runs. This is "on premise" (actually it is in Azure, but we tell the audience that "this SQL server runs under the CEO's desk...")
    - Select `SQL authentication`.
    - The username is `username`.
    - Copy/paste the password `d04f69d38b163f60A1!`.
    - Make sure that `Encrypt connection` and `Trust server certificate` are selected.
    - Click on `Connect`.
    - Select the `tailwind` database.
    - Click `Add`.
    - Click `Start assessment`.
    - When the assessment completes, show that there are no issues with the migration.

At this point we are ready to start the migration with the Database migration service DMS. We have peace of mind because we know that we shouldn't have any issue.

[Raw video of the demo available here](https://1drv.ms/v/s!As15SQCXjw37s8F3aXMWxg9r5MpEig)

- Go to [the SQL Database Managed Instance (SQL DB MI)](http://gslb.ch/ignite-tour-setup-08).
    - Show that there is one DB at the moment which we won't use here.
    - Tailwind is not available yet.
    - Show the VNET and explain the security features of SQL DB MI.
    - Show the Quick start tab
    - Show the connection strings for ADO.NET, ODBC, JDBC etc.
    - Show the pricing tier (see the note below). Show that the prices are transparent, you can scale up and down.
    - Show the "Save money" button. Joke that our accountants hate this button, because it allows leveraging existing licenses (Azure Hybrid benefits) and decrease the Azure SQL database prices by up to 55%. I usually joke about the fact that we're all developers in this room and we need to stick together against the mean accountants, etc...
    - Go back to Overview.
    - Show the `Advanced Threat Protection` tab.
        - For 15USD a month, you can switch this on.
        - There is some AI which runs and checks the data and the connections, and detects like SQL injection etc, and emails you if something bad is found.

> SQL DB MI is a lot more expensive than Azure SQL Database. This price is justified because (1) it's a brand new flavor of Azure SQL Database (2) it's more compatible even with very old versions of SQL Server, all the way down to 2005 and (3) it's more secure, with its own private VNET, private IP addresses, etc... --> Great for enterprise.

- Go to [the Database migration service](http://gslb.ch/ignite-tour-setup-09) in the portal.
    - Create a new migration project.
    - Enter the name `tailwind-migration`.
    - Show the `Source server type`. At this time we support things like MongoDB to Cosmos DB migration (which we just did using the native tools, but explain that you can also use the DMS now), Postgres and mySQL, databases running on AWS, etc.
    - Select `SQL server` as the source server type.
    - Select `Azure SQL Database managed instance` as the `Target server type`.
    - Select `Choose type of activity`. This is where we can select `online` which allows minimum downtime of the website because we don't have to switch off anymore, but the DMS keeps the source and target synchronized. However for this demo we will do an offline migration because online takes more time.
    - Click on `Create and run activity`.
    - In the `Select source` tab, enter the IP address of the "on premise" SQL 2012 VM `13.68.175.168`.
    - Select `SQL authentication`.
    - Enter the username `username`.
    - Enter the password `d04f69d38b163f60A1!`.
    - Make sure that `Encrypt connection` and `Trust server certificate` are checked.
    - Click on `Save`. The service will connect to the source server and check that everything works.
    - In the `Select target` tab, enter the `Target server name`. You can copy it from the SQL Database Managed Instance overview page, it is the `Host` value. Or you can copy it from commands.txt. The value is `sqlmi4e9f1e.0b30e6402ec5.database.windows.net`.
    - Select `SQL authentication`.
    - Enter the username `username`.
    - Enter the password `d04f69d38b163f60A1!`.
    - Click on `Save`. Here too the service will connect to the target server and make sure that everything is OK.
    - In the `Select databases` tab, make sure that `tailwind` is selected.
    - Click on `Save`.
    - In the `Select logins` tab, click on `Save`.
    - Now we need to configure the backups. This is important in case something goes wrong during the migration.
        - Select `I will let Azure Database Migration Service create backup files`.
        - Under `Network share...` enter `\\storage6c4b8e.file.core.windows.net\share1`. This is the address of a file share to which the backups will be copied by the DMS.
        - Under `impersonates`, enter `AZURE\storage6c4b8e`.
        - Under `Password`, enter `t9U7ysu882Jy3Y8kdRa0bk/wNHhGk+75SGebaizG3KHCMDO/SvoW/QWlJb6414a4dNhoUCFoiWFJli7tA6ZYEQ==`.
        - Under `SAS URI`, enter `https://storage6c4b8e.blob.core.windows.net/container1?sp=rwdl&st=2019-01-16T11:30:37Z&se=2020-01-17T11:30:00Z&sv=2018-03-28&sig=79fe3t5zhkPwncwVyp%2FZO8CO9ka1B90K4KlUWGQ6EkY%3D&sr=c`. This is the SAS URI of a blob container which will be used for some temporary files.
        - Click on `Advanced settings`.
        - Show that you can change the name of the target database if needed (don't change it in this demo).
        - Click on `Save`. This step takes a while so be ready to talk through it and explain the next steps.

    - In the `Summary` tab, under `Activity name`, enter `tailwind-activity`.
    - Under `Validation option`, select `Do not validate my database` to go faster but explain that in a production scenario we would prefer to validate the database.
    - Click `Save`.
    - Click `Run migration`.
    - In the `tailwind-activity` tab, click on `Refresh` until we see one database "in progress".
    - Click on this line to show the details.

The migration will take a few minutes to complete, so go back to the slides and give a tour of SQL Database Managed Instance.

## Data Migration Service, part 2

[Raw video of the demo available here](https://1drv.ms/v/s!As15SQCXjw37s8F4fUTfzBJ60Vgx4Q)

At this point the migration should be complete, so change back to the DMS tab and refresh the view.

- The status should show Completed so close the tab.
- Switch to [the SQL DB MI tab](http://gslb.ch/ignite-tour-setup-08) and show that the tailwin DB is now available.
- Switch to the front end site, and show the connection string on top. It should show the old SQL 2012 connection string.
- Explain that to switch the connection string here is a little more complicated than just going to the Azure portal and changing it. This is because the SQL DB MI runs into its own virtual network for added security. So the Inventory service (ASP.NET service) runs into a docker container which is located in the same virtual network, or else it wouldn't have access to the DB, since the DB doesn't have any public IP addresses. Explain that this is a very secure architecture, because no one has direct access to the data, but every access has to go through our Inventory service API, which allows us to check everything.
- Switch to Ubuntu.
- Make sure to `exit` from the SSH session which should still be active.
- Copy/paste the following script. You can simply copy/paste the script below, or copy/paste from the commands.txt file. Note that you will have to enter the password for your private SSH key. What this script does is log into the docker instance hosting the Inventory service, change the connection string setting to the new SQL DB MI connection string, and then log off.

```bash
ssh 'azureuser@'$IP_FQDN << EOM
docker login -u ${CONTAINER_REGISTRY} -p ${CONTAINER_REGISTRY_PASSWORD} ${CONTAINER_REGISTRY}.azurecr.io
docker rm -f ignite-service
docker pull ${CONTAINER_REGISTRY}.azurecr.io/${CONTAINER_IMAGE}
docker run --name ignite-service --restart always -d -p 8080:8080/tcp \\
    -e PORT=8080 \\
    -e CUSTOMCONNSTR_InventoryContext='${CONNECTION_STRING_MI}' \\
    ${CONTAINER_REGISTRY}.azurecr.io/${CONTAINER_IMAGE}
EOM
```

- Once the script completes, switch to the front end site again and refresh the view. 
- Show that the connection string now shows Microsoft SQL Azure with a recent patch date, but the functionality of the site works as is (the inventory numbers show up and you can increase / decrease the values) without changing anything to the application.

At this point we are complete with the demos, switch back to the slides and finish the presentation.