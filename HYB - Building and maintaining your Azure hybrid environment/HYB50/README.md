# # HYB50 - Business Continuity Planning
In this session you'll see how Tailwind Traders came up with a Business Continuity Plan for Northwind's brand new hybrid infrastructure. You'll see how we implemented Azure Site Recovery and Azure Backup.

## Services Used
- Azure Site Recovery
- Azure Backup

## NOTE: 

All services created will incur usage costs that you, the replicator of the demo detailed below, will incur. Please be aware the you, the replicator of the demo detailed below, will be responsible for all costs associated in replicating, operating and maintaining this demonstration. Microsoft takes no responsibility of any costs incurred while replicating, operating and maintaining this demonstration. It is advised to turn off or terminate the replicated demonstration once completed to ensure incurred costs are kept to a minimum.  

## ASR Demo Setup - Required to Complete Setup

In order to perform the demos for this session, you will need to build out resources in your Azure subscription. Create the following resources before proceeding to the demo activities listed below.

### Create a Source Hyper-V server
In order to simulate an on-premises environment you can use nested virtualization.  We have made available a template with scripts to deploy an Hyper-V server in Azure based on Windows Server 2016. Just click the <a  href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpierreroman%2FLP4S5%2Fmaster%2FASR-Demo-Setup%2FAzureNestedHyperV-master%2Fazure-deploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a> button.

You will need to create VMs as nested workloads in order to setup protection, replicate the workload and perform tests and regular failovers.

### Prepare Azure resources for disaster recovery

Once source has been created, follow the instructions in <a href="https://docs.microsoft.com/en-us/azure/site-recovery/tutorial-prepare-azure?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">Prepare Azure resources for disaster recovery of on-premises machines</a>.

Following this, you follow the following <a href="https://docs.microsoft.com/en-us/azure/site-recovery/hyper-v-azure-tutorial?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">instructions</a> to set up disaster recovery of on-premises Hyper-V VMs to Azure.  

```txt
Please note the step above may take a long time to replicate the running VMs.
```
### Run a disaster recovery drill to Azure

Once The replication has completed and that you have validated that the replicated items are Healthy

```txt
Navigate to Recovery Services vaults > "Your Recovery Vault" > Replicated items and review the replication status.
```
Use these <a href="https://docs.microsoft.com/en-us/azure/site-recovery/tutorial-dr-drill-azure?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">instructions</a> to run a disaster recovery drill.

## Azure VM Backup Demo - Required to Complete Setup

In order to perform the Azure Backup demo, you will need to build out resources in your Azure subscription. Create the following resources before proceeding to the demo activities listed below.

### Deploy VMs to be backed up

Using ARM templates from <a href="https://azure.microsoft.com/en-ca/resources/templates?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">Azure Quickstart Templates</a> you can deploy the following workloads to a resource group in your subscription.

1. 1 or 2 Windows 2012R2 IIS Web Servers.
2. 1 SQL Server 2014 running on premium or standard storage.
3. 1 virtual network with 2 subnets with NSG rules.
4. 1 Availability Set for IIS servers.
5. 1 Load balancer with NATing rules.

Click the button below to deploy the resources.

<a  href="https://portal.azure.com/#create/Microsoft.Template/uri/https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fiis-2vm-sql-1vm%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

### Back up SQL Server databases to Azure

SQL Server databases are critical workloads that require a low recovery point objective (RPO) and long-term retention. Azure Backup provides a SQL Server backup solution that requires zero infrastructure: no complex backup server, no management agent, and no backup storage to manage. Azure Backup provides centralized management for your backups across all servers that are running SQL Server, or even different workloads.

Follow the instructions <a href="https://docs.microsoft.com/en-us/azure/backup/backup-azure-sql-database?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">here</a> to build a backup solution for the workload we created earler.

### Setup Backup of VMs running in Azure

for the other non SQL VMs we created, follow the instructions listed <a href="https://docs.microsoft.com/en-us/azure/backup/tutorial-backup-vm-at-scale?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">here</a> to Use Azure portal to back up the reminder multiple virtual machines

```txt
Please note that the instructions show you how to create a vault again.
Please use the vault we created when we protected the SQL workload.
```


### Restore VM from Azure Backup

Azure Backup creates recovery points that are stored in geo-redundant recovery vaults. When you restore from a recovery point, you can restore the whole VM or individual files. The following explains how to restore a complete VM using CLI. In this tutorial you learn how to:
* List and select recovery points
* Restore a disk from a recovery point
* Create a VM from the restored disk

please refer to <a href="https://docs.microsoft.com/en-us/azure/backup/tutorial-restore-disk?WT.md_id=MSIgniteTheTour-github-hyb50" target="_blank">Restore a disk and create a recovered VM in Azure</a> for the instructions

## Learn More/Resources

### Microsoft Learn

[Design for availability & recoverability in Azure](https://docs.microsoft.com/en-us/learn/modules/design-for-availability-and-recoverability-in-azure/index?WT.mc_id=MSIgniteTheTour-github-hyb50)

### Microsoft Docs

[Site Recovery Documentation](https://docs.microsoft.com/en-us/azure/site-recovery/?WT.mc_id=MSIgniteTheTour-github-hyb50)

[Azure Backup Documentation](https://docs.microsoft.com/en-us/azure/backup/?WT.mc_id=MSIgniteTheTour-github-hyb50
)

