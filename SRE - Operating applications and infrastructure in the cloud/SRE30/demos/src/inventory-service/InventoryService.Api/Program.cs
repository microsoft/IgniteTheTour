using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using InventoryService.Api.Database;
using InventoryService.Api.Models;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace InventoryService.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = CreateWebHostBuilder(args).Build();
            using (var scope = host.Services.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<InventoryContext>();
                context.Database.Migrate();
                // make sure there is a user inserted (for SQL injection demo)
                if (context.SecretUsers.Count() == 0)
                {
                    context.SecretUsers.Add(new SecretUser
                    {
                        Username = "administrator",
                        Password = "MySuperSecr3tPassword!"
                    });
                    context.SaveChanges();
                }
            }
            host.Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)            
                .UseApplicationInsights()
                .UseStartup<Startup>();
    }
}
