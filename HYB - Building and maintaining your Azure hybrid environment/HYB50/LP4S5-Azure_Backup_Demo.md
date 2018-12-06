**Demo - Azure Backup**

**Prep:**

1.  Log into Azure Portal via this URL:
    https://portal.azure.com/?feature.customportal=false\#\@microsoft.onmicrosoft.com/dashboard/private/166920f4-40a2-4643-b204-5a8304c7300f

2.  Select All Services (located under Dashboard)

3.  In the provided search bar (in between words "All services" and "By
    category" type the word Recovery

4.  Highlight the star next to Recovery Services vaults - This will add Recovery
    Services vaults to your favorites menu

5.  Select Recovery Services vaults and insure the subscription has been set to
    Ignite the Tour

6.  Select TailwindBackup001

7.  Select Backup items

8.  Confirm that SQL in Azure VM is showing a backup count of 4

9.  Navigate to Virtual Machines

10. Select the LP4S5-ASR-Backup resource group only deselecting all other
    resource groups

11. Confirm that 2 VMs are visible - LP4S5-ASR-BackA and LP4S5-ASR-BackB

12. LP4S5-ASR-BackA contains the SQL database and backup is already enabled via
    SQL in Azure VM as a Backup Management Type

13. The backup demo walk-through will be preformed on LP4S5-ASR-BackB

**Demo:**

**Monolog**

Hey this is with Microsoft and today we are going to take a look at Azure
Backup.

With Tailwind Traders now adopting a hybrid infrastructure its now time to take
advantage of Azure Backup. Tailwind Traders have moved thier inventory SQL
database and other VMs to Azure and have enabled backup functionality. Lets
confirm that all VMs are being backed up.

1.  Select Recovery Services vaults

Here in the Recovery Services vaults you can create the vault your backup images
will be stored to. Lets start by clicking Add

1.  Click + Add

Here you can create a new Recovery Services Vault, select the subscription,
resource group and location for said vault. The IT team has already created a
vault for us to use so we will select TailwindBackup001

1.  Select TailwindBackup001

With the appropriate vault now selected, we are presented with a slew of options
to backup, restore, set backup policies, monitor backup jobs and other
traditional backup functionaility.

Lets see what items are currently being backed up

1.  Select Backup items

Here we can see under Backup Managment Type that there are currently 4 SQL in
Azure VM items being backed up. Currently in public preview, Azure Backup for
SQL Server on Azure VMs uses native SQL Server backup and restore APIs to
provide a solid backup offering including a 15-minute log backup with
point-in-time restore up to a specific second.

1.  Select SQL in Azure VM

Here we can see Azure Backup has backed up 4 SQL standalone instances and the
backup status is healthy.

1.  Select TailwindBackup001 - Backup items (top)

Back in Backup items I can see we are missing a VM that needs to be backed up in
this vault. Lets get started in adding backup fuctionality to this VM.

1.  Select Backup under Getting Started

Here we can define what we plan to backup

1.  Select the drop arrow under "Where is your workload running?"

Notice that Azure Backup offers a backup solution for both in cloud and
on-premise.

1.  Select On-Premises

2.  Select the drop arrow under "What do you want to backup?"

Here you can see the different types of backup possibilities for on-premises
instances. Everything from Hyper-V VMs to Exchange Servers to even Bare Metal
Recovery.

1.  Select Bare Metal Recovery

2.  Select Prepare Infrastructure

The on-premises infrastructure can be prepared via System Center Data Protection
Manager or any other System Center Product. Alternatively the solution can also
be setup by setting up an on-premise Azure Backup Server by following the
provided 2 step instructions.

The VM we plan to backup is in Azure and so we'll change the "Where is your
workload running?" selection to reflect that.

1.  Select the drop arrow under "Where is your workload running?"

2.  Select Azure

3.  Select the drop arrow under "What do you want to backup?"

Here you can see the different types of backup possibilities for Azure VMs.
Tailwind Traders SQL on Azure VM currently uses the SQL Server in Azure VM
(Preview). The VM we wish to backup contians a legacy application and so only
requires the VM to be backed up.

1.  Select Virtual Machine

2.  Select Backup

Now we'll set the Backup policy. The default policy backs up the VM daily at
5:30am and retains that backup for 30 days.

1.  Select Create New in the "Choose backup policy" drop down menu

As you can see Tailwind Traders has a plethora of backup choices in terms of
frequency and length of retention. Tailwind Traders is happy with the default
backup offering for now and can change the policy later.

1.  Select DefaultPolicy in the "Choose backup policy" drop down menu

2.  Select OK

Next will select which VM we need to backup. Lets go ahead and prepare Server B
for backup

1.  Select checkmark box beside LP4S5-ASR-BackB

2.  Select OK

You can then enable the backup job once the VM to be backed up has been valided.

1.  Select Enable backup

Now the deployment of the backup job is being created within the desired
resource group which takes a minute or so to setup.

1.  Select Backup items once the backup job has been completed

Now we can see that the Azure VM backup job has been added

1.  Select Azure Virtual Machine

And we can see the backup job is for server B. The backup pre-check or
validation has passed and is awaiting for the set time to conduct its first
backup. Azure Backup for Tailwind Traders is now complete.

**Post Demo:**

1.  Navigate to Recovery Services vaults \> Backup items \> Azure Virtual
    Machine

2.  Select LP4S5-ASR-BackB

3.  Select Stop backup

4.  Select Delete Backup Data in the 1st dropdown

5.  Type LP4S5-ASR-BackB in the next box

6.  Select Stop backup

7.  Navigate to Navigate to Recovery Services vaults \> Backup items

8.  Select Refresh

9.  Verify that only 4 SQL in Azure VM items exist
