source ../../scripts/variables.sh
kubectl config use-context $(clustername)
helm delete --purge product
kubectl config use-context $(clustername2)
helm delete --purge product