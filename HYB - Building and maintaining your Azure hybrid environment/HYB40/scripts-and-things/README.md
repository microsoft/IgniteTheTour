## RBAC (Personal subscription)

- [PORTAL] Manual configure reader (rebecca@nepeters.com)
- Azure CLI create custom role and assign

Create Role (Cloud Shell)

```
az role definition create --role-definition vm-restart.json
```

Assign user to Role:

```
az role assignment create --role "Restart Virtual Machines" --assignee rebecca@nepeters.com
```

## Azure Policy

- [PORTAL] Management Group
- [PORTAL] Apply single policy (tag resource)
- Apply custom policy (tag resource by type)

Create resource group and apply policy:

```
pwsh ./policy-tag-type/policyTagAppendType.ps1 -ResourceGroupName policy-demo-custom -ResourceType Microsoft.Storage/storageAccounts -Location eastus -PolicyName tagByType
```

Create storage account which will be tagged.

```
az storage account create --name storage007$RANDOM --resource-group policy-demo-custom
```

Create container instance which will not be tagged.

```
az container create --name contianer$RANDOM --resource-group policy-demo-custom --image microsoft/aci-helloworld
```

- [PORTAL] Create RG and apply initiative (Storage and VM SKU)

## Blueprints

- [PORTAL] Manually create blueprint
- Azure DevOps demo