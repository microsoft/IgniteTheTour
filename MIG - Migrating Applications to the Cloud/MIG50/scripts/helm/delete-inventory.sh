source ../../scripts/variables.sh
kubectl config use-context $(clustername)
helm delete --purge inventory
kubectl config use-context $(clustername2)
helm delete --purge inventory