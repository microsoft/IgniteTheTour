#!/bin/bash
#set -eou pipefail
source ./scripts/variables.sh

# Local context cleanup for AKS 1
kubectl config unset users.$(clustername)
kubectl config unset clusters.$(clustername)
kubectl config unset contexts.$(clustername)
kubectl config delete-context $(clustername)

# Local context cleanup for AKS 2
kubectl config unset users.$(clustername2)
kubectl config unset clusters.$(clustername2)
kubectl config unset contexts.$(clustername2)
kubectl config delete-context $(clustername2)

