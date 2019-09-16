sudo usermod -aG docker azureuser

echo "Let's see if Docker is running..."
sudo docker version

sudo docker login -u REPLACE_CONTAINER_REGISTRY_USERNAME -p REPLACE_CONTAINER_REGISTRY_PASSWORD REPLACE_CONTAINER_REGISTRY_SERVER
sudo docker rm -f ignite-service
sudo docker pull REPLACE_CONTAINER_REGISTRY_SERVER/REPLACE_INVENTORY_IMAGE_NAME
sudo docker run --name ignite-service --restart always -d -p 8080:8080/tcp -e PORT=8080 -e CUSTOMCONNSTR_InventoryContext='Server=tcp:REPLACE_SQL_IP,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=REPLACE_SQL_USERNAME;Password=REPLACE_SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;' REPLACE_CONTAINER_REGISTRY_SERVER/REPLACE_INVENTORY_IMAGE_NAME
