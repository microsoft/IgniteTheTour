# Preparation for the demos

- Open the [front end app service](http://gslb.ch/ignite-tour-setup-01) in the portal and make sure it is running.
    - Close the tab.
- Open [MongoDB](http://gslb.ch/ignite-tour-setup-02) in the portal and make sure it runs.
    - Close the tab.
- Open [SQL Server](http://gslb.ch/ignite-tour-setup-03) in the portal and make sure it runs.
    - Close the tab.
- Open an empty portal.
    - Filter by correct subscription.
- Open [the product service](http://gslb.ch/ignite-tour-setup-04) in the portal.
    - Go to Application Settings.
    - Make sure that the value of `COSMOSDB_OR_MONGODB_CONNECTION_STRING` is `mongodb://137.117.33.211:27017`.
	- Go back to the Overview.
- (If available) Delete resource group lp2s2-cosmosdb.
- Make sure that [the backup Cosmos DB](http://gslb.ch/ignite-tour-setup-05) exists and that the collection tailwind was deleted.
	- Change the global replication to contain only one copy of the data in Eastern US.
- Open [the front end site](http://lp2s2-frontend.azurewebsites.net/) in the web browser (NOT HTTPS).
- Go to [the SQL MI Resource Group](http://gslb.ch/ignite-tour-setup-07), select the `tailwind` resource and delete it.
    - Close the tab.
- Open [the SQL Managed Instance](http://gslb.ch/ignite-tour-setup-08) in the portal and make sure it runs.
- Open [the DMS page](http://gslb.ch/ignite-tour-setup-09) in the portal.
    - Make sure that the service is running. It is configured to always run but sometimes it stops on its own and needs to be restarted.
	- Delete all previous migration projects.
- Open [new-article.json](https://github.com/Azure-Samples/ignite-tour-lp2s2/blob/master/demos/new-article.json) in Notepad++.
- Open [commands.txt](https://github.com/Azure-Samples/ignite-tour-lp2s2/blob/master/demos/commands.txt) in Notepad++.
    - Under `mongorestore migration`, prepare the migration script with HOST, USER and PASSWORD placeholders.

> mongorestore --host HOST:10255 -u USER -p PASSWORD --ssl --sslAllowInvalidCertificates inventory.bson --numInsertionWorkersPerCollection 4 --batchSize 24 --db tailwind --collection inventory

- Open https://docs.microsoft.com/en-us/azure/cosmos-db/cli-samples.
- Make sure that [the Data Migration Assistant](https://www.microsoft.com/en-us/download/details.aspx?id=53595) is installed on your machine and runs.
- Start the presentation
- Open Ubuntu (on Windows) or Bash (Mac / Linux).
- Run the preparation script:

*Part 1: Setting the subscription*

> Note: You may have to install `az` for this to work.

```bash
az account set --subscription 'Ignite the Tour'
```

*Part 2: Defining variables*

> Note: You may have to install `jq` for this to work.

```bash
RESOURCE_GROUP_7='LP2S2-test-7'
RANDOM_STR='6c4b8e'
CONTAINER_REGISTRY=acr${RANDOM_STR}
CONTAINER_IMAGE='ignite-inventory-service:latest'
CONTAINER_REGISTRY_PASSWORD=$(az acr credential show -n $CONTAINER_REGISTRY | jq -r .passwords[0].value)

CONNECTION_STRING_2012='Server=tcp:13.68.175.168,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=username;Password=d04f69d38b163f60A1!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'

CONNECTION_STRING_MI='Server=tcp:sqlmi4e9f1e.0b30e6402ec5.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=username;Password=d04f69d38b163f60A1!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
```

*Part 3: Setting the SSH key for Inventory VM*

> Note: You may have to create an SSH key on your machine for this to work.

```bash
VM_NAME='inventory-service'
az vm user update -u azureuser --ssh-key-value "$(< ~/.ssh/id_rsa.pub)" -g $RESOURCE_GROUP_7 -n $VM_NAME
```

*Part 4: Getting the IPs*
```bash
IP_FQDN=$(az vm show -g $RESOURCE_GROUP_7 -n $VM_NAME -d | jq -r .publicIps)
```

*Part 5: Logging into the docker for Inventory Service and setting the connection string*
```bash
ssh 'azureuser@'$IP_FQDN << EOM
docker login -u ${CONTAINER_REGISTRY} -p ${CONTAINER_REGISTRY_PASSWORD} ${CONTAINER_REGISTRY}.azurecr.io
docker rm -f ignite-service
docker pull ${CONTAINER_REGISTRY}.azurecr.io/${CONTAINER_IMAGE}
docker run --name ignite-service --restart always -d -p 8080:8080/tcp \\
    -e PORT=8080 \\
    -e CUSTOMCONNSTR_InventoryContext='${CONNECTION_STRING_2012}' \\
    ${CONTAINER_REGISTRY}.azurecr.io/${CONTAINER_IMAGE}
EOM
```

> After this script ran, refresh the front end site that you opened earlier. Make sure that the connection string shows the SQL 2012 connection string.

*Part 6: Setting the SSH key for the Mongo DB VM*
```bash
RESOURCE_GROUP_2='LP2S2-test-2'
VM_NAME_MONGO='mongodb1'

az vm user update -u azureuser --ssh-key-value "$(< ~/.ssh/id_rsa.pub)" -g $RESOURCE_GROUP_2 -n $VM_NAME_MONGO
```

*Part 7: Cleanup*
```bash
clear
```

> This script is also available in [commands.txt](https://github.com/Azure-Samples/ignite-tour-lp2s2/blob/master/demos/commands.txt).
