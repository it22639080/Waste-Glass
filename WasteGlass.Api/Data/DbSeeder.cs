using Microsoft.EntityFrameworkCore;
using WasteGlass.Api.Models;
using WasteGlass.Api.Services;

namespace WasteGlass.Api.Data;

public static class DbSeeder
{
    private const double CollectorStartLatitude = 6.9271;
    private const double CollectorStartLongitude = 79.8612;

    public static async Task SeedAsync(
        AppDbContext dbContext,
        RouteOptimizationService routeOptimizationService,
        CancellationToken cancellationToken = default)
    {
        var demoSuppliers = GetDemoSuppliers();
        var demoSupplierIds = demoSuppliers.Select(s => s.SupplierId).ToHashSet();
        var existingSuppliers = await dbContext.Suppliers
            .Where(s => demoSupplierIds.Contains(s.SupplierId))
            .ToListAsync(cancellationToken);

        foreach (var demoSupplier in demoSuppliers)
        {
            var existingSupplier = existingSuppliers
                .FirstOrDefault(s => s.SupplierId == demoSupplier.SupplierId);

            if (existingSupplier is null)
            {
                dbContext.Suppliers.Add(demoSupplier);
                continue;
            }

            existingSupplier.Name = demoSupplier.Name;
            existingSupplier.Address = demoSupplier.Address;
            existingSupplier.Latitude = demoSupplier.Latitude;
            existingSupplier.Longitude = demoSupplier.Longitude;
            existingSupplier.ExpectedKg = demoSupplier.ExpectedKg;
            existingSupplier.BarcodeValue = demoSupplier.BarcodeValue;
            existingSupplier.IsActive = true;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        var today = DateTime.UtcNow.Date;
        var hasTodayTrip = await dbContext.Trips.AnyAsync(t => t.TripDate == today, cancellationToken);

        if (hasTodayTrip)
        {
            return;
        }

        var suppliers = await dbContext.Suppliers
            .Where(s => s.IsActive && demoSupplierIds.Contains(s.SupplierId))
            .OrderBy(s => s.SupplierId)
            .ToListAsync(cancellationToken);

        var route = routeOptimizationService.OptimizeRoute(
            suppliers,
            CollectorStartLatitude,
            CollectorStartLongitude);

        var trip = new Trip
        {
            TripDate = today,
            CollectorStartLatitude = CollectorStartLatitude,
            CollectorStartLongitude = CollectorStartLongitude,
            Status = TripStatuses.InProgress,
            StartedAt = DateTime.UtcNow,
            TripStops = route.Stops.Select(stop => new TripStop
            {
                SupplierId = stop.Supplier.Id,
                StopOrder = stop.StopOrder,
                DistanceFromPreviousKm = Math.Round(stop.DistanceFromPreviousKm, 2),
                Status = stop.StopOrder == 1 ? TripStopStatuses.Next : TripStopStatuses.Pending,
                IsShortfall = false
            }).ToList()
        };

        dbContext.Trips.Add(trip);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private static List<Supplier> GetDemoSuppliers() =>
    [
        new()
        {
            SupplierId = "SUP001",
            BarcodeValue = "SUP001",
            Name = "Green Glass Mart",
            Address = "Galle Face Center Road, Colombo 03",
            Latitude = 6.9177,
            Longitude = 79.8482,
            ExpectedKg = 120
        },
        new()
        {
            SupplierId = "SUP002",
            BarcodeValue = "SUP002",
            Name = "City Bottle Center",
            Address = "Main Street, Pettah, Colombo 11",
            Latitude = 6.9368,
            Longitude = 79.8516,
            ExpectedKg = 80
        },
        new()
        {
            SupplierId = "SUP003",
            BarcodeValue = "SUP003",
            Name = "Lanka Recycling Point",
            Address = "Baseline Road, Borella, Colombo 08",
            Latitude = 6.9147,
            Longitude = 79.8778,
            ExpectedKg = 150
        },
        new()
        {
            SupplierId = "SUP004",
            BarcodeValue = "SUP004",
            Name = "Eco Glass Supplier",
            Address = "High Level Road, Nugegoda",
            Latitude = 6.8721,
            Longitude = 79.8885,
            ExpectedKg = 60
        },
        new()
        {
            SupplierId = "SUP005",
            BarcodeValue = "SUP005",
            Name = "Metro Waste Glass Hub",
            Address = "Galle Road, Dehiwala",
            Latitude = 6.8518,
            Longitude = 79.8651,
            ExpectedKg = 100
        }
    ];
}
