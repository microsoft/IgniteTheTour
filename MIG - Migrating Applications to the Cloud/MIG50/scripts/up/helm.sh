#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh
# requires AKS to be installed with ./scripts/up/aks.sh
# https://docs.helm.sh/using_helm/#installing-helm
# "...if you want to live on the edge"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    kubectl config use-context $(clustername)
fi

kubectl create -f charts/rbac-config.yml

helm init --service-account tiller
