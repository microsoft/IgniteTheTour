#!/bin/bash
set -eou pipefail
source ../variables.sh

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername)
fi

prompt kubectl get ingress
