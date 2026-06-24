using Microsoft.EntityFrameworkCore;
using WasteGlass.Api.Data;
using WasteGlass.Api.DTOs;
using WasteGlass.Api.Models;

namespace WasteGlass.Api.Services;

public class TripService(
    AppDbContext dbContext,
    RouteOptimizationService routeOptimizationService,
    IConfiguration configuration)
{
    public async Task<TripSequenceDto> GetOrCreateTodayTripAsync(CancellationToken cancellationToken = default)
    {
        var today = DateTime.UtcNow.Date;
        var existingTrip = await GetTripWithStopsQuery()
            .FirstOrDefaultAsync(t => t.TripDate == today, cancellationToken);

        if (existingTrip is not null)
        {
            if (existingTrip.TripStops.Count == 0)
            {
                await AddOptimizedStopsAsync(existingTrip, cancellationToken);
            }

            return ToTripSequenceDto(existingTrip);
        }

        var suppliers = await dbContext.Suppliers
            .Where(s => s.IsActive)
            .OrderBy(s => s.SupplierId)
            .ToListAsync(cancellationToken);

        if (suppliers.Count == 0)
        {
            throw new InvalidOperationException("No active suppliers are available to create today's trip.");
        }

        var trip = new Trip
        {
            TripDate = today,
            CollectorStartLatitude = configuration.GetValue("Depot:Latitude", 6.9271),
            CollectorStartLongitude = configuration.GetValue("Depot:Longitude", 79.8612),
            Status = TripStatuses.InProgress,
            StartedAt = DateTime.UtcNow
        };

        dbContext.Trips.Add(trip);
        await dbContext.SaveChangesAsync(cancellationToken);
        await AddOptimizedStopsAsync(trip, cancellationToken);

        var createdTrip = await GetTripWithStopsQuery()
            .FirstAsync(t => t.Id == trip.Id, cancellationToken);

        return ToTripSequenceDto(createdTrip);
    }

    public async Task<TripReportDto?> GetTripReportAsync(int tripId, CancellationToken cancellationToken = default)
    {
        var trip = await GetTripWithStopsQuery()
            .FirstOrDefaultAsync(t => t.Id == tripId, cancellationToken);

        if (trip is null)
        {
            return null;
        }

        var collections = await dbContext.CollectionRecords
            .Where(c => c.TripId == tripId)
            .ToListAsync(cancellationToken);

        var totalCollectedKg = collections.Sum(c => c.TotalKg);
        var totalExpectedKg = trip.TripStops.Sum(s => s.Supplier.ExpectedKg);
        var totalRouteDistanceKm = trip.TripStops.Sum(s => s.DistanceFromPreviousKm);
        var startedAt = trip.StartedAt;
        var finishedAt = trip.CompletedAt ?? DateTime.UtcNow;

        return new TripReportDto
        {
            TripId = trip.Id,
            StartedAt = trip.StartedAt,
            CompletedAt = trip.CompletedAt,
            Duration = Math.Max(0, (int)Math.Round((finishedAt - startedAt).TotalMinutes)),
            TotalRouteDistanceKm = Math.Round(totalRouteDistanceKm, 2),
            TotalExpectedKg = totalExpectedKg,
            TotalCollectedKg = totalCollectedKg,
            Suppliers = trip.TripStops
                .OrderBy(s => s.StopOrder)
                .Select(stop =>
                {
                    var collection = collections.FirstOrDefault(c => c.SupplierId == stop.SupplierId);
                    return new SupplierCollectionSummaryDto
                    {
                        SupplierCode = stop.Supplier.SupplierId,
                        SupplierName = stop.Supplier.Name,
                        ExpectedKg = stop.Supplier.ExpectedKg,
                        ClearGlassKg = collection?.ClearGlassKg ?? 0,
                        ColouredGlassKg = collection?.ColouredGlassKg ?? 0,
                        TotalKg = collection?.TotalKg ?? 0,
                        Condition = collection?.Condition,
                        Status = stop.Status,
                        IsShortfall = stop.IsShortfall
                    };
                })
                .ToList()
        };
    }

    private IQueryable<Trip> GetTripWithStopsQuery()
    {
        return dbContext.Trips
            .Include(t => t.TripStops)
            .ThenInclude(s => s.Supplier)
            .AsSplitQuery();
    }

    private async Task AddOptimizedStopsAsync(Trip trip, CancellationToken cancellationToken)
    {
        var suppliers = await dbContext.Suppliers
            .Where(s => s.IsActive)
            .OrderBy(s => s.SupplierId)
            .ToListAsync(cancellationToken);

        if (suppliers.Count == 0)
        {
            throw new InvalidOperationException("No active suppliers are available to create today's trip stops.");
        }

        var route = routeOptimizationService.OptimizeRoute(
            suppliers,
            trip.CollectorStartLatitude,
            trip.CollectorStartLongitude);

        foreach (var stop in route.Stops)
        {
            trip.TripStops.Add(new TripStop
            {
                SupplierId = stop.Supplier.Id,
                Supplier = stop.Supplier,
                StopOrder = stop.StopOrder,
                DistanceFromPreviousKm = Math.Round(stop.DistanceFromPreviousKm, 2),
                Status = stop.StopOrder == 1 ? TripStopStatuses.Next : TripStopStatuses.Pending,
                IsShortfall = false
            });
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private static TripSequenceDto ToTripSequenceDto(Trip trip) => new()
    {
        TripId = trip.Id,
        TripDate = trip.TripDate,
        TotalRouteDistanceKm = Math.Round(trip.TripStops.Sum(s => s.DistanceFromPreviousKm), 2),
        RemainingStops = trip.TripStops.Count(s => s.Status != TripStopStatuses.Collected),
        Stops = trip.TripStops
            .OrderBy(s => s.StopOrder)
            .Select(TripStopDto.FromEntity)
            .ToList()
    };
}
