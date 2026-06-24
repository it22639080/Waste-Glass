namespace WasteGlass.Api.Models;

public class CollectionRecord
{
    public int Id { get; set; }
    public int TripId { get; set; }
    public int SupplierId { get; set; }
    public string SupplierCode { get; set; } = string.Empty;
    public decimal ClearGlassKg { get; set; }
    public decimal ColouredGlassKg { get; set; }
    public decimal TotalKg { get; set; }
    public string Condition { get; set; } = string.Empty;
    public DateTime CollectedAt { get; set; }
    public bool IsSynced { get; set; }

    public Trip Trip { get; set; } = null!;
    public Supplier Supplier { get; set; } = null!;
}
