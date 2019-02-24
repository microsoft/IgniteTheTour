# HYB10 - Planning and Implementing Hybrid Network Connectivity

  In this session you'll learn how to assess your organization's on-premises  network infrastructure, how to plan and then implement an appropriate networking design for Azure. You'll learn how to implement appropriate Azure virtual network technologies, including securing connectivity between on-premises and Azure using VPNs and ExpressRoute as well as how to strategically deploy firewalls, network security groups and marketplace appliances to protect those resources and workloads.

## Services Used

- Azure Virtual Networks
- Azure VPN Gateway
- Azure ExpressRoute
- Azure Firewall
- Azure File Sync

## NOTE: 

All services created will incur usage costs that you, the replicator of the demo detailed below, will incur. Please be aware the you, the replicator of the demo detailed below, will be responsible for all costs associated in replicating, operating and maintaining this demonstration. Microsoft takes no responsibility of any costs incurred while replicating, operating and maintaining this demonstration. It is advised to turn off or terminate the replicated demonstration once completed to ensure incurred costs are kept to a minimum.  

## **Demo Setup - Required to Complete Setup**

In order to perform the demos for this session, you will need to build out resources in your Azure subscription. Create the following resources before proceeding to the demo activities listed below.

## Create Resource Group TailTrade-RG

1. Login to the Azure Portal with an account having global administrator privileges.
2. From the resource blade, click Resource Group.
3. Click '+ Add' to create a new resource group.
    1. For **Name**, choose *TailTrade-RG*.
    2. For **Subscription**, choose your subscription
    3. For Resource Group Location, choose a geographic location available to you.

## DEMO ONE: Create Azure VNet

In this demo, you will be adding an Azure Virtual Network, or VNet, to the Tailwind Traders resource group. This will be used in the process of building an Azure VPN Gateway in a later demo.

Prerequisites: Create Resource Group TailTrade-RG

### Instructions

1.  In the **Virtual Networks** section, click Add

2.  On the **Create virtual network** blade, provide the following information:

    -   Name: tailtrade-VNet-1

    -   Address space: 172.16.0.0/16

    -   Resource Group: TailTrade-RG

    -   Subnet: Name: Subnet-1

    -   Subnet: Address range: 172.16.10.0/24

    -   DDos protection: Basic

    -   Service Endpoints: Click Enabled, Browse through the list and describe
        the functionality of creating endpoints for Azure services on subnets.
        Select all endpoints.

    -   Firewall: Disabled.

3.  Click **Create**.

4.  When the Virtual Network is created, click Refresh

## DEMO TWO: Create Azure VPN Gateway

Using the Azure VNet from the previous demo, you will create an Gateway Subnet and an Azure VPN Gateway.

Prerequisites: Demo One Complete

### Instructions

1.  Open tailtrade-VNet-1, created in the previous demo

2.  Under Settings click Subnets.

3.  When Subnets is selected, click Gateway subnet

4.  In the Add subnet blade, provide the following information

    -   Address range (CIDR) block: 172.16.1.0/24

5.  Do not configure any service endpoints or perform subnet delegation.

6.  Click OK. Wait for the gateway subnet to be created.

7.  In the Search box, type virtual network gateways and click on Virtual
    network gateways in the drop down list.

8.  In the Virtual network gateways blade, click Create virtual network gateway

9.  On the create virtual network gateway blade, provide the following
    information

    -   Name: VNet1GW

    -   Gateway type: VPN

    -   VPN type: Route-based

    -   SKU: VpnGw1

    -   Virtual network: tailtrade-VNet-1

    -   Public IP address: Create New

    -   Public IP address name: VNet1GWIP

10. Click Create

11. Verify that the virtual network gateway appears in the list of virtual
    network gateways

## DEMO THREE: Azure Network Adapter for Windows Server 2019

Prerequisites: 
- Deploy Windows Server 2019 named fs-04-2019 and install Windows Admin Center. 
    - Windows Server 2019 Server is domain joined to tailtrade.internal domain.

### Instructions
1.	Sign on to Windows Admin Center using the administrator@tailtrade.internal domain admin account
2.	In All Connections, select fs-04-2012.tailtrade.internal.
3.	In the fs-04-2019.tailtrade.internal blade, click Network.
4.	In the Network blade, click Add Azure Network Adapter
5.	When prompted, click Register Windows Admin Center to Azure.
6.	On the Azure Integration page, click Register.
7.	On the Register the gateway with Azure page, click Copy Code and then click Device Login. This will open a new tab.
8.	On the new tab, paste the code from step 7 and then click Continue.
9.	On the sign in prompt, sign in with an account that has Owner permissions.
10.	Once signed in, switch back to the original tab. Ensure that the GUID of the tenant you wish to associate Windows Admin Center is selected and click Register.
11.	Right click on the link “Go to the Azure AD App Registration” link and open it in a new tab. This will open a page linked to the app that will allow for Windows Admin Center to be registered with Azure AD.
12.	In the Azure AD App’s Azure Console page, click Settings and in the settings blade click Required Permissions.
13.	Click Grant Permissions and then click Yes.
14.	Switch back to the Windows Admin Center page and click Close under Register the gateway with Azure.
15.	Click Windows Admin Center, click fs-04-2019.tailtrade.internal and then click Network.
16.	Click Add Azure Network Adapter
17.	In the Add Azure Network Adapter page, select the Subscription, Location, and Virtual Network that you wish to associate with Azure Network Adapter.
18.	Use the default gateway subnet option, SKU settings and VPN settings and click Create.
19.	In approximately half an hour, a new VPN connection will exist between the server and the Azure VNet.

