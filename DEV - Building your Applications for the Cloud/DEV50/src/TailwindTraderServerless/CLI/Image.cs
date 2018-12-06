using DataAccess;
using Notifications;
using System;
using System.IO;
using System.Threading.Tasks;

namespace CLI
{
    public class Image
    {
        public async Task ImageSkuAsync(string sku, string image)
        {
            var imagePath = Path.Combine(Environment.CurrentDirectory, image);
            if (!File.Exists(imagePath))
            {
                throw new Exception($"Image not found at path: {imagePath}.");
            }
            Console.WriteLine($"Adding image '{imagePath}' to SKU {sku}...");
            IInventoryAccess access = Services.InventoryAccess;
            var item = await access.SetImageAsync(sku, File.OpenRead(imagePath));
            Console.WriteLine($"Raising image event for {sku}...");
            IEventPublisher publisher = Services.EventPublisher;
            await publisher.RaiseEvent(Model.SkuMessageType.ImageSet, item);           
        }

        public static void Sku(string sku, string imgName)
        {
            var image = new Image();
            image.ImageSkuAsync(sku, imgName).Wait();
        }
    }
}
