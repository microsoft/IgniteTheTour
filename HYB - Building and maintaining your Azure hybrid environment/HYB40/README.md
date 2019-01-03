# HYB40 - Governing Your Azure Environment

In this session you’ll learn how Tailwind Traders maps their organizational structure and business requirements to an Enterprise Scaffold, to govern their Cloud resources. You’ll see how Azure Policy and Role Based Access control are used to control resource configuration and access. In addition, you’ll learn how Azure Blueprints combines these settings, enforcing governance across your entire Azure tenancy.

## Services Used

- Azure Policy
- Role Based Access Control
- Azure Blueprints

## NOTE: 

All services created will incur usage costs that you, the replicator of the demo detailed below, will incur. Please be aware the you, the replicator of the demo detailed below, will be responsible for all costs associated in replicating, operating and maintaining this demonstration. Microsoft takes no responsibility of any costs incurred while replicating, operating and maintaining this demonstration. It is advised to turn off or terminate the replicated demonstration once completed to ensure incurred costs are kept to a minimum.  

## Demo Prerequisites

### Create Azure Policy artifacts and configure 

*Note:This demo shows two different subscriptions added to one management group. If you are unable to create an additional subscription, you can run through these demo steps with only one single subscription in the management group.*

- Create one subscription named TT-Prod-Paragon
    
-   Create one subscription named TT-Test-Paragon
    
-   Create a Management Group with ID= TWT-HYB40 and display name TWT-HYB40-MG
    
-   In the TWT-HYB40-MG Management Group, add the TT-Prod-Paragon and
        TT-Test-Paragon subscriptions.
    
-  Creating the following Resource Groups:

    -   48015P-Paragon-RG

    -   90210P-Paragon-RG

    -   48015T-Paragon-RG

    -   90210T-Paragon-RG

### Create RBAC artefacts and configure:* 

-   Create Azure AD Group (Security groups) 
    
    -   IT_NetAdmin
    
-   Create an Azure AD user:
    
    -   Steve Lamb (Steve.L\@… ) and add to IT_NetAdmin group
    
-   To begin demos, login to both portal.azure.com and shell.azure.com with your account attached to your Azure subscription.

## Demo Instructions

### Demo 1 – Create policy initiative to limit storage & VM creation by SKUs 

*In this demo, we show how to enforce that all storage & VMs created in
    either of the two subscriptions must conform to the allowed SKUs, using a
    policy initiative added to the management group.*

-   *Verify Subscriptions*
    - In the Azure portal, Click on Management Groups and the TWT-HYB40-MG magement group to verify you have the needed subscriptions of TT-Prod-Paragon and TT-Test-Paragon

-   *Add Policy Initiative of allowed Storage and VM SKUs*

    -   Click on Policy, then Definitions
    
    -   Click Definition type and select Initiative 
    
    -   Click on + Initiative definition
    
        -    Select the Definition location by clicking on the 3 dots then selecting
            TWT-HYB40-MG. This is where the definition will live.
        
        -   Enter the name as TT-CostControl and the description Prevent expensive
            resource creation by limiting storage and VM SKUs
        
        -   Leave the Category as Create new and enter the category name as Custom-Cost
        
        -   On the right-hand side, under the Available Definitions, click in the search
            box and type SKU. Two policy definitions will appear (Allowed storage
            account SKUs and Allowed virtual machine SKUs).
        
        -   Click on the Allowed storage account SKUs then click + Add
        
        -   Now you need to click on the Parameter name Allowed SKUs box that says 0
            selected. It will show nothing in the drop down, so you have to click on the
            blue button with 3 dots, note the management group showing and select a
            subscription. Explain that some policies do not pre-populate the value
            selection box. Choosing a subscription tells the policy where to read from
            to get a list of possible values. It does NOT assign the policy to the
            subscription.
        
        -   Now you can click back in the 0 selected box and chose your allowed SKUs (eg
            Standard_LRS (locally redundant storage) and Standard_ZRS (zone redundant
            storage))
        
        -   On the right side in the Available Definitions pane, click the Allowed
            virtual machine SKUs, then click + Add
        
        -   Now you need to click on the Parameter name Allowed SKUs box that says 0
            selected. It will show nothing in the drop down, so you have to click on the
            blue button with 3 dots, note the management group showing and select a
            subscription.
        
        -   Now you can click back in the 0 selected box and chose your allowed SKUs (eg
            Standard_D1, Standard_D2, Standard_D3, Standard_D4)
        
        -   Then click Save

- *Assign Policy Definition*

    -   Click on Assignments, then next to the Scope box, click on the 3 dots.
    
    -   Select the TWT-HYB40-MG and click Select. 
    
    -   Click the Assign initiative button.
    
    -   Next to the Intiative definition box, click the blue dots.
    
    -   In the Search box, type cost then select the TT-CostControl initiative, then
        click the Select button.
    
    -   Click Assign
    
    -   Explain that it takes 30mins to apply
    
    -   Click the Policy Overview blade and show our TT-CostControl initiative with
        a compliance status of Not started.

### Demo 2 – Policy VM Create Fail Portal**

*Create a new VM that is out of policy. This will show what the failure looks like when creating a disallowed VM via the portal.*

