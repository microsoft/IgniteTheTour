ssh -o StrictHostKeyChecking=no azureuser@MONGO_IP_ADDRESS 'bash -s' < mongoconfigure.sh
ssh -o StrictHostKeyChecking=no azureuser@INVENTORY_VM_IP_ADDRESS 'bash -s' < inventoryvmconfigure.sh
