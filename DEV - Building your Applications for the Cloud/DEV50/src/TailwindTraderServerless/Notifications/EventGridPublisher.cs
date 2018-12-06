using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Azure.EventGrid;
using Microsoft.Azure.EventGrid.Models;
using Model;

namespace Notifications
{
    public class EventGridPublisher : IEventPublisher
    {
        private readonly string endPoint;
        private readonly string key;

        public EventGridPublisher()
        {
            endPoint = Environment.GetEnvironmentVariable(Globals.PUBLISH_ENDPOINT);
            key = Environment.GetEnvironmentVariable(Globals.PUBLISH_KEY);
        }

        public async Task RaiseEvent(SkuMessageType type, IInventoryItem item)
        {
            Console.WriteLine($"Raising event {type} for SKU {item.Sku}...");

            var eventPayload = SkuNotification.Create(type, item);

            var events = new List<EventGridEvent>()
            {
                new EventGridEvent
                {
                    Id = Guid.NewGuid().ToString(),
                    EventType = type.ToString(),
                    Data = eventPayload,
                    EventTime = DateTime.Now,
                    Subject = item.Sku,
                    DataVersion = "2.0"
                }
            };
            var topicHostname = new Uri(endPoint).Host;
            var topicCredentials = new TopicCredentials(key);
            var client = new EventGridClient(topicCredentials);

            await client.PublishEventsAsync(topicHostname, events);
            Console.WriteLine($"Raised successfully.");
        }
    }
}
