#!/usr/bin/env bash
set -eou pipefail
source ../../scripts/variables.sh

prompt func azure functionapp publish $(funcname)
prompt curl -v "http://$(funcname).azurewebsites.net/api/RunCreateReport"
