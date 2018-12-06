# The Inventory Service Kubernetes Chart

## Installing to AKS

To install to AKS, make sure that you have an AKS cluster and have [installed Helm](../README.md). Then, execute the following from inside this directory:

```console
helm install --name inventory --namespace inventory ./
```

To view all the Kubernetes artifacts created, run:

```console
kubectl get all -n inventory
```

To delete it, run:

```console
helm delete --purge inventory
```
