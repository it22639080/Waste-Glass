using WasteGlass.Api.Models;

namespace WasteGlass.Api.DTOs;

public class TripStopDto
{
    public int StopId { get; set; }
    public int StopOrder { get; set; }
    public int SupplierId { get; set; }
    public string SupplierCode { get; set; } = string.Empty;
    public string SupplierName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public decimal ExpectedKg { get; set; }
    public string Status { get; set; } = string.Empty;
    public double DistanceFromPreviousKm { get; set; }

    public static TripStopDto FromEntity(TripStop stop) => new()
    {
        StopId = stop.Id,
        StopOrder = stop.StopOrder,
        SupplierId = stop.Supplier.Id,
        SupplierCode = stop.Supplier.SupplierId,
        SupplierName = stop.Supplier.Name,
        Address = stop.Supplier.Address,
        Latitude = stop.Supplier.Latitude,
        Longitude = stop.Supplier.Longitude,
        ExpectedKg = stop.Supplier.ExpectedKg,
        Status = stop.Status,
        DistanceFromPreviousKm = Math.Round(stop.DistanceFromPreviousKm, 2)
    };
}
