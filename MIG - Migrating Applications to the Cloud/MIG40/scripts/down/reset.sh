#!/usr/bin/env bash

source ./scripts/variables.sh

# apps
scripts/down/apps.sh

# func app
az functionapp delete -g $(rgfunc) -n $(funcname)
make funcsetup