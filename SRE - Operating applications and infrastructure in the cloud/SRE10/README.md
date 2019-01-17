# SRE10 - Modernizing your infrastructure: moving to Infrastructure as Code

Deploying applications to the cloud can be as simple as clicking the mouse a few times and running "git push". The applications running at Tailwind Traders, however, are quite a bit more complex and, correspondingly, so are our deployments. The only way that we can reliably deploy complex applications (such as our sales and fulfillment system) is to automate it.

In this module, you'll learn how Tailwind Traders uses automation with Azure Resource Management (ARM) templates to provision infrastructure, reducing the chances of errors and inconsistency caused by manual point and click. Once in place, we move on to deploying our applications using continuous integration and continuous delivery, powered by Azure DevOps.

## The demo environment

*In Azure CloudShell*

Note: the git commands below require some auth setup, see [Appendix A](#AppendixA) at the end of this document.

### Get the code

```
mkdir ~/source
pushd ~/source

# This repo has all the setup scripts for SRE10 and application code
git clone https://github.com/Microsoft/IgniteTheTour

# This repo has the database schema scripts
git clone https://github.com/Microsoft/TailwindTraders.git

```

### Set up the demo environment

By default, the scripts will set up a resource group named `SRE10-${CITY}-${APP_ENVIRONMENT}` so each person will have an individual standalone environment.

All of the naming parameters are defined in `./setup/0-params.sh`.

```
pushd ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE10

# edit the parameters to meet your needs
code ./setup/0-params.sh

./setup.sh

popd  

```

Do this once for each app environment - `dev`, `uat`, and `prod`.

Output from each of the commands in the scripts can be found in a corresponding log file in `./setup/log` (e.g. for ./2-database.sh there will be a ./2-database.log).

### Create the Azure DevOps Project

#### New Organization

* Open https://dev.azure.com
* Create a new organization
![Create new org](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_org.png)
![Name new org](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_org_name.png)

#### First Project

* Create the first project - name it `SRE10`

#### Authorize Azure Subscription

* Add a service connection for your Azure Subscription
![New service connection](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_service_connection.png)
![New ARM service connection](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_service_connection2.png)
![New ARM service connection detail](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_service_connection3.png)

#### Create KeyVault Mapping for Keys and Connection Strings

* Navigate to Azure Pipelines Library
![Azure Pipelines library](https://ignitethetour.blob.core.windows.net/assets/SRE10/pipelines_library.png)
* Create a new variable group
![Create new variable group](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_variable_group.png)
* Configure the variable group
    * Name
    * Link secrets to keyvault as variables
    * Subscription - use the subscription we've configured above
    * Pick the keyvault that was created in the setup script
    * Click Authorize
![Configure variable group](https://ignitethetour.blob.core.windows.net/assets/SRE10/authorize_keyvault.png)

* Add the variables from keyvault
![Add variable](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_variables.png)
![Add variable](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_variables2.png)

* Save the variable group.

#### Set up source code repos

* Create the repositories
  * `web-app-infra`
  * `frontend`
  * `product-service`
  * `inventory-service`

* Clone the setup repository to your local workstation

```
git clone https://github.com/Microsoft/IgniteTheTour
```

* Clone the empty repositories that we just set up to your local workstation

```
git clone https://dev.azure.com/modernops/SRE10/_git/inventory-service
git clone https://dev.azure.com/modernops/SRE10/_git/product-service
git clone https://dev.azure.com/modernops/SRE10/_git/frontend
git clone https://dev.azure.com/modernops/SRE10/_git/web-app-infra
```

* Stage starting content to the local repo

  * PowerShell

```
copy-item -recurse ./SRE10-Setup/demos/src/web-app-infra/* -destination ./web-app-infra/
copy-item -recurse ./SRE10-Setup/demos/src/frontend/* -destination ./frontend/
copy-item -recurse ./SRE10-Setup/demos/src/product-service/* -destination ./product-service/
copy-item -recurse ./SRE10-Setup/demos/src/inventory-service/* -destination ./inventory-service/
```

  * Bash

```
cp -r ./SRE10-Setup/demos/src/web-app-infra/* ./web-app-infra/
cp -r ./SRE10-Setup/demos/src/frontend/* ./frontend/
cp -r ./SRE10-Setup/demos/src/product-service/* -destination ./product-sevice/
cp -r ./SRE10-Setup/demos/src/inventory-service/* ./inventory-service/
```

* Change into each directory, commit, and push each of the repos up to Azure DevOps

```
git add .
git commit -m 'initial commit'
git push origin master
```

#### Create the build pipelines

* Open the Builds tab
![New build](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_build.png)
* Create the first build
![New build](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_build2.png)
* Set Azure Repos as the source location for the build
![New build location](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_build_location.png)
* Pick `web-app-infra` 
![New build location](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_build_location2.png)
* It should detect the `azure-pipelines.yml` in the repo 
![Existing build definition](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_build_location3.png)
* Run the build
![Run build](https://ignitethetour.blob.core.windows.net/assets/SRE10/run_new_build.png)
* Navigate back to the builds page via the breadcrumbs and add the other builds.
![Add more builds](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_more_builds.png)

#### Create the release pipelines

* Navigate to Azure Pipelines Releases
* Create the first release
![New Release Pipeline](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_release_pipeline.png)
* Use an empty template
![Empty template](https://ignitethetour.blob.core.windows.net/assets/SRE10/empty_job_release.png)
* Name the first stage `Dev`
![Name task](https://ignitethetour.blob.core.windows.net/assets/SRE10/name_release_task.png)
* Rename the release as `App Environment Release`
![Name release](https://ignitethetour.blob.core.windows.net/assets/SRE10/rename_release.png)
* Add an artifact to the release
![Add artifact](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_artifact_release.png)
* Configure the `source` as `web-app-infra`
* Configure the `Default version` as `Latest`
![Add artifact](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_artifact_release.png)
* Click "Add"
* Link the KeyVault mapped variables we created above to the release.
![Link the KeyVault mapped variables](https://ignitethetour.blob.core.windows.net/assets/SRE10/link_keyvault_to_release1.png)
![Link the KeyVault mapped variables](https://ignitethetour.blob.core.windows.net/assets/SRE10/link_keyvault_to_release1.png)
![Link the KeyVault mapped variables](https://ignitethetour.blob.core.windows.net/assets/SRE10/link_keyvault_to_release2.png)
* Open the "Dev" stage
![Open task detail](https://ignitethetour.blob.core.windows.net/assets/SRE10/open_task_detail.png)
* Add a task
![Add a task](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task1.png)
* Use the search to find the `Azure Resource Group Deployment` task
![Add a task](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task2.png)
* Configure the release task
  * Subscription can use the mapped service connection
  * Resource group name - `SRE10-app-berlin-dev`
  * Location - `West US 2`
![Configure the task](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task2.png)
  * Pick the template `template.json` from the published artifact location
![Select from artifact](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task4.png)
![Select from artifact](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task5.png)
  * Pick the parameters file `parameters.json` from the published artifact location
  * Select the `Complete` deployment mode
![Select from artifact](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task6.png)
  * Select Override Template Parameters
![Select override template parameters](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task7.png)
    * `appServicePlanName: "tw-svc-SRE10-dev"`
    * `frontendAppName: "tw-frontend-SRE10-dev"`
    * `inventoryServiceName: "tw-inventory-SRE10-dev"`
    * `sqlConnectionString: "$(InventoryContextSQL-dev)"`
    * `productServiceName: "tw-product-SRE10-dev"`
    * `cosmosConnectionString: "$(MongoConnectionString-dev)"`
![Select override template parameters detail](https://ignitethetour.blob.core.windows.net/assets/SRE10/add_azure_resource_group_task8.png)
* Save the release
* Navigate to the pipeline view and clone the Dev stage.
![Clone the dev task](https://ignitethetour.blob.core.windows.net/assets/SRE10/clone_task_release.png)
* Rename the stage `UAT` and update any references from `-dev` to `-uat`.  
* Check the following for needed replacements
  * Resource group
  * All of the template parameters
* Navigate to the pipeline view and clone the UAT stage.
* Rename the stage `Prod` and update any references from `-uat` to `-prod`.  
* Check the following for needed replacements
  * Resource group
  * All of the template parameters
* Navigate to the pipeline view and configure continuous deployment
![Configure continuous delivery](https://ignitethetour.blob.core.windows.net/assets/SRE10/configure_cd_release.png)
* Add approval to the Prod stage
![Configure continuous approval](https://ignitethetour.blob.core.windows.net/assets/SRE10/configure_release_approval.png)
![Configure continuous approval](https://ignitethetour.blob.core.windows.net/assets/SRE10/configure_release_approval2.png)
* Create the next release pipeline for the Inventory Service
![Next release pipeline](https://ignitethetour.blob.core.windows.net/assets/SRE10/new_release_pipeline2.png)
* Configure the artifact to pull from the Inventory Service build
* Configure continuous deployment
* Configure a dev stage to use the `Azure CLI` task 
    * Use `Inline Script`
    * Use the below CLI

```
az webapp deployment source config-zip --resource-group SRE10-app-berlin-dev --name tw-inventory-SRE10-dev --src ./_inventory-service/drop/InventoryService.Api.zip
```
* Copy the Dev stage and create a UAT stage.  
* Update the task script to use `-uat` instead of `-dev`
* Copy the UAT stage and create a Prod stage.  
* Update the task script to use `-prod` instead of `-uat`
* Save the release
* Create the next release pipeline for the Product Service
* Configure the artifact to pull from the Product Service build
* Configure continuous deployment
* Configure a dev stage to use the `Azure CLI` task 
    * Use `Inline Script`
    * Use the below CLI

```
az webapp deployment source config-zip --resource-group SRE10-app-berlin-dev --name tw-product-SRE10-dev --src ./_product-service/drop/ProductService.zip
```
* Copy the Dev stage and create a UAT stage.  
* Update the task script to use `-uat` instead of `-dev`
* Copy the UAT stage and create a Prod stage.  
* Update the task script to use `-prod` instead of `-uat`
* Save the release
* Create the next release pipeline for the Frontend App
* Configure the artifact to pull from the Frontend build
* Configure continuous deployment
* Configure a dev stage to use the `Azure CLI` task 
    * Use `Inline Script`
    * Use the below CLI

```
az webapp deployment source config-zip --resource-group SRE10-app-berlin-dev  --name tw-frontend-SRE10-dev  --src ./_frontend/drop/Frontend-dev.zip
```
* Copy the Dev stage and create a UAT stage.  
* Update the task script to use `-uat` instead of `-dev`
* Copy the UAT stage and create a Prod stage.  
* Update the task script to use `-prod` instead of `-uat`
* Save the release

## Running the Demos

### Provision Infra from the Portal

* Sign in to the Azure Portal - https://portal.azure.com
![Create a resource](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_resource.png)
* Click "Create a resource"
![Create a web app](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_web_app.png)
* Click "Web App"
![Web app details](https://ignitethetour.blob.core.windows.net/assets/SRE10/web_app_details1.png)
    * *1* Add an app name `SRE10-berlin-manualdeploy`
    * Ensure the subscription is `Ignite the Tour`
    * The resource group name should match the app name
    * *2* Change the OS to `Linux`
    * *3* Ensure publish is set to `Code`
    * *4* Set the runtime stack to `Node.js 8.11`
* Change the App Service plan to Create New
![App service plan](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_app_service1.png)
![App service plan](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_app_service2.png)
* Name the app service plan `SRE10-berlin-manualdeploy`
* Click OK
![Web app details](https://ignitethetour.blob.core.windows.net/assets/SRE10/web_app_details1.png)
* Click Create
* From the portal, select the resource group `SRE10-Berlin-manualdeploy`
* Show the created or creating web application
![Web app deployment](https://ignitethetour.blob.core.windows.net/assets/SRE10/web_app_deployment.png)
* Leave the portal open to this location for the next demo



### Provision Infra with an ARM Template

* In the resource group, click "Deployments"
![Web app deployment](https://ignitethetour.blob.core.windows.net/assets/SRE10/web_app_deployment.png)
* Click on the deployment
![Deployment list](https://ignitethetour.blob.core.windows.net/assets/SRE10/deployment_selection.png)
* Click on Template
![Deployment detail](https://ignitethetour.blob.core.windows.net/assets/SRE10/deployment_detail.png)
* This can give us a starting place to create our infrastructure as code.
* Open cloud shell ( https://shell.azure.com )
![CloudShell](https://ignitethetour.blob.core.windows.net/assets/SRE10/cloud_shell.png)
* In CloudShell, the below snippet will duplicate the deployment we created through the portal.

```
source ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE10/setup/0-params.sh
cd ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE10/demos/2-webapp_from_template
code .
sub=$(az account show --query id -o tsv)
./deploy.sh -i $sub -g SRE10-${CITY}-templatedeploy -n demo -l ${LOCATION}
```

* In the portal, show the deployed app service and plan
![Deployed template](https://ignitethetour.blob.core.windows.net/assets/SRE10/deployed_template.png)


### CI/CD for infrastructure

* In Visual Studio Code, open the git repository for the web app deployment `./SRE10/web-app-infra`
![Edit template in VS Code](https://ignitethetour.blob.core.windows.net/assets/SRE10/edit_template_vscode.png)
* Create a branch in VSCode
![Create branch in VS Code](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_branch_vscode.png)
* Edit template to add `sku` and `skuCode` parameters


```
"sku":{
    "type": "string",
    "defaultValue" : "PremiumV2",
    "metadata": {
        "description": "The SKU of App Service Plan "
    }
},
"skuCode":{
    "type": "string",
    "defaultValue" : "P1v2",
    "metadata": {
        "description": "The SKU of App Service Plan "
    }
},
```

* Delete the `sku` and `skuCode` variables.

```
    "variables": {
      "location": "[resourceGroup().location]",
      "sku": "PremiumV2",
      "skuCode": "P1v2"
    },
```

to

```
    "variables": {
      "location": "[resourceGroup().location]"
    },
```

* Edit the variable references for `sku` and `skuCode` to be parameter references

```
        "sku": {
          "Tier": "[variables('sku')]",
          "Name": "[variables('skuCode')]"
        },
```

to

```
        "sku": {
          "Tier": "[parameters('sku')]",
          "Name": "[parameters('skuCode')]"
        },
```

* Sync changes to origin 
![Stage change](https://ignitethetour.blob.core.windows.net/assets/SRE10/stage_change_vscode.png)
![Comment and commit](https://ignitethetour.blob.core.windows.net/assets/SRE10/comment_and_commit_vscode.png)
![Sync changes](https://ignitethetour.blob.core.windows.net/assets/SRE10/push_changes_vscode.png)

* Create PR
![Create pull request](https://ignitethetour.blob.core.windows.net/assets/SRE10/create_pull_request.png)
* Review and merge
![Approve pull request](https://ignitethetour.blob.core.windows.net/assets/SRE10/approve_pull_request.png)
![Complete pull request](https://ignitethetour.blob.core.windows.net/assets/SRE10/complete_pull_request.png)

* Build will validate the ARM template
* Release will deploy the template
* Talk about ARM deployment modes, incremental vs complete


### CI/CD for applications

* In Visual Studio Code, open the git repository for the web app deployment `./SRE10/frontend`
* Edit header on `src/index.html` to add the city to the header
![Edit index.html](https://ignitethetour.blob.core.windows.net/assets/SRE10/edit_index_html_vscode.png)

* Commit and push changes to master (for time).  We'd ideally follow a pull request process with code review for these changes as well.

## Cleaning up

```
cd ~
source ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE10/setup/0-params.sh
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-dev" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-uat" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-prod" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-dev" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-uat" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-prod" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-manualdeploy" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-templatedeploy" --yes --no-wait

rm ~/source/IgniteTheTour/SRE - Operating applications and infrastructure in the cloud/SRE10/setup/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/IgniteTheTour
```

### <a name="AppendixA"></a>Appendix A: git auth
During the period of time where the code for this demo env lives in private repos, there are two separate sets of git auth that have to be set up a single time:

1. auth for github.com: create a personal access token by choosing Settings->Developer settings->personal access tokens from the drop down menu under your picture on github.com (when logged in). When you create a person access token,
be sure to choose the "\[ \] repo Full control of private repositories" scope box. Note: you must also be a member of the Azure-Samples Organization for the repo to be accessible.
For more infomation on personal auth tokens see https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/. Your github username and the personal access token you created will be used for the git clone prompts.
