namespace WasteGlass.Api.Models;

public class TripStop
{
    public int Id { get; set; }
    public int TripId { get; set; }
    public int SupplierId { get; set; }
    public int StopOrder { get; set; }
    public double DistanceFromPreviousKm { get; set; }
    public string Status { get; set; } = TripStopStatuses.Pending;
    public bool IsShortfall { get; set; }

    public Trip Trip { get; set; } = null!;
    public Supplier Supplier { get; set; } = null!;
}

public static class TripStopStatuses
{
    public const string Pending = "Pending";
    public const string Next = "Next";
    public const string Collected = "Collected";
}
