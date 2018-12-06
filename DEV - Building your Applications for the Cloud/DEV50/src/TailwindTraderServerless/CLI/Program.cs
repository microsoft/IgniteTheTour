using System;
using System.Linq;

namespace CLI
{
    class Program
    {
        private static readonly string[] commands = new[] 
        {
            ParsedArgs.INIT,
            ParsedArgs.ADD,
            ParsedArgs.DESCRIBE,
            ParsedArgs.PRICE,
            ParsedArgs.IMAGE,
            ParsedArgs.GET
        };

        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("Tailwind Traders Command Line Tool");
                Console.WriteLine("Begin Verification.");

                Verify(args);

                Console.WriteLine("Secrets verified, processing request...");

                var parsedArgs = ParsedArgs.Parse(args);
                
                switch (parsedArgs.Command)
                {
                    case ParsedArgs.INIT:
                        Initialize.Database();
                        break;

                    case ParsedArgs.GET:
                        Get.Sku(parsedArgs.Sku);
                        break;

                    case ParsedArgs.ADD:
                        Add.Sku(parsedArgs.Sku);
                        break;

                    case ParsedArgs.DESCRIBE:
                        Describe.Sku(parsedArgs.Sku, parsedArgs.Target);
                        break;

                    case ParsedArgs.PRICE:
                        Price.Sku(parsedArgs.Sku, parsedArgs.Target);
                        break;

                    case ParsedArgs.IMAGE:
                        Image.Sku(parsedArgs.Sku, parsedArgs.Target);
                        break;
                }
                Console.WriteLine("Success!");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }

        // "Fail fast"
        static void Verify(string[] args)
        {
            if (args == null || args.Length < 1)
            {
                throw new Exception("No parameters passed. Not sure what to do!");
            }

            if (!commands.Any(c => c == args[0].ToLower()))
            {
                throw new Exception($"I don't understand the command '{args[0]}'");
            }

            Services.Validator.Validate();
        }
    }
}
