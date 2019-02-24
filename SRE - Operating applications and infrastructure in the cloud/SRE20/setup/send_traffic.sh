#!/bin/bash
set -eo pipefail

source ./0-params.sh

goodurl="https://${inv_app_name}.azurewebsites.net/api/inventory/2"
for i in `seq 1 86`;
do
    curl $goodurl
done  

badurl="https://${inv_app_name}.azurewebsites.net/api/inventory/test/2"
for i in `seq 1 14`;
do
    curl $badurl
done  
