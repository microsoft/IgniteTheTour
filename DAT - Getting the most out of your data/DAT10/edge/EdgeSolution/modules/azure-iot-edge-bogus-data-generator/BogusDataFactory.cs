// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Bogus;
using Bogus.DataSets;
using IoTEdgeBogusDataGenerator.Models;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace IoTEdgeBogusDataGenerator
{
    
    public class BogusDataFactory
    {
        static string connectionString = "Server=tcp:" 
        + Environment.GetEnvironmentVariable("sqlserver.name") + ".database.windows.net,1433;" 
        + "Initial Catalog=" + Environment.GetEnvironmentVariable("sqlserver.database") + ";Persist Security Info=False"
        + ";User ID=" + Environment.GetEnvironmentVariable("sqlserver.user")
        + ";Password=" + Environment.GetEnvironmentVariable("sqlserver.password")
        + ";MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

        static List<Item> ItemCatalog = new List<Item>();
        static List<string> Stores = new List<string>();

        static BogusDataFactory()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                // Connect to the database
                conn.Open();

                // Read rows
                SqlCommand selectCommand = new SqlCommand("SELECT sku, name, price FROM products", conn);
                SqlDataReader results = selectCommand.ExecuteReader();
                
                // Enumerate over the rows
                while(results.Read())
                {
                    ItemCatalog.Add(new Item{Sku  = results[0] as string, Name = results[1] as string, Price = Int32.Parse(results[2].ToString())});
                }

                selectCommand = new SqlCommand("SELECT name FROM stores", conn);
                results = selectCommand.ExecuteReader();

                while(results.Read())
                {
                    Stores.Add(results[0] as string);
                }
            }
        }
        public static Object CreateBogusData(int counter)
        {
            //Set the randomzier seed if you wish to generate repeatable data sets.
            Randomizer.Seed = new Random(counter);

            var testOrder = new Faker<Order>()
                //Ensure all properties have rules. By default, StrictMode is false
                //Set a global policy by using Faker.DefaultStrictMode
                .StrictMode(true)
                //OrderNumber is deterministic
                .RuleFor(o => o.OrderNumber, f => counter)
                //Generate Random GUID for PurchaseId
                .RuleFor(o => o.PurchaseId, f => Guid.NewGuid())
                //Pick a Random Store
                .RuleFor(o => o.StoreName, f => f.PickRandom(Stores))
                //Generate Fake Name
                .RuleFor(o => o.CustomerName, f => f.Name.FullName())
                //Generate Fake Email
                .RuleFor(o => o.Email, (f,o) => f.Internet.Email(o.CustomerName))
                //Generate Fake Address
                .RuleFor(o => o.ShippingAddress, f => f.Address.StreetAddress())
                //Get Fake Items
                .RuleFor(o => o.Items, f => GetFakeItems(f))
                //Get Amount Due
                .RuleFor(o => o.Amount_Due, (f,o) => GetAmountDue(o.Items))
                //Stamp with the current time
                .RuleFor(o => o.Timestamp, f => DateTime.UtcNow);

            return testOrder.Generate();
        }

        public static List<Item> GetFakeItems(Faker f)
        {
            List<Item> Items = new List<Item>();
            int numberOfItems = f.Random.Number(1,5);

            for(int i = 0; i < numberOfItems; i++)
            {
                var item = f.PickRandom(ItemCatalog);
                
                if(item.Name == "Screw")
                  {
                    Items.Add(new Item(){Sku = "TT2099" , Name = "Philips Head Screwdriver", Price = 2});
                    Console.WriteLine("Correlation Forced");
                  }  

                Items.Add(item);
            }

            return Items;
        }
        public static int GetAmountDue(List<Item> items)
        {
            int total = 0;

            foreach(var item in items)
            {
                total += item.Price;
            }

            return total;
        }
        
    }
}