## DEMO FOUR: Azure File Sync

Prerequisites:

-   Domain Controller. DC.tailwind.internal

-   FS-01.tailwind.internal: Two volumes, C: and E:

    -   e:\\TailDocs is empty

-   FS-02.tailwind.internal: Two volumes, C: and E:

    -   e:\\TailDocs contains three subfolders, Folder-1, Folder-2 and Folder-3

### Instructions
1.  In the Azure search bar, type file sync.

2.  Click on File Sync

3.  On the Deploy Storage Sync page, provide the following information:

    -   Name: TailTradeFilesync

    -   Resource Group: TailTrade-RG

    -   Region: Same region used for all previous demonstrations

4.  Click Create.

5.  On FS-01, perform the following steps

    -   Download and install the Azure File Sync agent.
        <https://go.microsoft.com/fwlink/?linkid=858257>

    -   Sign in using an account that has Owner permission in the Azure
        subscription that hosts the File Sync Service

    -   Select the TailTrade-RG resource group and TailTradeFileSync storage
        sync service and click Register

    -   Repeat these steps on FS-02

6.  In the Azure Portal search bar, type storage accounts

7.  In the Storage Accounts blade, click Add

8.  On the Create Storage Account blade, provide the following details:

    -   Resource group: TailTrade-RG

    -   Storage account name: TailTradeSG

    -   Region: Same region used for all previous demonstrations

9.  Click Review and Create

10. After validation completes, click Create.

11. After creation completes, navigate to the TailTradeSG storage account.

12. Under Services, click Files.

13. In the Files blade, click new File Share.

14. Enter the name Taildocs and click Create.

15. In the Storage Sync Services blade, click ON TailTradeFileSync

16. In the TailTradeFileSync blade, click new Sync Group.

17. In the Sync Group blade, provide the following information

    -   Sync group name: Syncdocs

    -   Storage Account: TailTradeSG

    -   Azure File Share: taildocs

18. Click Create.

19. Switch to FS-2.

20. On the data volume, E:, view the e:\\TailDocs folder and validate that it
    contains three subfolders, Folder-1, Folder-2 and Folder-3.

21. Switch to FS-1

22. On the data volume, E:, view the e:\\TailDocs folder and validate that it
    contains no subfolders.

23. In the Azure portal, in the TailTradeFileSync storage sync service, click
    Sync Groups and then click TailDocs.

24. In the TailDocs sync group, click Add Server Endpoint. From the dropdown,
    ensure that you select FS-2.tailtrade.internal.

25. Specify the path as E:\\TailDocs

26. Set Cloud Tiering to Enabled and the Volume Free Space to 50%

27. Click Create.

28. Wait until the Health status of server FS-2.tailtrade.internal switches from
    Pending to the green checkmark.

29. Click on the taildocs Azure File Share under Cloud Endpoints, then click the
    tailtrades storage account. This will open the storage account properties.
    Click Files and then click the taildocs file share. Verify that Folder-1,
    Folder-2, and Folder-3 are now present.

30. Navigate back to the TailDocs sync group, click Add Server Endpoint. From
    the dropdown, ensure that you select FS-1.tailtrade.internal

31. Specify the path as E:\\TailDocs

32. Set Cloud Tiering to Enabled and the Volume Free Space to 50%

33. Click Create.

34. Wait until the Health status of server FS-1.tailtrade.internal switches from
    Pending to the green checkmark.

35. Switch to FS-01 and verify that Folder-1, Folder-2 and Folder-3 are now
    present in e:\\TailDocs. Create a new folder called Folder-4

36. Switch to FS-02 and click refresh. Note the creation of Folder-4. Create a
    new folder named Folder-5. Switch to FS-01 and verify that Folder-05
    appears.

## Teardown Instructions

To remove the demos from your environment, delete the Resource Group TailTrade-RG.

## Learn More/Resources

[Connect an on-premises network to Azure](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Azure VPN Gateway](https://docs.microsoft.com/en-us/azure/vpn-gateway/?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Outbound connections in Azure](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Azure File Sync](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-deployment-guide?tabs=portal?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Azure Site-to-Site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal?WT.mc_id=MSIgniteTheTour-github-hyb10)
