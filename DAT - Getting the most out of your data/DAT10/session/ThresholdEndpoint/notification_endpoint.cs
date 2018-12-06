using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace threshold_watcher
{
    public static class notification_endpoint
    {
        [FunctionName("notification_endpoint")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)]HttpRequest req, ILogger log)
        {
            //{"OrderId":1358,"Item":"apple","Quantity":3}
            string item = req.Query["item"];
            // string orderId = req.Query["orderId"];
            string quantity = req.Query["quantity"];
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            item = item ?? data?.Item;
            // orderId = orderId ?? data?.orderId;
            quantity = quantity ?? data?.quantity;

            return item != null
                ? (ActionResult)new OkObjectResult($"{item} {quantity}")
                : new BadRequestObjectResult("Please pass data on the query string or in the request body");
        }
    }
}
