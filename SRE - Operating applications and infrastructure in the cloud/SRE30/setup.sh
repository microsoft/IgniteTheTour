#!/bin/bash
set -eo pipefail

pushd ~/source/SRE30-Setup/setup

./1-resource_group.sh && ./2-database.sh && ./3-cosmos.sh && ./4-setup-apps.sh && ./5-deploy-apps.sh
