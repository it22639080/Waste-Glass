namespace WasteGlass.Api.DTOs;

public class TripReportDto
{
    public int TripId { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public int Duration { get; set; }
    public double TotalRouteDistanceKm { get; set; }
    public decimal TotalExpectedKg { get; set; }
    public decimal TotalCollectedKg { get; set; }
    public List<SupplierCollectionSummaryDto> Suppliers { get; set; } = [];
}

public class SupplierCollectionSummaryDto
{
    public string SupplierCode { get; set; } = string.Empty;
    public string SupplierName { get; set; } = string.Empty;
    public decimal ExpectedKg { get; set; }
    public decimal ClearGlassKg { get; set; }
    public decimal ColouredGlassKg { get; set; }
    public decimal TotalKg { get; set; }
    public string? Condition { get; set; }
    public string Status { get; set; } = string.Empty;
    public bool IsShortfall { get; set; }
}
