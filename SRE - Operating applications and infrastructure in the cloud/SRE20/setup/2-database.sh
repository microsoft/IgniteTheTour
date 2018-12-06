#!/bin/bash
set -eo pipefail

source ./0-params.sh

### SQL SERVER
# Create a logical server in the resource group
echo "Creating a Azure SQL Server instance $SERVERNAME in $DB_RG."
az sql server create \
	--name $SERVERNAME \
	--resource-group $DB_RG \
	--location $LOCATION  \
	--admin-user $DBUSER \
	--admin-password $DBPASS \
	-o table &> $base_source_path/../setup/log/2-database.log

# Configure a firewall rule for the server
echo "Allowing Azure IPs to the Azure SQL Server instance."
az sql server firewall-rule create \
	--resource-group $DB_RG \
	--server $SERVERNAME \
	-n AllowAllAzureIPs \
	--start-ip-address $startip \
	--end-ip-address $endip \
	-o table &>> $base_source_path/../setup/log/2-database.log

# Create a database in the server with zone redundancy as true
echo "Creating the $DATABASENAME database on $SERVERNAME."
az sql db create \
	--resource-group $DB_RG \
	--server $SERVERNAME \
	--name $DATABASENAME \
	--service-objective S0 \
	--zone-redundant false \
	-o table &>> $base_source_path/../setup/log/2-database.log

# Load Data
echo "Loading starting data in $DATABASENAME on $SERVERNAME."
sqlcmd \
	-S tcp:$SERVERNAME.database.windows.net,1433 \
	-d tailwind \
	-U $DBUSER \
	-P $DBPASS \
	-i ~/source/tailwind-traders/sql_server/tailwind_ss.sql &>> $base_source_path/../setup/log/2-database.log

# ### PostgreSQL
# SKU=B_Gen5_1

# # Create the PostgreSQL service
# az postgres server create \
#     --resource-group $DB_RG \
#     --name $SERVERNAME \
#     --location $LOCATION \
#     --admin-user $DBUSER \
#     --admin-password $DBPASS \
#     --sku-name $SKU \
#     --version 10.0

# # Open up the firewall so we can access
# az postgres server firewall-rule create \
#     --resource-group $DB_RG \
#     --server $SERVERNAME \
#     --name AllowAllAzureIPs \
#     --start-ip-address $startip \
#     --end-ip-address $endip

# echo "Creating the Tailwind database..."

# # Load data
# pushd ~/source/tailwind-traders/postgres/
# psql "postgres://$DBUSER%40$SERVERNAME:$DBPASS@$SERVERNAME.postgres.database.azure.com/postgres" -c "CREATE DATABASE tailwind;"
# psql "postgres://$DBUSER%40$SERVERNAME:$DBPASS@$SERVERNAME.postgres.database.azure.com/tailwind" -f tailwind.sql

# popd
