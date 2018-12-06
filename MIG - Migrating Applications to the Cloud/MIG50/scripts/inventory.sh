#!/bin/bash
set -eou pipefail

cd src/inventory-service/InventoryService.Api
dotnet user-secrets set 'ConnectionStrings:InventoryContext' "$DOTNET_CONNECTION"
dotnet run
