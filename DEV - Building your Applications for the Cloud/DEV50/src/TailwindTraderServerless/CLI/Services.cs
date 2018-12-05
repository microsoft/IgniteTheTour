using DataAccess;
using Model;
using Notifications;

namespace CLI
{
    // cheap and easy dependency injection
    public static class Services
    {
        public static IInventoryAccess InventoryAccess { get; } = new StorageAccess();
        public static IEventPublisher EventPublisher { get; } = new EventGridPublisher();
        public static IValidate Validator { get; } = new Validators();
    }
}
