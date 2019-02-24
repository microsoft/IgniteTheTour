# HYB20 - Securing Your Azure Environment

In this session you'll learn how to improve the security of privileged accounts used to manage Azure resources, manage software updates for both on-premises and cloud hosted virtual machines, and how to get the most out of Azure Security Center for assessing and remediating security configuration issues in a hybrid environment.  

## Services Used

- Privileged Identity Management
- Azure Software Updates
- Azure Security Center

## NOTE: 

All services created will incur usage costs that you, the replicator of the demo detailed below, will incur. Please be aware the you, the replicator of the demo detailed below, will be responsible for all costs associated in replicating, operating and maintaining this demonstration. Microsoft takes no responsibility of any costs incurred while replicating, operating and maintaining this demonstration. It is advised to turn off or terminate the replicated demonstration once completed to ensure incurred costs are kept to a minimum.  

## Demo
In order to perform the demos for this session, you will need to build out resources in your Azure subscription. Create the following resources before proceeding to the demo activities listed below.

## Demo Setup 

### Enable Azure Security Center
Follow [this quickstart](https://docs.microsoft.com/en-us/azure/security-center/security-center-get-started?WT.md_id=MSIgniteTheTour-github-hyb20) to enable Security Center in your tier.

**NOTE: This will enable a 60-day trial. After 60 days, you will incur a cost for running Azure Security Center.**

### Deploy VMs for demos
Two VMs are required for the deploys. These VMs can be deployed using the **Virus attack on Virtual Machines Scenario** located at https://aka.ms/virus-attack-prevention.

Click
 <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-VM-Virus-Attack-Prevention%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
To Deploy in your environment. 

- this deploys two VMs, one of which does not have Anti-Malware extensions installed.
- Leave all of the defaults.
- Enter an Administrator name and password of your choosing.

### Azure AD Premium P2 Required
Azure AD Premium P2 is required on the subscription. To check your subscription, check out [this article](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/subscription-requirements?WT.md_id=MSIgniteTheTour-github-hyb20).

### Create Demo Users
Two demo users, Don.funk and prime.admin, are needed for the demo. These are created in Azure AD using the following information:

- Don Funk
    - create as don.funk@ where @ is the subscription UPN suffix.
    - Enable Multi-Factor Authentication on account. Follow [this article for information on MFA](https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-getstarted?WT.md_id=MSIgniteTheTour-github-hyb20)
- Prime Admin
    - create as prime.admin@ where @ is the subscription UPN suffix.
    - Needs roles of
        - Global Admin Azure AD
        - Subscription Owner
For information on creating a user in Azure AD, check out [this article](https://blogs.msdn.microsoft.com/benjaminperkins/2017/10/11/add-a-new-user-to-my-azure-subscription/?WT.md_id=MSIgniteTheTour-github-hyb20).

### Set Up the Network for Azure Firewall
Azure Firewall requires the creation of a Resource Group and Virtual Network. Using the tutorial [Deploy and configure Azure Firewall using the Azure portal](https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal?WT.md_id=MSIgniteTheTour-github-hyb20), follow the **Set up the network** section ONLY. Do not complete **Deploy the firewall** as it will be done as part of the demo.

## DEMO ONE: Azure Security Center

### Prerequisites

- Requires that Azure Security Center already be enabled on the subscription. 

- Requires that two VMs be deployed

### Instructions

1.  In the Azure console, click Security Center.

2.  Under Resource Security Hygiene, click Recommendations.

3.  Review the list of recommendations for the subscription, discussing
    individual recommendations

4.  Click the recommendation “Install endpoint protection solution on virtual machines”

5.  Click Endpoint Protection not installed on Azure VMs

6.  Ensure VM-Without-EP is selected and then click Install on 1 VMs

7.  On the Select Endpoint Protection blade, click Microsoft Antimalware.

8.  On the Microsoft Antimalware blade, click Create.

9.  On the Install Microsoft Antimalware blade, review the defaults and then
    click OK.

10. Installation of Endpoint Protection will continue in the background, but
    will not complete during the demo.

11. Click Security Center, click Recommendations, and then click Apply a
    Just-In-Time network access control

12. Select both vm-with-ep and vm-without-ep and click Enable JIT on 2 VMs.

13. Review the JIT VM access configuration and click Save.

14. Wait for JIT VM configuration to be applied. Then, in Azure Security Center,
    under Advanced Cloud Defense, click Just in Time VM access. Verify that both
    VMs are listed as configured.

## DEMO TWO: Privileged Identity Management

### Prerequisites

-   Azure AD Premium P2 is enable on the subscription. 

-   Have created the don.funk\@ and prime.admin\@ user (the \@ indicates the
    subscription UPN suffix).

-   The don.funk\@ account is pre-configured for multi-factor authentication.

### Instructions

1.  In the Azure Console search bar, type Privileged Identity Management. Click
    on Privileged Identity Management.

2.  In the Privileged Identity Management Quick Start page, under Manage, click
    Azure AD Roles.

3.  On the Azure AD Roles – Overview page, click Roles.

4.  In the list of roles, scroll down and click the Password Administrator role.

5.  In the Password Administrator role blade, click Add Member.

6.  On the Add managed members page, click Select members.

7.  On the Select Members page, click don.funk\@ and click Select and then on
    the Add Managed Members page click OK.

8.  Click back to Azure AD Roles – Roles.

9.  Under Manage, click Settings.

10. On the Azure AD Roles – Settings page, click Roles.

11. On the list of Role blade, click the Password Administrator role.

12. On the Password Administrator role blade, configure the following settings:

    -   Activations. Scroll to demonstrate the maximum number of hours, then set
        the maximum activation duration at 0.5 hours.

    -   Enable notifications.

    -   Enable Incident/Request ticket.

    -   Enable Multi-Factor Authentication.

    -   Require Approval.

13. Click Select approvers, click prime.admin\@, and then click Select.

14. Under Password Administrator, click Save. Close the Password Administrator
    blade and then close the Roles blade.

15. Open a new private window and sign on as don.funk\@

16. In the Search bar, type Privileged Identity Management.

17. In Privileged Identity Management, click My Roles under Tasks.

18. Under Eligible Roles, click the Activate link next to Password
    Administrator.

19. As MFA is required for this role, you will need to click Verify your
    identity before proceeding. Click Verify my identity. This will force you to
    sign in as don.funk\@ using MFA.

20. Once MFA has been performed, click Activate.

21. On the Activation blade, provide the following information:

    -   Ticket Number: 12345

    -   Ticket System: TT TroubleTickets

    -   Activation Reason: Need to change user password.

22. Click Activate.

23. Switch to the window where you are signed on as prime.admin\@ whilst keeping
    the private window with the don.funk\@ account signed in also open

24. In Privileged Identity Management, click Approve Requests.

25. Click Refresh to view a list of pending approvals, select the Password
    Administrator role for Don Funk, and then click Approve.

26. On the Approve Selected Requests page, enter the reason “Approve Don’s
    Request to change user passwords” and then click Approve.

27. Switch back to the private windows with the don.funk\@ account signed in and
    click My Roles in Privileged Identity Management.

28. Verify that the status of the Password Administrator role is set to Access
    Valid.

## DEMO THREE: Azure Firewall

### Prerequisites

-   VNet named Test-FW-VN that uses the 10.0.0.0/16 address space and has the following subnets:

    -   AzureFirewallSubnet: 10.0.1.0/24

    -   Jump-SN: 10.0.3.0/24

    -   Workload-SN: 10.0.2.0/24

    -   Srv-Jump on Jump-SN. Has public IP address.

    -   Srv-Work on

### Instructions

1.  From the portal home page, click Create a resource.

2.  Click Networking, and after Featured, click See all.

3.  Click Firewall \> Create.

4.  On the Create a Firewall page, use the following to configure the firewall:

-   Name: Test-FW01

-   Subscription: \<your subscription\>

-   Resource group: Use existing: Test-FW-RG

-   Location: Select the same location that you used previously

-   Choose a virtual network: Use existing: Test-FW-VN

-   Public IP address: Create new. The Public IP address must be the Standard
    SKU type.

1.  Click Review + create.

2.  Review the summary, and then click Create to create the firewall. This will
    take a few minutes to deploy.

3.  After deployment completes, go to the Test-FW-RG resource group, and click
    the Test-FW01 firewall.

4.  Note the private IP address. You'll use it later when you create the default
    route.

5.  From the Azure portal home page, click All services.

6.  Under Networking, click Route tables.

7.  Click Add.

8.  For Name, type Firewall-route.

9.  For Subscription, select your subscription.

10. For Resource group, select Use existing, and select Test-FW-RG.

11. For Location, select the same location that you used previously.

12. Click Create.

13. Click Refresh, and then click the Firewall-route route table.

14. Click Subnets \> Associate.

15. Click Virtual network \> Test-FW-VN.

16. For Subnet, click Workload-SN. Make sure that you select only the
    Workload-SN subnet for this route, otherwise your firewall will not work
    correctly.

17. Click OK.

18. Click Routes \> Add.

19. For Route name, type FW-DG.

20. For Address prefix, type 0.0.0.0/0.

21. For Next hop type, select Virtual appliance. Azure Firewall is actually a
    managed service, but virtual appliance works in this situation.

22. For Next hop address, type the private IP address for the firewall that you
    noted previously.

23. Click OK. Open the Test-FW-RG, and click the Test-FW01 firewall.

24. On the Test-FW01 page, under Settings, click Rules.

25. Click the Application rule collection tab.

26. Click Add application rule collection.

27. For Name, type App-Coll01.

28. For Priority, type 200.

29. For Action, select Allow.

30. Under Rules, Target FQDNs, for Name, type AllowGH.

31. For Source Addresses, type 10.0.2.0/24.

32. For Protocol:port, type http, https.

33. For Target FQDNS, type github.com

34. Click Add.

35. Click the Network rule collection tab.

36. Click Add network rule collection.

37. For Name, type Net-Coll01.

38. For Priority, type 200.

39. For Action, select Allow.

40. Under Rules, for Name, type AllowDNS.

41. For Protocol, select UDP.

42. For Source Addresses, type 10.0.2.0/24.

43. For Destination address, type 209.244.0.3,209.244.0.4

44. For Destination Ports, type 53.

45. Click Add. From the Azure portal, open the Test-FW-RG resource group.

46. Click the network interface for the Srv-Work virtual machine.

47. Under Settings, click DNS servers.

48. Under DNS servers, click Custom.

49. Type 209.244.0.3 in the Add DNS server text box, and 209.244.0.4 in the next
    text box.

50. Click Save.

51. Restart the Srv-Work virtual machine.

52. From the Azure portal, review the network settings for the Srv-Work virtual
    machine and note the private IP address.

53. Connect a remote desktop to Srv-Jump virtual machine, and from there open a
    remote desktop connection to the Srv-Work private IP address.

54. Open Internet Explorer and browse to http://github.com.

55. Click OK \> Close on the security alerts. You should see the GitHub home
    page.

56. Browse to <http://www.bing.com>. You should be blocked by the firewall.

## DEMO FOUR: Azure Software Update

### Prerequisites

- The virtual machines that were deployed for Demo One.

### Instructions

1.  In the Azure Console, click Virtual Machines

2.  Click VM-With-EP

3.  Under Operations, click Update Management

4.  On the Update Management blade, click Enable for VMs in this subscription
    and then click Click to select machines to enable.

5.  On the Enable Update Management blade, select VM-with-EP and VM-without-EP
    and click Enable. After several minutes, both VMs will have their Update
    Management status listed as Already Enabled.

6.  Click Go to Update Management.

7.  Both VM-with-EP and VM-Without-EP will be listed as Non-Compliant.

8.  Click Missing Updates to review which updates are missing.

9.  Click Schedule Update Deployment.

10. On the New Update Deployment blade, enter the name TT-Update-A1 and ensure
    that the Windows operating system is selected.

11. Click Groups to update (Click to Configure).

12. On the Select Groups page, select the Subscription and resource group that
    hosts the VMs and click Add and then click OK.

13. Click Machines to Update (Click to Configure)

14. On the Type drop down, click Machines.

15. On the list of machines, click VM-with-EP and VM-without-EP to add them to
    the list of selected items and then click OK.

16. Click Schedule Settings (Click to Configure) and specify a schedule for the
    update deployment to occur. Click OK.

17. Click Create to create the update deployment.

## Teardown Steps

To remove these demos, you will need to do the following:

- Delete Test-FW-RG Resource Group
- Delete all VMs created
- Delete don.funk and prime.admin users
- If necessary, disable Azure Security Center

## Learn More/Resources

### Microsoft Learn

[Introduction to security in Azure](https://docs.microsoft.com/en-us/learn/modules/intro-to-security-in-azure/index?WT.mc_id=MSIgniteTheTour-github-HYB20)

[Top 5 security items to consider before pushing to production](https://docs.microsoft.com/en-us/learn/modules/top-5-security-items-to-consider/index?WT.mc_id=MSIgniteTheTour-github-HYB20)

### Microsoft Docs

[Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/?WT.mc_id=MSIgniteTheTour-github-HYB20)

[Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/?WT.mc_id=MSIgniteTheTour-github-HYB20) 

[Azure Software Update](https://docs.microsoft.com/en-us/azure/automation/automation-update-management?WT.mc_id=MSIgniteTheTour-github-HYB20
)

[Just In Time VM Access](https://docs.microsoft.com/en-us/azure/security-center/security-center-just-in-time?WT.mc_id=MSIgniteTheTour-github-HYB20)

[Secure Score](https://docs.microsoft.com/en-us/azure/security-center/security-center-secure-score?WT.mc_id=MSIgniteTheTour-github-HYB20
)

[Security Center Policies](https://docs.microsoft.com/en-us/azure/security-center/security-center-azure-policy?WT.mc_id=MSIgniteTheTour-github-HYB20
)

[Conditional Access Azure Management](https://docs.microsoft.com/en-us/azure/role-based-access-control/conditional-access-azure-management?WT.mc_id=MSIgniteTheTour-github-HYB20)

