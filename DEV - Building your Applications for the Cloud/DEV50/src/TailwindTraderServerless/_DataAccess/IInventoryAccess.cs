using Model;
using System.IO;
using System.Threading.Tasks;

namespace DataAccess
{
    public interface IInventoryAccess
    {
        Task<IInventoryItem> NewSkuAsync(string sku);
        Task SetImageAsync(string sku, Stream image);
        Task SetHumanDescriptionAsync(string sku, string description);
        Task SetPriceAsync(string sku, decimal price);
        Task<IInventoryItem> GetAsync(string sku);
    }
}
