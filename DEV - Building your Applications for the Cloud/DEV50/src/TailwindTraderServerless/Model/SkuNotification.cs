namespace Model
{
    public abstract class SkuNotification
    {
        public string Sku { get; set; }

        public static SkuNotification Create(SkuMessageType type, IInventoryItem item)
        {
            switch (type)
            {
                case SkuMessageType.Activated:
                    return new SkuActivated { Sku = item.Sku };
                case SkuMessageType.Added:
                    return new SkuAdded { Sku = item.Sku };
                case SkuMessageType.DescriptionSet:
                    return new DescriptionSet
                    {
                        Sku = item.Sku,
                        Description = item.Description
                    };
                case SkuMessageType.ImageSet:
                    return new ImageSet
                    {
                        Sku = item.Sku,
                        ImageUrl = item.ImageUrl
                    };
                case SkuMessageType.PriceSet:
                    return new PriceSet
                    {
                        Sku = item.Sku,
                        Price = item.Price
                    };
            }

            return null;
        }
    }
}
