#!/usr/bin/env bash

source ./scripts/variables.sh

APP_SERVICE='app-service-linux'

WEB_APP_1='frontend-'$(rg)
az webapp delete \
    -g $(rg) \
    -n $WEB_APP_1

WEB_APP_2='inventory-service-'$(rg)
az webapp delete \
    -g $(rg) \
    -n $WEB_APP_2

WEB_APP_3='product-service-'$(rg)
az webapp delete \
    -g $(rg) \
    -n $WEB_APP_3

az appservice plan delete \
    -g $(rg) \
    -n $APP_SERVICE
