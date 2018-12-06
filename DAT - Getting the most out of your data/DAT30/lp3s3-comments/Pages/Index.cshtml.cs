using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using lp3s3_comments.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace lp3s3_comments.Pages
{
    public class IndexModel : PageModel
    {
        public IEnumerable<Comment> Comments;

        public IndexModel(TailwindContext context)
        {
            Db = context;
        }

        private TailwindContext Db { get; }

        public void OnGet()
        {
            // return the comments
            Comments = Db.Comments.ToList();
        }
    }
}
