using DataAccess;
using Notifications;
using System;
using System.Threading.Tasks;

namespace CLI
{
    public class Add
    {
        public async Task AddSkuAsync(string sku)
        {
            Console.WriteLine($"Adding SKU {sku}...");
            IInventoryAccess access = Services.InventoryAccess;
            var item = await access.NewSkuAsync(sku);
            Console.WriteLine($"Raising event for {sku}...");
            IEventPublisher publisher = Services.EventPublisher;
            await publisher.RaiseEvent(Model.SkuMessageType.Added, item);            
        }

        public static void Sku(string sku)
        {
            var add = new Add();
            add.AddSkuAsync(sku).Wait();
        }
    }
}
