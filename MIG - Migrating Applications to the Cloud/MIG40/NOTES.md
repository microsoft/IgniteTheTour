# Before Starting

All the variables that control resource naming are in scripts/variables.sh

The `base` variable is added to many of the others to name things.  

The default resource group name is `base` + `the username part of your az login`, 
eg: `mig50brketels` for the Azure user `brketels@microsoft.com`

All of the scripts to setup, configure, and tear down the demo are wrapped in a
Makefile with easy targets grouping them:
```make setup```

To run any of the scripts individually, source the scripts/variables.sh file first:
``` source ./scripts/variables.sh && ./scripts/up/secrets.sh```

# Install
#### Install https://www.microsoft.com/net/download
brew install npm
brew install jq
pip install azure-cli

brew tap azure/functions
brew install azure-functions-core-tools

brew install postgres #(no need to start services)
brew install mongodb #(no need to start services)

make setup

# Demo Docker
make docker
make acrbuild

# Demo Deploy
make deploy

# Demo KeyVault
make secrets
make deploy-secure

# Demo Functions
make funcdeploy