using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using lp3s3.CommentCogSvc.Database;
using lp3s3.CommentCogSvc.CogSvc;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace lp3s3.CommentCogSvc
{
    public static class GetCommentAnalysis
    {

        [FunctionName("GetCommentAnalysis")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Admin, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(context.FunctionAppDirectory)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();
            log.LogInformation("Comment Analysis function triggered");

            var db = TailwindContext.CreateNew(config.GetConnectionString("Tailwind"));

            int id = 0;
            int.TryParse(req.Query["CommentId"], out id);

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string bodyid = data ?? data?.CommentId;
            if (!string.IsNullOrEmpty(bodyid))
                int.TryParse(bodyid, out id);

            // using the comment Id, get the database entries
            var comment = db.Comments.FirstOrDefault(c => c.Id == id);
            var analysis = db.CommentAnalyses.FirstOrDefault(ca => ca.Id == id);

            // Get analysis of the text
            var analyser = new TextAnalyser(config["analyticsSubscriptionKey"], config["translatorSubscriptionKey"], config["region"]);
            var result = analyser.GetTextAnalysis(id, comment.CommentText);

            var isnew = analysis == null;
            if (isnew) {
                analysis = new CommentAnalysis() {
                    Id = id
                };
            }
            // Update the database
            analysis.Language = result.Language;
            analysis.Sentiment = result.Sentiment;
            analysis.EnglishTranslation = result.EnglishTranslation;
            analysis.Keywords = result.Keywords;

            if (isnew) {
                db.Add(analysis);
            }
            db.SaveChanges();

            return (ActionResult)new OkObjectResult(result);
        }
    }
}
