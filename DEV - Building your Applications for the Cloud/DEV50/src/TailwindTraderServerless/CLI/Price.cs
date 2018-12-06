using DataAccess;
using Notifications;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace CLI
{
    public class Price
    {
        public async Task PriceSkuAsync(string sku, string price)
        {
            if (decimal.TryParse(price, out decimal priceParsed))
            {
                Console.WriteLine($"Adding price '{priceParsed}' to SKU {sku}...");
                IInventoryAccess access = Services.InventoryAccess;
                var item = await access.SetPriceAsync(sku, priceParsed);
                Console.WriteLine($"Raising price event for {sku}...");
                IEventPublisher publisher = Services.EventPublisher;
                await publisher.RaiseEvent(Model.SkuMessageType.PriceSet, item);
            }
            else
            {
                throw new ArgumentException($"Unable to parse price {price} for sku {sku}.");
            }
        }

        public static void Sku(string sku, string newPrice)
        {
            var price = new Price();
            price.PriceSkuAsync(sku, newPrice).Wait();
        }
    }
}
