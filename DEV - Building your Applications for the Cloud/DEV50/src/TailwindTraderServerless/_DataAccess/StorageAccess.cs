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
            var temp = new TableInventoryItem
            {
                Sku = sku
            };

            var operation = TableOperation.Retrieve<TableInventoryItem>(temp.PartitionKey, temp.RowKey);
            var result = await table.ExecuteAsync(operation);
            return result?.Result as IInventoryItem;
        }

        public async Task<IInventoryItem> NewSkuAsync(string sku)
        {
            throw new NotImplementedException();
        }

        public async Task SetHumanDescriptionAsync(string sku, string description)
        {
            throw new NotImplementedException();
        }

        public async Task SetImageAsync(string sku, Stream image)
        {
            throw new NotImplementedException();
        }

        public async Task SetPriceAsync(string sku, decimal price)
        {
            throw new NotImplementedException();
        }
    }
}
