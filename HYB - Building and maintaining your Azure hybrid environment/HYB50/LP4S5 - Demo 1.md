# Demo 1 – ASR setup and replication
## Demo Intro

Let’s get started

### Design Fail-over Infrastructure

### Setup the Recovery Vault
1. Sign in to the Azure portal
2. Click **+ Create a resource**
2. Type **Site Recovery** in the search bar.
2. Click on  **Backup and Site Recovery (OMS)**.
2. Click **Create**
3. In Name, Type **TTRecoveryVault**.
3. Select **Ignite the Tour** for the subscription
4. Click on **Create New** for the resource group and name it **LP4S5-ASR-Target**.
5. Specify "**East US**" as the Azure region.
6. Click Pin to dashboard and then click Create.

### Deploy Config server on source environemnt

1. In the Resource menu of the vault, click Getting Started > Site Recovery > Step 1: Prepare Infrastructure > Protection goal.
1. Select "**On-Premises**" in the "Where are your machines Located?"
1. Make sure **Azure** is in the "Where you want to replicate your machines to?"
1. Select "**Not Virtualized / Other**" in the "Are your machines Virtualized?"
1. Click **OK**
1. In Step 2, select "**Yes, I have Done it**" in the "Have you completed deployment planning?"
1. In Step 3 we prepare our Source environment. Click "**+ Configuration Server**"
1. Explain the steps  listed.
1. Click "**Download**" and save the Vault credentials

**Option to show the config server setup**
1. RDP in the **ConfigVM** azure virtual machine in the "**LP4S5-ARS-Source**"
    > Username: sysadmin
    > Password: P@ssw0rd1234
2. Open File explorer on the server and navigate to "**f:\**"
2. copy the "**TTRecoveryVault_<Dates>.VaultCredentials**" to the VM
2. Execute "**MicrosoftAzureSiteRecoveryUnifiedSetup**"
    >use P@ssw0rd1234 for all SQL passwords
3. Select "**No**" to protect VMWare machines.  all other items are default

### Setup the Target environment###



















	
	
	
	
	
	
	
	

