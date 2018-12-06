using DataAccess;
using Notifications;
using System;
using System.Threading.Tasks;

namespace CLI
{
    public class Describe
    {
        public async Task DescribeSkuAsync(string sku, string description)
        {
            Console.WriteLine($"Adding description '{description}' to SKU {sku}...");
            IInventoryAccess access = Services.InventoryAccess;
            var item = await access.SetHumanDescriptionAsync(sku, description);
            Console.WriteLine($"Raising describe event for {sku}...");
            IEventPublisher publisher = Services.EventPublisher;
            await publisher.RaiseEvent(Model.SkuMessageType.DescriptionSet, item);
        }

        public static void Sku(string sku, string description)
        {
            var describe = new Describe();
            describe.DescribeSkuAsync(sku, description).Wait();
        }

    }
}
