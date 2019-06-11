#!/bin/bash
set -eou pipefail
source ../scripts/variables.sh

echo "Frontend service address: $(fdfrontend)"
echo "Inventory service address: $(fdinventory)"
echo "Product service address: $(fdproduct)"

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

az network front-door routing-rule create \
-g $(rg) \
--front-door-name $(fdname) \
-n "FrontendServiceRoutingRule" \
--frontend-endpoints "DefaultFrontendEndpoint" \
--backend-pool "FrontendBackendPool"

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
--backend-pool "InventoryBackendPool"

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
--backend-pool "ProductBackendPool"

