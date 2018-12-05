using Model;
using System.IO;
using System.Threading.Tasks;

namespace DataAccess
{
    public interface IInventoryAccess
    {
        Task<IInventoryItem> NewSkuAsync(string sku);
        Task<IInventoryItem> SetImageAsync(string sku, Stream image);
        Task<IInventoryItem> SetHumanDescriptionAsync(string sku, string description);
        Task<IInventoryItem> SetPriceAsync(string sku, decimal price);
        Task<IInventoryItem> GetAsync(string sku);
    }
}
