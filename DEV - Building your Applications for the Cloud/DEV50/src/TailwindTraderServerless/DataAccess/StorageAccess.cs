using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Microsoft.WindowsAzure.Storage.Table;
using Model;

namespace DataAccess
{
    public class StorageAccess : IInventoryAccess
    {
        public CloudStorageAccount storageAccount = null;
        public CloudTableClient tableClient = null;
        public CloudTable table = null;
        public CloudBlobClient blobClient = null;
        public CloudBlobContainer container = null;

        private void InitStorage()
        {
            if (storageAccount == null)
            {
                var storageConnection = Environment.GetEnvironmentVariable(Globals.STORAGE);
                storageAccount = CloudStorageAccount.Parse(storageConnection);
            }
        }

        public async Task InitTableAsync()
        {
            if (tableClient == null)
            {
                InitStorage();
                tableClient = storageAccount.CreateCloudTableClient();
            }
            table = tableClient.GetTableReference(Globals.TABLE);

            // Create the table if it doesn't exist.
            await table.CreateIfNotExistsAsync();
        }

        public async Task InitBlobAsync()
        {
            if (container == null)
            {
                blobClient = storageAccount.CreateCloudBlobClient();
                container = blobClient.GetContainerReference(Globals.CONTAINER);
                await container.CreateIfNotExistsAsync(
                    BlobContainerPublicAccessType.Blob,
                    null,
                    null);
            }
        }

        public async Task<IInventoryItem> GetAsync(string sku)
        {
            if (string.IsNullOrWhiteSpace(sku))
            {
                throw new ArgumentException("sku");
            }

            await InitTableAsync();
            var temp = TableInventoryItem.GenerateTemplateFromSku(sku);
            var operation = TableOperation.Retrieve<TableInventoryItem>(temp.PartitionKey, temp.RowKey);
            var result = await table.ExecuteAsync(operation);
            return result?.Result as IInventoryItem;
        }

        public async Task<IInventoryItem> NewSkuAsync(string sku)
        {
            if (string.IsNullOrWhiteSpace(sku))
            {
                throw new ArgumentException("sku");
            }
            await InitTableAsync();
            var newSku = new TableInventoryItem
            {
                Sku = sku
            };
            var operation = TableOperation.Insert(newSku);
            var result = await table.ExecuteAsync(operation);
            return newSku;
        }

        public async Task<IInventoryItem> SetHumanDescriptionAsync(string sku, string description)
        {
            await InitTableAsync();
            var item = await RequireAsync(sku);
            item.HumanDescription = description;
            item.DescriptionSet = true;
            await ReplaceAsync(item);
            return item;
        }

        public async Task<IInventoryItem> SetImageAsync(string sku, Stream image)
        {
            await InitTableAsync();
            await InitBlobAsync();
            var item = await RequireAsync(sku);
            string fileName = $"{sku}.jpg";
            var blob = container.GetBlockBlobReference(fileName);
            Console.WriteLine("Uploading image...");
            await blob.UploadFromStreamAsync(image);
            Console.WriteLine("Uploaded image. Updating sku...");
            item.ImageUrl = blob.Uri.ToString();
            item.ImageSet = true;
            await ReplaceAsync(item);
            return item;
        }

        public async Task<IInventoryItem> SetPriceAsync(string sku, decimal price)
        {
            await InitTableAsync();
            var item = await RequireAsync(sku);
            item.Price = price;
            item.PriceSet = true;
            await ReplaceAsync(item);
            return item;
        }

        private async Task<TableInventoryItem> RequireAsync(string sku)
        {
            if (!((await GetAsync(sku)) is TableInventoryItem item))
            {
                throw new Exception($"Sku {sku} not found.");
            }
            return item;
        }

        private async Task ReplaceAsync(TableInventoryItem item)
        {
            var operation = TableOperation.Replace(item);
            var result = await table.ExecuteAsync(operation);
        }
    }
}
