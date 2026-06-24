namespace WasteGlass.Api.Models;

public class Supplier
{
    public int Id { get; set; }
    public string SupplierId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public decimal ExpectedKg { get; set; }
    public string BarcodeValue { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;

    public ICollection<TripStop> TripStops { get; set; } = new List<TripStop>();
    public ICollection<CollectionRecord> CollectionRecords { get; set; } = new List<CollectionRecord>();
}
