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
    public static class GetProductImageTags
    {

        [FunctionName("GetProductImageTags")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Admin, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(context.FunctionAppDirectory)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();
            log.LogInformation("Get Product Image Tags function triggered");

            var db = TailwindContext.CreateNew(config.GetConnectionString("Tailwind"));

            int id = 0;
            int.TryParse(req.Query["ProductId"], out id);

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string bodyid = data ?? data?.CommentId;
            if (!string.IsNullOrEmpty(bodyid))
                int.TryParse(bodyid, out id);

            // using the product Id, get the database entry
            var product = db.Products.FirstOrDefault(c => c.Id == id);

            // Get analysis of the text
            var analyser = new CustomVisionAnalyser(config["customVisionSubscriptionKey"], new Guid(config["customVisionProjectId"]));
            var tags = analyser.GetImageTagPredictions(product.ImageUrl);
            
            log.LogInformation("Tag predictions: {Tags}", tags);

            // get the confidence tag
            var bestTag = (tags.OrderByDescending(t => t.Confidence).FirstOrDefault());
            if (tags.Any(t => t.Tag != bestTag.Tag && bestTag.Confidence - t.Confidence < 30)) {
                // take a bit off for having another tag so close
                bestTag.Confidence -= Math.Min(bestTag.Confidence, 20);
                log.LogInformation("Two tags were close together so we're reducing the confidence");
            }

            product.Tags = bestTag.Tag;
            product.AutoTagConfidence = bestTag.Confidence;
            
            db.SaveChanges();

            return (ActionResult)new OkObjectResult(tags);
            
        }
    }
}
