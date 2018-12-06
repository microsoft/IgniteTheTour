using System;

namespace CLI
{
    internal class ParsedArgs
    {
        public const string INIT = "init";
        public const string ADD = "add";
        public const string DESCRIBE = "describe";
        public const string PRICE = "set-price";
        public const string IMAGE = "set-image";
        public const string GET = "get";

        public string Command { get; set; }
        public string Sku { get; set; }
        public string Target { get; set; }

        public static ParsedArgs Parse(string[] args)
        {
            var command = args[0].ToLowerInvariant();
            var sku = string.Empty;
            var target = string.Empty;
            if (command != INIT)
            {
                if (args.Length < 2 || string.IsNullOrWhiteSpace(args[1]))
                {
                    throw new ArgumentException($"'{command}' command requires a SKU.");
                }
                sku = args[1].Trim();
                if (command != ADD && command != GET)
                {
                    if (args.Length < 3 || string.IsNullOrWhiteSpace(args[2]))
                    {
                        throw new ArgumentException($"'{command}' command requires a target value.");
                    }
                    target = args[2].Trim();
                }
            }
            return new ParsedArgs
            {
                Command = command,
                Sku = sku,
                Target = target
            };
        }
    }
}
