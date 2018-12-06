using Model;
using System.Threading.Tasks;

namespace Notifications
{
    public interface IEventPublisher
    {
        Task RaiseEvent(SkuMessageType type, IInventoryItem item);
    }
}
