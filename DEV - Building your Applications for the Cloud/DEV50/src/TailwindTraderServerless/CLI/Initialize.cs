using DataAccess;
using System;
using System.Threading.Tasks;

namespace CLI
{
    public class Initialize
    {
        public async Task InitializeAsync()
        {
            Console.WriteLine("WARNING! This task will delete any existing data.");
            Console.WriteLine("Type 'yes' to continue.");
            var response = Console.ReadLine();
            if (response.Trim().ToLowerInvariant() == "yes")
            {
                var initializer = new InventoryInitializer();
                await initializer.InitAsync();
            }
            else
            {
                Console.WriteLine("Aborted.");
            }
        }

        public static void Database()
        {
            var initialize = new Initialize();
            initialize.InitializeAsync().Wait();
        }
    }
}
