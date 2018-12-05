#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

echo "Creating Front Door $(fdname)"
echo "Frontend address: $(fdfrontend)"
echo "Inventory address: $(fdinventory)"
echo "Product address: $(fdproduct)"

az network front-door create -g $(rg) --name $(fdname) --backend-address $(fdfrontend)

az network front-door load-balancing create \
-g $(rg) \
-f $(fdname) \
-n "loadbalancing1" \
--sample-size 1 \
--successful-samples-required 1

az network front-door probe create \
-g $(rg) \
-f $(fdname) \
-n "probe1" \
--interval 5 \
--protocol Http \
--path "/"

#####
# The backend pool for the frontend service in AKS
#####
echo "Creating backend pool for frontend service $(fdfrontend)"

az network front-door backend-pool create \
-g $(rg) \
--front-door-name $(fdname) \
-n "FrontendBackendPool" \
--load-balancing "loadbalancing1" \
--probe "probe1" \
--address $(fdfrontend)

echo "Creating routing rule for frontend service"

#az network front-door routing-rule create \
#-g $(rg) \
#--front-door-name $(fdname) \
#-n "FrontendServiceRoutingRule" \
#--frontend-endpoints "DefaultFrontendEndpoint" \
#--backend-pool "FrontendBackendPool" \
#--patterns '/*'

#####
# The backend pool for the inventory service in AKS
#####

echo "Creating backend pool or inventory service $(fdinventory)"

az network front-door backend-pool create \
-g $(rg) \
--front-door-name $(fdname) \
-n "InventoryBackendPool" \
--load-balancing "loadbalancing1" \
--probe "probe1" \
--address $(fdinventory)

echo "Creating routing rule for inventory service $(fdinventory)"
az network front-door routing-rule create \
-g $(rg) \
--front-door-name $(fdname) \
-n "InventoryRoutingRule" \
--frontend-endpoints "DefaultInventoryEndpoint" \
--backend-pool "InventoryBackendPool" \
--patterns '/*'

#####
# The backend pool for the product service in AKS
#####

echo "Creating backend pool for product service $(fdproduct)"
az network front-door backend-pool create \
-g $(rg) \
--front-door-name $(fdname) \
-n "ProductBackendPool" \
--load-balancing "loadbalancing1" \
--probe "probe1" \
--address $(fdproduct)

echo "Creating routing rule for product service"
az network front-door routing-rule create \
-g $(rg) \
--front-door-name $(fdname) \
-n "ProductRoutingRule" \
--frontend-endpoints "DefaultProductEndpoint" \
--backend-pool "ProductBackendPool" \
--patterns '/*'
