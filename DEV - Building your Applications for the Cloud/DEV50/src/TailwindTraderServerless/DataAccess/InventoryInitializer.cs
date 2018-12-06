using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Microsoft.WindowsAzure.Storage.Table;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace DataAccess
{
    public class InventoryInitializer
    {
        private readonly string[] skus = new[] { "2051", "2053", "2057", "2059", "2088" };

        private readonly string[] descriptions = new[]
        {
            "Bundled wires",
            "Black lantern",
            "Outlet with dial",
            "Paint roller",
            "Pliers"
        };

        public async Task InitAsync()
        {
            Console.WriteLine("Initializing inventory database...");
            var random = new Random();
            var dataAccess = new StorageAccess();
            await dataAccess.InitTableAsync();
            await dataAccess.InitBlobAsync();
            var table = dataAccess.table;
            var container = dataAccess.container;
            Console.WriteLine("Deleting old table...");
            await table.DeleteIfExistsAsync();
            var tableCreated = false;
            while (!tableCreated)
            {
                try
                {
                    tableCreated = await table.CreateIfNotExistsAsync();
                }
                catch (StorageException se)
                {
                    Console.WriteLine(se.Message);
                    Console.WriteLine("Waiting for table to be deleted. Trying again in 10 seconds...");
                    Thread.Sleep(10000);
                }
                catch
                {
                    throw;
                }
            }
            for (var idx = 0; idx < skus.Length; idx += 1)
            {
                var item = new TableInventoryItem
                {
                    Sku = skus[idx],
                    Price = random.Next(99, 100000)/100.0m,
                    ImageUrl = await LoadImageAsync(container, skus[idx]),
                    HumanDescription = descriptions[idx],
                    PriceSet = true,
                    DescriptionSet = true,
                    ImageSet = true,
                    IsActive = true
                };
                var operation = TableOperation.Insert(item);
                await table.ExecuteAsync(operation);
                Console.WriteLine($"Inserted sku {item.Sku}: {item.Description}");
            }            
        }

        private async Task<string> LoadImageAsync(CloudBlobContainer container, string sku)
        {
            string fileName = $"{sku}.jpg";
            var blob = container.GetBlockBlobReference(fileName);
            if (await blob.ExistsAsync())
            {
                Console.WriteLine($"{sku}.jpg already exists.");       
            }
            else
            {
                var directory = Directory.GetParent(Environment.CurrentDirectory);
                var inputPath = Path.Combine(directory.ToString(), fileName);
                if (File.Exists(inputPath))
                {
                    Console.WriteLine($"Uploading {sku}.jpg...");
                    await blob.UploadFromFileAsync(inputPath);
                    Console.WriteLine("Uploaded.");
                }
                else
                {
                    throw new Exception($"Can't find {inputPath}.");
                }
            }
            return blob.Uri.ToString();
        }
    }
}
