namespace WasteGlass.Api.DTOs;

public class TripSequenceDto
{
    public int TripId { get; set; }
    public DateTime TripDate { get; set; }
    public double TotalRouteDistanceKm { get; set; }
    public int RemainingStops { get; set; }
    public List<TripStopDto> Stops { get; set; } = [];
}
