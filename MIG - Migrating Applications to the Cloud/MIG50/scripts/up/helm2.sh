#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    kubectl config use-context $(clustername2)
fi

kubectl create -f charts/rbac-config.yml

helm init --service-account tiller
