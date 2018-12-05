# SRE10 - Modernizing your infrastructure: moving to Infrastructure as Code

Deploying applications to the cloud can be as simple as clicking the mouse a few times and running "git push". The applications running at Tailwind Traders, however, are quite a bit more complex and, correspondingly, so are our deployments. The only way that we can reliably deploy complex applications (such as our sales and fulfillment system) is to automate it.

In this module, you'll learn how Tailwind Traders uses automation with Azure Resource Management (ARM) templates to provision infrastructure, reducing the chances of errors and inconsistency caused by manual point and click. Once in place, we move on to deploying our applications using continuous integration and continuous delivery, powered by Azure DevOps.

## Setting up a demo environment

*In Azure CloudShell*

Note: the git commands below require some auth setup, see [Appendix A](#AppendixA) at the end of this document.

### Get the code

```
mkdir ~/source
pushd ~/source

# This repo has all the setup scripts for SRE10 and application code
git clone https://dev.azure.com/ignite-tour-lp5/SRE10-Setup/_git/SRE10-Setup

# This repo has the database schema scripts
git clone https://github.com/Azure-Samples/tailwind-traders

```

### Set up the demo environment

By default, the scripts will set up a resource group named `SRE10-${CITY}-${APP_ENVIRONMENT}` so each person will have an individual standalone environment.

All of the naming parameters are defined in `./setup/0-params.sh`.

```
pushd ~/source/SRE10-Setup

# edit the parameters to meet your needs
code ./setup/0-params.sh

./setup.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file in `./setup/log` (e.g. for ./2-database.sh there will be a ./2-database.log).


### Clean up

```
cd ~
source ~/source/SRE10-Setup/setup/0-params.sh
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-dev" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-uat" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-prod" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-dev" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-uat" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-prod" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-manualdeploy" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-templatedeploy" --yes --no-wait

rm ~/source/SRE10-Setup/setup/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/SRE10-Setup
```

### Profit

### <a name="AppendixA"></a>Appendix A: git auth
During the period of time where the code for this demo env lives in private repos, there are two separate sets of git auth that have to be set up a single time:

1. auth for dev.azure.com: create alternative credentials.
This can be performed by going to the dev.azure.com page for the repos (https://dev.azure.com/ignite-tour-lp5/_git/SRE10-Setup), clicking on _Clone_, filling out the bottom half of the form and choosing "Save Git Credentials". 
For more information, [see the Azure DevOps documentation](https://docs.microsoft.com/en-us/azure/devops/repos/git/auth-overview?WT.mc_id=msignitethetour-github-SRE10&view=vsts). Your alternative credentials ($USER@microsoft.com and the password you supplied) will be used for the git clone prompts.
1. auth for github.com: create a personal access token by choosing Settings->Developer settings->personal access tokens from the drop down menu under your picture on github.com (when logged in). When you create a person access token,
be sure to choose the "\[ \] repo Full control of private repositories" scope box. Note: you must also be a member of the Azure-Samples Organization for the repo to be accessible.
For more infomation on personal auth tokens see https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/. Your github username and the personal access token you created will be used for the git clone prompts.
