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
    public class ExtendedModel : PageModel
    {
        public IEnumerable<ExtendedComment> Comments;
        private readonly IConfiguration config;

        [BindProperty]
        public int GetAnalysisCommentId { get; set; }

        public ExtendedModel(TailwindContext context, IConfiguration config)
        {
            Db = context;
            this.config = config;
        }

        private TailwindContext Db { get; }

        public void OnGet()
        {
            // return the comments
            Comments = ExtendedComment.FromDb(Db.Comments.ToList(), Db.CommentAnalyses.ToList());
        }

        public IActionResult OnPost()
        {
            if (GetAnalysisCommentId > 0)
            {
                using (var client = new HttpClient()
                {
                    BaseAddress = new Uri(config["FunctionsUrl"])
                })
                {
                    var functionKey = config["FunctionsKey"];

                    // wait for response, but don't use it, we'll refresh the page
                    var response = client.GetAsync($"api/GetCommentAnalysis?CommentId={GetAnalysisCommentId}&code={functionKey}").Result;
                }
            }
            return new RedirectToPageResult("Extended");
        }
    }
}
