using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using lp3s3_comments.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace lp3s3_comments.Pages
{
    public class ProductsModel : PageModel
    {
        public IEnumerable<Product> Products;
        private readonly IConfiguration config;
        private readonly IHttpClientFactory httpClientFactory;

        [BindProperty]
        public int ProductId { get; set; }

        public ProductsModel(TailwindContext context, IConfiguration config, IHttpClientFactory httpClientFactory)
        {
            Db = context;
            this.config = config;
            this.httpClientFactory = httpClientFactory;
        }

        private TailwindContext Db { get; }

        public async Task OnGetAsync()
        {
            // return the products
            Products = await Db.Products.OrderBy(p => p.AverageSentiment ?? 0).ToListAsync();
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (ProductId > 0)
            {
                var client = httpClientFactory.CreateClient("functions");

                var functionKey = config["FunctionsKey"];

                // wait for response, but don't use it, we'll refresh the page
                var response = await client.GetAsync($"api/GetProductImageTags?ProductId={ProductId}&code={functionKey}");
            }
            return new RedirectToPageResult("Products");
        }
    }
}
