#!/usr/bin/env bash
set -eou pipefail
source ../../scripts/variables.sh
# install nodejs
#curl -sL https://deb.nodesource.com/setup_8.x | bash
#apt-get install -y nodejs && npm install

#curl ${FUNCTIONS_SETTINGS_GIST} > local.settings.json
cat RunCreateReport/function.json.example | sed "s/\"to\": \".*\"/\"to\": \"$EMAIL\"/g" > RunCreateReport/function.json
cat CreateReport/function.json.example | sed "s/\"to\": \".*\"/\"to\": \"$EMAIL\"/g" > CreateReport/function.json

func extensions install
prompt func azure functionapp publish $(funcname)
#func azure functionapp publish "function${RANDOM_STR}" --publish-local-settings --overwrite-settings
prompt curl "http://$(funcname).azurewebsites.net/api/RunCreateReport"