-   *See failure because of enforcement of Allowed SKUs policy:* 

    -   In the Virtual Machines pane, click Add
    
    -   Select the TT-Test-Paragon subscription and the 90210-Paragon-RG resource
        group
    
    -   Enter the VM name ParaT-90210VM
    
    -   Set the Region to East US
    
    -   Change the image to Windows Server 2016 Datacenter
    
        -   Click on Change size
    
        -   Type e in the search by VM size box and scroll down the list
    
            -   Explain that e series VMs can get very expensive, including over \$5,000
                a month
        
            -   Select the E64-16s_v3 machine and click Select
        
        -   Enter the Administrator account Username “TWTAdmin”
        
        -   Choose your own 12char complex password and enter it twice
        
        -   Leave at no public inbound ports
        
        -   Click Review + Create
                
        -   Click on Click here to view details
                
        -   Click on link to the Policy (Allowed virtual machine SKUs in blue)
        
### Demo 3 – Policy VM Create Fail Cloud Shell

*Show what the failure looks like if someone tries to create a disallowed VM*

-   *Show Cloud shell subscription context*

    -   Switch to the shell.azure.com window in your browser

    -   Type **get-AzureRMContext.**

    -   Type **Select-AzureRMSubscription -SubscriptionName TT-Prod-Paragon**

    -   Type **clear screen**

-   *Create a large VM in Cloud shell and see it fail*

    -   Type **New-AzVm -ResourceGroupName "90210P-Paragon-RG" -Name
        "ParagonP90210VM”-image “win2016datacenter” -Size "Standard_E64_v3"**

    -   Enter username TWTAdmin then your own Password

    -   Then see red build error meaning the build fail due to the policy created

    -   Click the 90210P-Paragon-RG
        - Even though the VM size was disallowed, the
        command did create the network interface, virtual network etc. There is
        no pre-creation validation in Cloud shell, so you will need to clean up
        these resources afterwards.

### Demo 4 – Assign a Role Based Access Control

*In this demo, we assign a role based access control to a subscription so members of the IT_NetAdmin group can only see networking resources.*

-   *Show unrestricted access to Azure resources* 

    -   In the Azure portal, with your current admin account, click on All
        resources. 
    
-   *Add Network admin RBAC* 
    
    -   Click on Subscriptions then the TT-Prod-Paragon subscription.
    
    -   Click the Access control (IAM) blade.
    
    -   Explain this is where the RBAC settings live.
    
    -   Click + Add. 
    
    -   Click in the Role box and start typing net.
    
    -   Select the Network Contributor role.

    -   Select the IT_NetAdmin group. 
    
    -   Click Save.
    
    -   Click Azure Active Directory, Users, Steve Lamb to view user.
    
    -   Click Azure resources to view network resources will new permissions.

### Demo 5 – RBAC restricted user

*In this demo, we show how a user restricted by a role based access control can only see networking resources.*

-   *Show restricted RBAC enforcement* 

    -   Logged in as Steve Lamb, show the Azure Portal Dashboard showing all
        resources.
 
     -  Click Storage accounts, and note you cannot see storage account due to access restrictions.

### Demo 6 – Blueprint

*In this demo, you learn how to create and assign a Blueprint.

-   *Show Blueprint creation*

    -   Click Blueprints, then click Blueprint Definitions
    
    -   Click + Create Blueprint

        -   In Blueprint name, type TT-Compliance-BP 
        
        -   Blueprint description: Securing franchisee resources 
        
        -   In the Definition location, click the 3 dots then choose the TT-HYB40-MG
            management group. Click select.

    -   Click Next:Artifacts 
    
    -   Click Add artifact 
    
    -   Click the Artifact type dropdown
    
    -   Choose Policy Assignment in the drop down
    
    -   Click the Audit VMs that do not use managed disks policy, then click Add
    
    -   Click Add artifact 
    
    -   Click the Artifact type dropdown
    
    -   Choose Role Assignment in the drop down
    
    -   Click the Role box and type Net. Choose the Network Contributor role.
        
    -   Click Add 
    
    -   Click Add artifact … 
    
    -   Choose Resource Group from the drop down 
    
        -   Click Save Draft
        
        -   Right-click on the blueprint name and select Publish Blueprint
        
        -   Enter version number v1.0
                
        -   Then click Publish 
        
        -   Right click on the blueprint name then click Assign Blueprint 
        
        -   Click the Subscriptions drop down box and select the TT-Test-Paragon sub.
        
        -   Change the location to East US 
        
        -   Scroll down and show the Blueprint artifacts
        
## Teardown Steps
To teardown and remove the demos:
-   Delete the resource groups you created above
-   Unassign the Policy Initiative from the subscription
-   Delete the Policy Initiative definition
-   Delete the Role Based Accesss Control (IAM) from the TT-Prod-Paragon subscription
-   Unassign the Blueprint
-   Delete the Blueprint definition

## Learn More/Resources

### Microsoft Learn
[Secure your Azure resources with role-based access control (RBAC)](https://docs.microsoft.com/en-au/learn/modules/secure-azure-resources-with-rbac/index?WT.md_id=MSIgniteTheTour-github-hyb40)

### Microsoft Docs 
[Create and manage Azure Policy (requires Azure free trial)](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage?WT.md_id=MSIgniteTheTour-github-hyb40)

[Azure policy - how is it different from RBAC?](https://docs.microsoft.com/en-us/azure/governance/policy/overview?WT.md_id=MSIgniteTheTour-github-hyb40)

[GitHUb Azure Policy Repository](https://github.com/Azure/azure-policy)

