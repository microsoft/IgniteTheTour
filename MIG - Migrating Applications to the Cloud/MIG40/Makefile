all: frontend inventory product
docker: docker-frontend docker-inventory docker-product

# Demo Tasks
setup:
	@scripts/subscription.sh
	@scripts/up/setup.sh
	@scripts/mongorestore.sh > /dev/null 2>&1
	@scripts/pgload.sh



acrbuild: login
	@cd src/frontend && ../../scripts/dockerfront.sh
	@cd src/inventory-service/InventoryService.Api && ../../../scripts/dockerinventory.sh
	@cd src/product-service && ../../scripts/dockerproduct.sh

acrlist: login
	@scripts/acr-list.sh

localacrbuild: login
	@scripts/dockeracrpush.sh

# get connection string for cosmos
connection:
	@scripts/connection.sh

secrets:
	@scripts/up/secrets.sh

deploy:
	@scripts/up/deploy.sh

deploy-secure:
	@scripts/up/deploy-secure.sh

deploy-open:
	@scripts/up/deploy-open.sh

mongorestore:
	@scripts/mongorestore.sh > /dev/null 2>&1

mongorestore-verbose:
	@scripts/mongorestore.sh

# tear it all down
teardown:
	@scripts/subscription.sh
	@scripts/down/teardown.sh
	@scripts/down/funcdown.sh

# delete only resources created during the talk
reset:
	@scripts/down/reset.sh

## Databases
setup-cosmos:
	@scripts/up/cosmos.sh
	
pg:
	@scripts/up/postgres.sh
# login to ACR
login:
	@scripts/acr-login.sh


funcsetup:
	@scripts/up/funcsetup.sh

funcdeploy:
	@cd src/reports/ && ../../scripts/up/funcdeploy.sh

funcdeploy-local:
	@cd src/reports && ../../scripts/up/funcdeploy-local.sh

pgload:
	@scripts/pgload.sh

# local development
frontend:
	@cd src/frontend && npm run dev

inventory:
	@scripts/inventory.sh

product:
	@cd src/product-service && npm run dev

# docker build
docker-frontend:
	@cd src/frontend && docker build -t twt-frontend .

docker-inventory:
	@cd src/inventory-service/InventoryService.Api && docker build -t twt-inventory .

docker-product:
	@cd src/product-service && docker build -t twt-product .

devshell:
	./scripts/devshell.sh
