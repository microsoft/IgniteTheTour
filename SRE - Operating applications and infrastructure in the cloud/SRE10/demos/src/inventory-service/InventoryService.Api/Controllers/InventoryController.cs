using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using InventoryService.Api.Models;
using InventoryService.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace InventoryService.Api.Controllers
{
    [Route("api/inventory")]
    [ApiController]
    public class InventoryController : ControllerBase
    {
        private readonly InventoryManager inventoryManager;

        public InventoryController(InventoryManager inventoryManager)
        {
            this.inventoryManager = inventoryManager ?? throw new ArgumentNullException(nameof(inventoryManager));
        }

        /// <summary>
        /// Retrieves one or more inventory items.
        /// </summary>
        /// <returns>
        /// Inventory items
        /// </returns>
        /// <param name="skus">The list of comma-separated SKUs.</param>
        [HttpGet]
        public async Task<IEnumerable<InventoryItem>> GetAsync([FromQuery] string skus)
        {
            if (!string.IsNullOrEmpty(skus))
            {
                var splitSkus = skus.Split(',', StringSplitOptions.RemoveEmptyEntries);
                return await inventoryManager.GetInventoryBySkus(splitSkus);
            }
            else
            {
                return new List<InventoryItem>();
            }
        }

        /// <summary>
        /// Retrieves an inventory item (susceptible to SQL injection).
        /// </summary>
        /// <returns>
        /// Inventory item
        /// </returns>
        /// <param name="sku">The product SKU.</param>
        [HttpGet("bad/{sku}")]
        public async Task<IActionResult> GetSingleBadAsync(string sku)
        {
            var result = await inventoryManager.GetInventoryBySkuBad(sku);
            if (result != null)
            {
                return Ok(result);
            }
            else
            {
                return NotFound();
            }
        }

        /// <summary>
        /// Retrieves an inventory item.
        /// </summary>
        /// <returns>
        /// Inventory item
        /// </returns>
        /// <param name="sku">The product SKU.</param>
        [HttpGet("{sku}")]
        public async Task<InventoryItem> GetSingleAsync(string sku)
        {
            return (await inventoryManager.GetInventoryBySkus(new string[] { sku })).FirstOrDefault();
        }

        /// <summary>
        /// Increments an inventory item quantity by one.
        /// </summary>
        /// <returns>
        /// The updated inventory item
        /// </returns>
        /// <param name="sku">The product SKU.</param>
        [HttpPost("{sku}/increment")]
        public Task<InventoryItem> IncrementAsync(string sku)
        {
            return inventoryManager.IncrementInventory(sku);
        }

        /// <summary>
        /// Decrements an inventory item quantity by one.
        /// </summary>
        /// <returns>
        /// The updated inventory item
        /// </returns>
        /// <param name="sku">The product SKU.</param> 
        [HttpPost("{sku}/decrement")]
        public Task<InventoryItem> DecrementAsync(string sku)
        {
            return inventoryManager.DecrementInventory(sku);
        }
    }
}