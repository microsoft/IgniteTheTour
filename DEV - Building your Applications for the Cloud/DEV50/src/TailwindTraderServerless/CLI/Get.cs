using DataAccess;
using System;
using System.Threading.Tasks;

namespace CLI
{
    public class Get
    {
        public async Task GetSkuAsync(string sku)
        {
            IInventoryAccess access = Services.InventoryAccess;
            var item = await access.GetAsync(sku);
            if (item == null)
            {
                Console.WriteLine($"Sku {sku} not found.");
            }
            else
            {
                Console.WriteLine("===");
                Console.WriteLine($"Sku {sku}: {item.Description}.");
                Console.WriteLine(item.DescriptionSet ? "(human validated description)" : "(description not validated)");
                if (item.PriceSet)
                {
                    Console.WriteLine($"Price: {item.Price.ToString("C")}");
                }
                else
                {
                    Console.WriteLine("Price not set.");
                }
                if (item.ImageSet)
                {
                    Console.WriteLine($"Image can be found at:\n{item.ImageUrl}");
                }
                else
                {
                    Console.WriteLine("Image not set.");
                }
                if (item.IsActive)
                {
                    Console.WriteLine("ITEM IS ACTIVE!");
                }
                else
                {
                    Console.WriteLine("This item is not yet active in the catalog.");
                }
                Console.WriteLine("===");
            }
        }

        public static void Sku(string sku)
        {
            var get = new Get();
            get.GetSkuAsync(sku).Wait();
        }
    }
}
