namespace WasteGlass.Api.Models;

public class Trip
{
    public int Id { get; set; }
    public DateTime TripDate { get; set; }
    public double CollectorStartLatitude { get; set; }
    public double CollectorStartLongitude { get; set; }
    public string Status { get; set; } = TripStatuses.InProgress;
    public DateTime StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public ICollection<TripStop> TripStops { get; set; } = new List<TripStop>();
    public ICollection<CollectionRecord> CollectionRecords { get; set; } = new List<CollectionRecord>();
}

public static class TripStatuses
{
    public const string InProgress = "InProgress";
    public const string Completed = "Completed";
}
