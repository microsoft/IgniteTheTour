#!/bin/bash
set -eo pipefail


declare -a app_env=("dev" "uat" "prod")

for i in "${app_env[@]}"
do
    export APP_ENVIRONMENT=$i
    echo "Cleaning up the ${APP_ENVIRONMENT} environment."
    echo ""
    
    source ~/source/SRE10-Setup/setup/0-params.sh
    az group delete -n $APP_RG --yes --no-wait

    echo "reconfiguring the resource groups for ${APP_ENVIRONMENT}."
    ./setup/1-resource_group.sh
done

# Clean out the resource groups from the first two demos.
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-manualdeploy" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-templatedeploy" --yes --no-wait

unset APP_ENVIRONMENT

echo "You've now successfully reset your demo environment!"
echo "Now, update your local system source control per the instructions."
