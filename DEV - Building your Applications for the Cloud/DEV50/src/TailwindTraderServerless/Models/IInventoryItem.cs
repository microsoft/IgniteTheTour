namespace Models
{
    public interface IInventoryItem
    {
        string Sku { get; set; }
        string MachineDescription { get; set; }
        string HumanDescription { get; set; }
        string Description { get; }
        string ImageUrl { get; set; }
        decimal Price { get; set; }
        bool ImageSet { get; set; }
        bool DescriptionSet { get; set; }
        bool PriceSet { get; set; }
        bool IsActive { get; set; }
    }
}
