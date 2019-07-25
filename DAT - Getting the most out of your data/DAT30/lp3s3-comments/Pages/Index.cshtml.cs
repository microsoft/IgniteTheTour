using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using lp3s3_comments.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

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

        public async Task OnGetAsync()
        {
            // return the comments
            Comments = await Db.Comments.ToListAsync();
        }
    }
}
