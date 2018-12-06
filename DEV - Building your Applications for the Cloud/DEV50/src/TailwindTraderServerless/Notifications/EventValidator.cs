using Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace Notifications
{
    public class EventValidator : IValidate
    {
        public bool Validate()
        {
            // check for event grid endpoint
            var endpoint = Environment.GetEnvironmentVariable(Globals.PUBLISH_ENDPOINT);
            if (string.IsNullOrWhiteSpace(endpoint))
            {
                throw new Exception($"{Globals.PUBLISH_ENDPOINT} not found.");
            }

            // check for event grid key
            var key = Environment.GetEnvironmentVariable(Globals.PUBLISH_KEY);
            if (string.IsNullOrWhiteSpace(key))
            {
                throw new Exception($"{Globals.PUBLISH_KEY} not found.");
            }


            return true;
        }
    }
}
