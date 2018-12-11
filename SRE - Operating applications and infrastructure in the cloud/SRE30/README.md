# Microsoft Ignite | The Tour

## SRE30 - Diagnosing Failure in the Cloud

Tailwind Trader’s modern monitoring and alerting processes are working great. So great they have detected some issues with our application and how it is behaving in the cloud. It's time to make sense of what's going on and how to resolve trouble.
 
In this module, we will explore the processes and tools available to us to troubleshoot issues as they come up with running applications and infrastructure on Azure. Participants will gain exposure to querying log data found in Log Analytics as well as what to look for within Application Insights and Network Monitor to lead engineers to understanding and solving problems quickly.


## Setting up a demo environment

*In Azure CloudShell*

Note: the git commands below require some auth setup, see [Appendix A](#AppendixA) at the end of this document.

### Get the code

```
mkdir ~/source
pushd ~/source

# This repo has all the setup scripts for SRE30 and application code
git clone https://github.com/Microsoft/IgniteTheTour

# This repo has the database schema scripts
git clone https://github.com/Azure-Samples/tailwind-traders

```

### Set up the demo environment

By default, the scripts will set up a resource group named `SRE30-${CITY}-${APP_ENVIRONMENT}` so each person will have an individual standalone environment.

All of the naming parameters are defined in `./setup/0-params.sh`.

```
pushd ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30

# edit the parameters to meet your needs
code ./setup/0-params.sh

./setup.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file in `./setup/log` (e.g. for ./2-database.sh there will be a ./2-database.log).

### Generate traffic to app for demo

*NOTE:* If you want some good graphs, do this at several points before the talk and vary the number of requests.

In CloudShell, we will generate some traffic against one of the backend services.

Some good traffic

```
source ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30/setup/0-params.sh 
goodurl="https://${inv_app_name}.azurewebsites.net/api/inventory/2"
for i in `seq 1 86`;
do
    curl $goodurl
done  
```

and some bad traffic

```
source ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30/setup/0-params.sh 
badurl="https://${inv_app_name}.azurewebsites.net/api/inventory/test/2"
for i in `seq 1 14`;
do
    curl $badurl
done  
```

Also, visit https://tw-frontend-sre30-${city}-prod.azurewebsites.net/index.html a few times.

### Create the Troubleshooting Guide

* Open `the `inv-tw-insights-SRE30-$CITY-prod` resource
![Troubleshooting Guide](https://ignitethetour.blob.core.windows.net/assets/SRE30/troubleshooting_guide.png)
* Open the "Request Failures"
![Troubleshooting Guide](https://ignitethetour.blob.core.windows.net/assets/SRE30/new_guide.png)
*  Choose "Edit"
* Edit the text box that says "Failure Trend"

```
## Service Level Objective - 90% Sucessful Requests

Successful Requests / Total Requests

As measured at the app service.

The chart below shows the trend of successful requests against the objective 
```

* Edit the chart. 
  * Replace the query with the below
  * Run the query

```
requests
| where timestamp > ago(30d)
| summarize succeed = count (success == true), failed = count (success == false), total = count() by bin(timestamp, 1h)
| extend SLI = succeed * 100.00 / total 
| extend SLO = 90.0
| project SLI, timestamp, SLO 
| render timechart  
```
  * Change the Visualization to Line chart
  * Change the legend to Maximum Value
* Save the changes
  * Make the title `SLO Example`
  * Save
* Click Done editing

### Break the database connection

```
pushd ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30/demos/
./break_datase_config.sh
popd
```

## Running the Demo

### Setting Up Health Alerts

* Sign in to portal.azure.com
* Go to "Monitor"
![Azure Monitor](https://ignitethetour.blob.core.windows.net/assets/SRE30/monitor.png)
* Select "Service Health"
![Service Health](https://ignitethetour.blob.core.windows.net/assets/SRE30/service_health.png)
* Select "Health Alerts"
![Health Alerts](https://ignitethetour.blob.core.windows.net/assets/SRE30/health_alerts.png)
* Select "Create service health alert"
  * Set up alert target
![Alert Target](https://ignitethetour.blob.core.windows.net/assets/SRE30/alert_target.png)
  * Set up action group
    * Name
    * Short name
    * Subscription
    * Add a new action
      * Action Name
      * Action Type
      * Click on Edit Details to add an email address
![Action Group](https://ignitethetour.blob.core.windows.net/assets/SRE30/action_group.png)
  * Define Alert Details
    * Name the alert
    * Give it a description
    * Save the alert to a resource group
    * Click "Create alert rule"
![Alert Details](https://ignitethetour.blob.core.windows.net/assets/SRE30/alert_details.png)
![Alert Details](https://ignitethetour.blob.core.windows.net/assets/SRE30/alert_created.png)

### Show an Application Map

* In the Azure Portal, open up the `SRE30-app-$CITY-prod` resource group
* Under Monitoring, click "Insights (preview)"
![Resource Group Monitoring](https://ignitethetour.blob.core.windows.net/assets/SRE30/resource_group_monitoring.png)
* Click Application Map (you might have to scroll down)
![Show Application Map](https://ignitethetour.blob.core.windows.net/assets/SRE30/application_map.png)

### Live Debugging with Log Streaming

* Navigate to https://tw-frontend-SRE30-berlin-prod.azurewebsites.net/index.html
* Try to add an item to the inventory
* Open the portal and navigate to `SRE30-app-$CITY-prod` resource group
* Open the `tw-inventory-SRE30-$CITY-prod` app service
* Open the live log stream
![Log stream](https://ignitethetour.blob.core.windows.net/assets/SRE30/log_stream.png)
* Highlight the error
> Unhandled Exception: System.Data.SqlClient.SqlException: A connection was successfully established with the server, but then an error occurred during the login process. 
* In CloudShell

```
pushd ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30/demos/
./fix_datase_config.sh
popd
```
* Navigate to https://tw-frontend-SRE30-berlin-prod.azurewebsites.net/index.html
* Try to add an item to the inventory

### Troubleshooting Guides

* Open `the `inv-tw-insights-SRE30-$CITY-prod` resource
![Troubleshooting Guide](https://ignitethetour.blob.core.windows.net/assets/SRE30/troubleshooting_guide.png)
* Open "Workbooks" and scroll through the default templates.
* Pick "Performance Analysis
![Perf Analysis](https://ignitethetour.blob.core.windows.net/assets/SRE30/perf_analysis.png)
* Scroll through the report.
* Choose edit
![workbook](https://ignitethetour.blob.core.windows.net/assets/SRE30/workbook.png)
* Open of few of the existing bits of the report
  * Show the markdown
  * Show parameters
![parameters](https://ignitethetour.blob.core.windows.net/assets/SRE30/parameters.png)
  * Show the query builder backing the graphs
![query](https://ignitethetour.blob.core.windows.net/assets/SRE30/query.png)
* Click "Done Editing"
* Click Troubleshooting Guide
* Open the SLO example
![query](https://ignitethetour.blob.core.windows.net/assets/SRE30/guide_with_sample.png)
* Explore the guide
  * Show the query
  * Explain 
    * extend (SLI and SLO)
    * project

## Clean up

```
cd ~
source ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30/setup/0-params.sh
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-prod" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-prod" --yes --no-wait

rm ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE30/setup/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/IgniteTheTour
```

### Profit

### <a name="AppendixA"></a>Appendix A: git auth
During the period of time where the code for this demo env lives in private repos, there are two separate sets of git auth that have to be set up a single time:

1. auth for github.com: create a personal access token by choosing Settings->Developer settings->personal access tokens from the drop down menu under your picture on github.com (when logged in). When you create a person access token,
be sure to choose the "\[ \] repo Full control of private repositories" scope box. Note: you must also be a member of the Azure-Samples Organization for the repo to be accessible.
For more infomation on personal auth tokens see https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/. Your github username and the personal access token you created will be used for the git clone prompts.
