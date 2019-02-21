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
    az group delete -n $DB_RG --yes --no-wait
    az group delete -n $INSIGHTS_RG --yes --no-wait
done

# There is only one keyvault RG so, we don't have to loop over it.
az group delete -n $KEYVAULT_RG --yes --no-wait

# Clean out the resource groups from the first two demos.
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-manualdeploy" --yes --no-wait
az group delete -n "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-templatedeploy" --yes --no-wait

unset APP_ENVIRONMENT


echo "You've now successfully removed your demo environment!"
