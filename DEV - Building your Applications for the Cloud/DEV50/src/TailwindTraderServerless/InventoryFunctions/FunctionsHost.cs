using DataAccess;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage.Table;
using Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace InventoryFunctions
{
    public static class FunctionsHost
    {
        private const string DESCRIBE_EVENT = "Described";
        private const string IMAGE_EVENT = "ImageSet";
        private const string PRICE_EVENT = "PriceSet";

        /// <summary>
        ///     Maps incoming sku event to an internal durable function event and a factory for 
        ///     interrogating the payload
        /// </summary>
        private static readonly IDictionary<string,
            (string durableEvent, Func<EventGridEvent, SkuNotification> payloadFactory)> sku_events
            = new Dictionary<string,
            (string durableEvent, Func<EventGridEvent, SkuNotification> payloadFactory)>
        {
            { SkuMessageType.DescriptionSet.ToString(),
                (durableEvent: DESCRIBE_EVENT,
                    payloadFactory: (EventGridEvent eventGridEvent) => ExtractValue<DescriptionSet>(eventGridEvent)) },
            { SkuMessageType.ImageSet.ToString(),
                (durableEvent: IMAGE_EVENT,
                    payloadFactory: (EventGridEvent eventGridEvent) => ExtractValue<ImageSet>(eventGridEvent)) },
            { SkuMessageType.PriceSet.ToString(),
                (durableEvent: PRICE_EVENT,
                    payloadFactory: (EventGridEvent eventGridEvent) => ExtractValue<PriceSet>(eventGridEvent)) }
        };

        [FunctionName(nameof(Get))]
        public static async Task<IActionResult> Get(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "Get/{sku}")] HttpRequest req,
            string sku,
            [Table(Globals.TABLE)]CloudTable table,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            if (string.IsNullOrWhiteSpace(sku))
            {
                return new BadRequestObjectResult("SKU is required.");
            }

            log.LogInformation("Processing sku: {sku}", sku);

            var temp = TableInventoryItem.GenerateTemplateFromSku(sku);
            var operation = TableOperation.Retrieve<TableInventoryItem>(temp.PartitionKey, temp.RowKey);
            var result = await table.ExecuteAsync(operation);
            if (result.Result != null)
            {
                log.LogInformation("Sku {sku} found.", sku);
                return new OkObjectResult(result.Result);
            }
            log.LogWarning("Sku {sku} not found.", sku);
            return new NotFoundObjectResult(sku);
        }

        /// <summary>
        /// Simple "echo" of event grid events
        /// </summary>
        /// <param name="eventGridEvent">The event that was raised</param>
        /// <param name="log">Logger</param>
        [FunctionName(nameof(Monitor))]
        public static void Monitor([EventGridTrigger]EventGridEvent eventGridEvent, ILogger log)
        {
            log.LogInformation("Received event:\n{eventGridEvent}", JsonConvert.SerializeObject(eventGridEvent));
        }

        [FunctionName(nameof(Process))]
        public static async Task Process(
            [EventGridTrigger]EventGridEvent eventGridEvent,
            [OrchestrationClient]DurableOrchestrationClient starter,
            ILogger log)
        {
            log.LogInformation("Processing SKU event: {skuEvent}", eventGridEvent.EventType);

            // this workflow starts a durable function for the "added" event 
            // it then publishes other events until the price, description, and image are set
            // and will finally set the product to active 
            if (eventGridEvent.EventType == SkuMessageType.Added.ToString())
            {
                var payload = ExtractValue<SkuAdded>(eventGridEvent);
                log.LogInformation("Starting new workflow for sku {sku}.", payload.Sku);
                await starter.StartNewAsync(nameof(SkuWorkflow), payload.Sku);
                return;
            }

            // one of the events we're interested in
            if (sku_events.ContainsKey(eventGridEvent.EventType))
            {
                (string durableEvent, Func<EventGridEvent, SkuNotification> payloadFactory)
                    = sku_events[eventGridEvent.EventType];
                var payload = payloadFactory(eventGridEvent);
                var instanceId = await GetInstanceId(starter, log, payload.Sku);
                log.LogInformation("Informing sku workflow for sku {sku} of event {event}", payload.Sku, durableEvent);
                await starter.RaiseEventAsync(instanceId, durableEvent, payload.Sku);
            }
        }

        /// <summary>
        /// This workflow waits for all three attributes of a SKU to be set before setting it
        /// to active
        /// </summary>
        /// <param name="context">Orchestration for the workflow</param>
        /// <param name="log">Logger</param>
        /// <returns></returns>
        [FunctionName(nameof(SkuWorkflow))]
        public static async Task SkuWorkflow(
            [OrchestrationTrigger]DurableOrchestrationContext context,
            ILogger log)
        {
            var sku = context.GetInput<string>();

            log.LogInformation("Durable function started for sku {sku}", sku);

            var describe = context.WaitForExternalEvent<string>(DESCRIBE_EVENT);
            var image = context.WaitForExternalEvent<string>(IMAGE_EVENT);
            var price = context.WaitForExternalEvent<string>(PRICE_EVENT);

            await Task.WhenAll(describe, image, price);

            log.LogInformation("All events received. Marking sku {sku} as complete.", sku);
            await context.CallActivityAsync(nameof(MarkActive), sku);
        }

        /// <summary>
        /// Simple activity to mark an inventory item as active
        /// </summary>
        /// <param name="sku"></param>
        /// <param name="table"></param>
        /// <param name="log"></param>
        /// <returns></returns>
        [FunctionName(nameof(MarkActive))]
        public static async Task MarkActive(
            [ActivityTrigger]string sku,
            [Table(Globals.TABLE)]CloudTable table,
            ILogger log)
        {
            log.LogInformation("Marking sku {sku} as active.", sku);
            var item = new TableInventoryItem { Sku = sku };
            var operation = TableOperation.Retrieve<TableInventoryItem>(item.PartitionKey, item.RowKey);
            var result = await table.ExecuteAsync(operation);
            if (result.Result == null)
            {
                throw new Exception($"Failed to load sku {sku}");
            }
            item = result.Result as TableInventoryItem;
            item.IsActive = true;
            operation = TableOperation.Replace(item);
            await table.ExecuteAsync(operation);
        }

        /// <summary>
        /// This function is used by the logic app to add a machine description to an inventory
        /// item
        /// </summary>
        /// <param name="req"></param>
        /// <param name="table"></param>
        /// <param name="log"></param>
        /// <returns></returns>
        [FunctionName(nameof(MachineDescription))]
        public static async Task<IActionResult> MachineDescription(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req,
            [Table(Globals.TABLE)]CloudTable table,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string description = (data?.description).ToString();
            string sku = (data?.sku).ToString();

            if (string.IsNullOrWhiteSpace(sku))
            {
                return new BadRequestObjectResult("SKU is required.");
            }

            log.LogInformation("Processing sku: {sku}", sku);

            
            if (string.IsNullOrWhiteSpace(description))
            {
                return new BadRequestObjectResult("Description is required.");
            }

            var temp = TableInventoryItem.GenerateTemplateFromSku(sku);
            var operation = TableOperation.Retrieve<TableInventoryItem>(temp.PartitionKey, temp.RowKey);
            var result = await table.ExecuteAsync(operation);
            if (result.Result == null)
            {
                log.LogWarning("Sku {sku} not found.", sku);
                return new NotFoundObjectResult(sku);               
            }
            var item = result.Result as TableInventoryItem;
            item.MachineDescription = description;
            operation = TableOperation.Replace(item);
            await table.ExecuteAsync(operation);
            return new OkResult();
        }

        /// <summary>
        /// Extracts a strongly typed data message from the event grid payload
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="message"></param>
        /// <returns></returns>
        private static T ExtractValue<T>(EventGridEvent message)
        {
            return ((JObject)message.Data).ToObject<T>();
        }

        /// <summary>
        /// Iterates running orchestrations to find one that matches the SKU. Note if you
        /// have multiple orchestrations for the same SKU you'll want to identify this a 
        /// different way, perhaps by adding a complex input type with SKU and a category
        /// </summary>
        /// <param name="client"></param>
        /// <param name="log"></param>
        /// <param name="sku"></param>
        /// <returns></returns>
        private static async Task<string> GetInstanceId(DurableOrchestrationClient client, ILogger log, string sku)
        {
            log.LogInformation("Looking for running instance for sku {sku}", sku);
            var instances = await client.GetStatusAsync(
                DateTime.Now.AddYears(-10),
                null,
                new List<OrchestrationRuntimeStatus>
            {
                OrchestrationRuntimeStatus.Running
            });
            foreach (var instance in instances)
            {
                if (instance.Input.ToObject<string>() == sku)
                {
                    log.LogInformation("Found running instance {instanceId}", instance.InstanceId);
                    return instance.InstanceId;
                }
            }
            throw new Exception($"Running orchestration not found for sku {sku}");
        }
    }
}
