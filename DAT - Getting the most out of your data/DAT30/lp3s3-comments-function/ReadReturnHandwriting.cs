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
    public static class ReadReturnHandwriting
    {

        [FunctionName("ReadReturnHandwriting")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Admin, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(context.FunctionAppDirectory)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();
            log.LogInformation("Return Handwriting function triggered");

            var db = TailwindContext.CreateNew(config.GetConnectionString("Tailwind"));

            int id = 0;
            int.TryParse(req.Query["ReturnId"], out id);

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string bodyid = data ?? data?.CommentId;
            if (!string.IsNullOrEmpty(bodyid))
                int.TryParse(bodyid, out id);

            // using the return Id, get the database entry
            var rtn = db.Returns.FirstOrDefault(c => c.Id == id);

            // Get analysis of the text
            var analyser = new HandwritingAnalyser(config["visionSubscriptionKey"], config["region"]);
            var readText = analyser.GetHandwritingAnalysis(rtn.ReturnImageUrl).Result;
            
            rtn.ReturnNotes = readText;
            db.SaveChanges();

            return (ActionResult)new OkObjectResult(readText);
            
        }
    }
}
