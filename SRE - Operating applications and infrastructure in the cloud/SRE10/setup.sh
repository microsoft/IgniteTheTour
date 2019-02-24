#!/bin/bash
set -eo pipefail

pushd ./setup

declare -a app_env=("dev" "uat" "prod")

for i in "${app_env[@]}"
do
    export APP_ENVIRONMENT=$i
    echo "Setting up the ${APP_ENVIRONMENT} environment."
    echo ""

    ./1-resource_group.sh
    if [ $? != 0 ]; then
        echo "Failed to create resource groups.  Check ./setup/log/1-resource_group.log for more details."
        unset APP_ENVIRONMENT
        popd
        exit 1
    fi

    ./2-database.sh 
    if [ $? != 0 ]; then    
        echo "Failed to create the SQL database.  Check ./setup/log/2-database.log for more details."
        unset APP_ENVIRONMENT
        popd
        exit 1
    fi

    ./3-cosmos.sh 
    if [ $? != 0 ]; then        
        echo "Failed to create the CosmosDB environment.  Check ./setup/log/3-cosmos.log for more details."
        unset APP_ENVIRONMENT
        popd
        exit 1
    fi

    ./4-vault.sh
    if [ $? != 0 ]; then    
        echo "Failed to create the keyvault or application insights resources.  Check ./setup/log/4-vault.log for more details."
        unset APP_ENVIRONMENT
        popd
        exit 1
    fi

    echo ""
    echo "Finished setting up the ${APP_ENVIRONMENT} environment."
    echo ""
done

unset APP_ENVIRONMENT

popd

echo "You've now successfully configured your demo environment!"
echo "You rock!"
echo "Now go rock out on stage!!"
