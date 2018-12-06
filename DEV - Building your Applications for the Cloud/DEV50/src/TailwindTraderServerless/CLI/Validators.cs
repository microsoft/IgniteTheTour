using DataAccess;
using Model;
using Notifications;
using System.Linq;

namespace CLI
{
    public class Validators : IValidate
    {
        private readonly IValidate[] validators = new IValidate[]
        {
            new StorageValidator(),
            new EventValidator()
        };

        public bool Validate()
        {
            return validators.All(v => v.Validate());
        }
    }
}
