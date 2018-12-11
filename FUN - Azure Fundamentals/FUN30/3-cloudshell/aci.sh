# Create Resource Group
az group create --name myACIDemo --location eastus

# Create container
az container create --resource-group myACIDemo --name mycontainer --image microsoft/aci-helloworld --dns-name-label aci-demo-007

# Get Public IP Address
echo "Container IP Address:"
echo $(az container list --query "[?contains(name, 'mycontainer')].[ipAddress.ip]" --output tsv)