#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh
# requires AKS 2nd cluster to be installed with ./scripts/up/aks2.sh

echo "checking for helm on your sytem..."
echo ''
command -v helm > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Helm appears to already be installed on your local system."
    echo ''
else
    echo "Helm is not currently installed. Installing helm now..."
    echo ''
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
fi

if [ "$(clustername2)" != "$(kubectl config current-context)" ]; then
    echo "Switching to $(clustername2) cluster..."
    echo ''
    kubectl config use-context $(clustername2)
fi

echo "Checking for existing tiller service account..."
echo ''

if [[ $(kubectl get sa -n kube-system | grep tiller) = *tiller* ]]; then
  echo "serviceaccount/tiller and clusterrolebinding.rbac.authorization.k8s.io/tiller have already been created"
  echo ''
else
    echo "creating rbac service acocunt and cluster role bindings..."
    echo ''
    kubectl create -f charts/rbac-config.yml
fi

echo "initializing helm..."
echo ''
helm init --service-account tiller
sleep 10
if [[ "helm version" ]] && [[ "kubectl get pods -n kube-system | grep tiller" ]]; then
    echo "helm and tiller are successfully installed..."
else
    echo "helm does not apper to be installed...please check manually..."
fi
