using System;
using System.Collections.Generic;

namespace IoTEdgeBogusDataGenerator.Models
{
   public class Order
   {
      public int OrderNumber { get; set; }
      public Guid PurchaseId { get; set; }
      public string StoreName { get; set; }
      public string Email {get; set;}
      public string CustomerName { get; set;}
      public string ShippingAddress { get; set; }
      public List<Item> Items { get; set; }
      public int Amount_Due { get; set; }
      public DateTime Timestamp { get; set; } 
   }

}