# SRE20 - Monitoring Your Infrastructure and Applications in Production

Tailwind Traders runs its entire business in the cloud and we need to understand what is happening with our cloud resources 24/7. To do that, we've implemented Microsoft Azure's monitoring solutions.

In this session, you'll learn how we use Azure Monitor to understand and visualize time series data using Application Insights and Log Analytics. We'll also monitor the health of our cloud services using Azure Service Health. With a more observable and data rich system Tailwind Trader’s engineers are now poised to know about, respond to, and resolve problems in real-time before they impact users and the business' bottom line.

## Services Used

- Azure Monitor – Log Analytics, 
- Azure Monitor – Application Insights, 
- Azure Service Health

## Setting up a demo environment

*In Azure CloudShell*

Note: the git commands below require some auth setup, see [Appendix A](#AppendixA) at the end of this document.

### Get the code

```
mkdir ~/source
pushd ~/source

# This repo has all the setup scripts for SRE20 and application code
git clone https://dev.azure.com/ignite-tour-lp5/SRE20-Setup/_git/SRE20-Setup

# This repo has the database schema scripts
git clone https://github.com/Azure-Samples/tailwind-traders

```

### Set up the demo environment

By default, the scripts will set up a resource group named `SRE20-${CITY}-${APP_ENVIRONMENT}` so each person will have an individual standalone environment.

All of the naming parameters are defined in `./setup/0-params.sh`.

```
pushd ~/source/SRE20-Setup

# edit the parameters to meet your needs
code ./setup/0-params.sh

./setup.sh

popd  

```

Output from each of the commands in the scripts can be found in a corresponding log file in `./setup/log` (e.g. for ./2-database.sh there will be a ./2-database.log).


### Clean up

```
cd ~
source ~/source/SRE20-Setup/setup/0-params.sh
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-prod" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-prod" --yes --no-wait

rm ~/source/SRE20-Setup/setup/.dbpass
rm -rf ~/source/tailwind-traders
rm -rf ~/source/SRE20-Setup
```

### Profit

### <a name="AppendixA"></a>Appendix A: git auth
During the period of time where the code for this demo env lives in private repos, there are two separate sets of git auth that have to be set up a single time:

1. auth for dev.azure.com: create alternative credentials.
This can be performed by going to the dev.azure.com page for the repos (https://dev.azure.com/ignite-tour-lp5/_git/SRE20-Setup), clicking on _Clone_, filling out the bottom half of the form and choosing "Save Git Credentials". 
For more information, [see the Azure DevOps documentation](https://docs.microsoft.com/en-us/azure/devops/repos/git/auth-overview?WT.mc_id=msignitethetour-github-SRE20&view=vsts). Your alternative credentials ($USER@microsoft.com and the password you supplied) will be used for the git clone prompts.
1. auth for github.com: create a personal access token by choosing Settings->Developer settings->personal access tokens from the drop down menu under your picture on github.com (when logged in). When you create a person access token,
be sure to choose the "\[ \] repo Full control of private repositories" scope box. Note: you must also be a member of the Azure-Samples Organization for the repo to be accessible.
For more infomation on personal auth tokens see https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/. Your github username and the personal access token you created will be used for the git clone prompts.
