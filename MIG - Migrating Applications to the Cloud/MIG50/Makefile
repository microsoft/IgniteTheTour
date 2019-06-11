# MIG50
# -----

all: frontend inventory product
docker: docker-frontend docker-inventory docker-product

allup: setup secrets setup-kubernetes

demo: setup secrets kubeconfig setup-kubernetes setup-kubernetes2 acrbuild helm helm2 setup-fd 

reset-demo: helm-frontend2
	cd charts/frontend && rm rev2.txt 

# Demo Tasks
setup:
	-@scripts/subscription.sh
	-@scripts/up/setup.sh
	-@scripts/mongorestore.sh > /dev/null 2>&1
	-@scripts/pgload.sh

kubeconfig:
	export KUBECONFIG=~/.kube/config

setup-cosmos:
	-@scripts/up/cosmos.sh
	
# login to ACR
login:
	@scripts/acr-login.sh

acrbuild: login
	@cd src/frontend && ../../scripts/dockerfront.sh
	@cd src/inventory-service/InventoryService.Api && ../../../scripts/dockerinventory.sh
	@cd src/product-service && ../../scripts/dockerproduct.sh

localacrbuild: login
	@cd src/frontend && ../../scripts/dockeracrpush.sh

acrlist: login
	@scripts/acr-list.sh

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
	-@scripts/subscription.sh
	-@scripts/down/teardown.sh
	-@scripts/down/funcdown.sh
	-@scripts/down/aks-cleanup.sh

teardown-rg:
	@scripts/subscription.sh
	@scripts/down/rg-delete.sh

# delete only resources created during the talk
reset:
	@scripts/down/reset.sh

pg:
	@scripts/up/postgres.sh

## Other Tasks

funcsetup:
	@scripts/up/funcsetup.sh

funcdeploy:
	@cd src/reports/ && ../../scripts/up/funcdeploy.sh

funcdown:
	@scripts/down/funcdown.sh

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

# MIG50
# -----
# AKS and Helm stuff

acrbuild-aks:
	@cd src/frontend && ../../scripts/dockerfront-aks.sh
	@cd src/inventory-service/InventoryService.Api && ../../../scripts/dockerinventory-aks.sh
	@cd src/product-service && ../../scripts/dockerproduct-aks.sh

# allow us to rebuild individually
acrbuild-aks-frontend:
	@cd src/frontend && ../../scripts/dockerfront-aks.sh
acrbuild-aks-inventory:
	@cd src/inventory-service && ../../scripts/dockerinventory-aks.sh
acrbuild-aks-product:
	@cd src/product-service && ../../scripts/dockerproduct-aks.sh

# for setting up a new resource group for a new AKS
rg-aks:
	@scripts/up/rg-aks.sh

setup-kubernetes: setup-aks setup-kubectl setup-helm
setup-kubernetes2: setup-aks2 setup-kubectl2 setup-helm2

setup-aks:
	@scripts/up/rg.sh
	@scripts/up/aks.sh

setup-aks2:
	-@scripts/up/rg2.sh
	-@scripts/up/aks2.sh

setup-kubectl:
	@scripts/up/kubectl.sh

setup-kubectl2:
	@scripts/up/kubectl2.sh

setup-helm:
	@scripts/up/helm.sh

setup-helm2:
	@scripts/up/helm2.sh

list-pods:
	@cd scripts/helm && ./list-pods.sh

helm-watch:
	kubectl -n kube-system get deploy --watch

helm: helm-frontend helm-inventory helm-product
helm2: helm-frontend2 helm-inventory2 helm-product2

get-ingresses:
	@cd scripts/up && ./get-ingresses.sh

delete-helm: delete-helm-frontend delete-helm-inventory delete-helm-product

helm-frontend:
	@cd charts/frontend && ../../scripts/helm/install-frontend.sh

helm-frontend2:
	@cd charts/frontend && ../../scripts/helm/install-frontend2.sh

helm-reinstall-frontend:
	@cd charts/frontend && ../../scripts/helm/reinstall-frontend.sh

helm-rollback-frontend:
	@cd charts/frontend && ../../scripts/helm/rollback-frontend.sh

delete-one-helm-frontend:
	@cd charts/frontend && ../../scripts/helm/delete-one-frontend.sh

delete-helm-frontend:
	-@cd charts/frontend && ../../scripts/helm/delete-frontend.sh

delete-helm-frontend2:
	-@cd charts/frontend && ../../scripts/helm/delete-frontend2.sh

helm-inventory:
	@cd charts/inventory-service && ../../scripts/helm/install-inventory.sh

helm-inventory2:
	@cd charts/inventory-service && ../../scripts/helm/install-inventory2.sh

delete-helm-inventory:
	@cd charts/inventory-service && ../../scripts/helm/delete-inventory.sh

delete-helm-inventory2:
	@cd charts/inventory-service && ../../scripts/helm/delete-inventory2.sh

helm-product:
	@cd charts/product-service && ../../scripts/helm/install-product.sh

helm-product2:
	@cd charts/product-service && ../../scripts/helm/install-product2.sh

delete-helm-product:
	@cd charts/product-service && ../../scripts/helm/delete-product.sh

delete-helm-product2:
	@cd charts/product-service && ../../scripts/helm/delete-product2.sh

kubectl-frontend-logs:
	kubectl -n frontend logs deploy/frontend-frontend

kubectl-product-logs:
	kubectl -n product logs deploy/product-product

kubectl-inventory-logs:
	kubectl -n inventory logs deploy/inventory-inventory

setup-fd:
	@scripts/up/frontdoor/applytemplate.sh

setup-fd-backends-only:
	@scripts/up/frontdoor/backends.sh
