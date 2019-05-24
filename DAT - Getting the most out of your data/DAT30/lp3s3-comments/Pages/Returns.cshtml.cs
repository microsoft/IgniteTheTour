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
    public class ReturnsModel : PageModel
    {
        public IEnumerable<Return> Returns;
        private readonly IConfiguration config;
        private readonly IHttpClientFactory httpClientFactory;

        [BindProperty]
        public int GetHandwritingReturnId { get; set; }

        public ReturnsModel(TailwindContext context, IConfiguration config, IHttpClientFactory httpClientFactory)
        {
            Db = context;
            this.config = config;
            this.httpClientFactory = httpClientFactory;
        }

        private TailwindContext Db { get; }

        public async Task OnGetAsync()
        {
            // return the returns
            Returns = await Db.Returns.ToListAsync();
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (GetHandwritingReturnId > 0)
            {
                var client = httpClientFactory.CreateClient("functions");
                var functionKey = config["FunctionsKey"];

                // wait for response, but don't use it, we'll refresh the page
                var response = await client.GetAsync($"api/ReadReturnHandwriting?ReturnId={GetHandwritingReturnId}&code={functionKey}");
            }
            return new RedirectToPageResult("Returns");
        }
    }
}
