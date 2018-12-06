read -p 'Resource group name: ' RESOURCE_GROUP_NAME

printf "\n*** About to delete everything in $RESOURCE_GROUP_NAME ***\n"

az group delete -g $RESOURCE_GROUP_NAME -y --no-wait