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

## Teardown Instructions

To remove the demos from your environment, delete the Resource Group TailTrade-RG.

## Learn More/Resources

[Connect an on-premises network to Azure](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Azure VPN Gateway](https://docs.microsoft.com/en-us/azure/vpn-gateway/?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Outbound connections in Azure](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Azure File Sync](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-deployment-guide?tabs=portal?WT.mc_id=MSIgniteTheTour-github-hyb10)

[Azure Site-to-Site VPN](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal?WT.mc_id=MSIgniteTheTour-github-hyb10)
