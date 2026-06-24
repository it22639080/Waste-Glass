using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using WasteGlass.Api.Data;
using WasteGlass.Api.DTOs;
using WasteGlass.Api.Models;

namespace WasteGlass.Api.Services;

public class CollectionService(AppDbContext dbContext)
{
    public async Task<CollectionSubmitResultDto> SubmitCollectionAsync(
        CollectionSubmitDto request,
        CancellationToken cancellationToken = default)
    {
        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);
        var result = await SubmitCollectionInternalAsync(request, cancellationToken);

        if (result.Success && !result.AlreadySynced)
        {
            await transaction.CommitAsync(cancellationToken);
        }
        else if (result.AlreadySynced)
        {
            await transaction.CommitAsync(cancellationToken);
        }

        return result;
    }

    public async Task<SyncResponseDto> SyncCollectionsAsync(
        SyncRequestDto request,
        CancellationToken cancellationToken = default)
    {
        var response = new SyncResponseDto();

        foreach (var record in request.Records)
        {
            var result = await SubmitCollectionAsync(record, cancellationToken);
            response.Results.Add(new SyncRecordResultDto
            {
                SupplierCode = record.SupplierCode,
                Success = result.Success,
                AlreadySynced = result.AlreadySynced,
                TripStatus = result.TripStatus,
                Message = result.Message
            });
        }

        response.SyncedCount = response.Results.Count(r => r.Success);
        response.FailedCount = response.Results.Count(r => !r.Success);
        response.Success = response.FailedCount == 0;

        return response;
    }

    private async Task<CollectionSubmitResultDto> SubmitCollectionInternalAsync(
        CollectionSubmitDto request,
        CancellationToken cancellationToken)
    {
        var validationError = ValidateRequest(request);
        if (validationError is not null)
        {
            return Failure(validationError, StatusCodes.Status400BadRequest, request.SupplierCode);
        }

        var trip = await dbContext.Trips
            .Include(t => t.TripStops)
            .ThenInclude(s => s.Supplier)
            .FirstOrDefaultAsync(t => t.Id == request.TripId, cancellationToken);

        if (trip is null)
        {
            return Failure($"Trip {request.TripId} was not found.", StatusCodes.Status404NotFound, request.SupplierCode);
        }

        var supplierCode = request.SupplierCode.Trim();
        var supplier = await dbContext.Suppliers
            .FirstOrDefaultAsync(s => s.SupplierId == supplierCode, cancellationToken);

        if (supplier is null)
        {
            return Failure($"Supplier code '{supplierCode}' was not found.", StatusCodes.Status404NotFound, supplierCode);
        }

        var stop = trip.TripStops.FirstOrDefault(s =>
            s.SupplierId == supplier.Id);

        if (stop is null)
        {
            return Failure(
                $"Supplier '{supplierCode}' does not belong to trip {request.TripId}.",
                StatusCodes.Status400BadRequest,
                supplierCode);
        }

        var existingRecord = await dbContext.CollectionRecords
            .FirstOrDefaultAsync(c => c.TripId == request.TripId && c.SupplierId == stop.SupplierId, cancellationToken);

        if (existingRecord is not null)
        {
            return new CollectionSubmitResultDto
            {
                Success = true,
                AlreadySynced = true,
                CollectionRecordId = existingRecord.Id,
                SupplierCode = existingRecord.SupplierCode,
                Message = "Collection record was already synced.",
                TripStatus = trip.Status,
                NextSupplierCode = GetNextSupplierCode(trip),
                StatusCode = StatusCodes.Status200OK
            };
        }

        if (stop.Status == TripStopStatuses.Collected)
        {
            return Failure(
                $"Supplier '{supplierCode}' has already been collected for this trip.",
                StatusCodes.Status400BadRequest,
                supplierCode);
        }

        var expectedStop = trip.TripStops
            .Where(s => s.Status == TripStopStatuses.Next)
            .OrderBy(s => s.StopOrder)
            .FirstOrDefault();

        if (expectedStop is null)
        {
            expectedStop = trip.TripStops
                .Where(s => s.Status == TripStopStatuses.Pending)
                .OrderBy(s => s.StopOrder)
                .FirstOrDefault();

            if (expectedStop is null)
            {
                return Failure("This trip is already completed.", StatusCodes.Status400BadRequest, supplierCode);
            }

            expectedStop.Status = TripStopStatuses.Next;
        }

        if (expectedStop.SupplierId != stop.SupplierId)
        {
            return Failure(
                $"Supplier '{supplierCode}' is not the current next stop. Expected '{expectedStop.Supplier.SupplierId}'.",
                StatusCodes.Status400BadRequest,
                supplierCode);
        }

        var collection = new CollectionRecord
        {
            TripId = request.TripId,
            SupplierId = stop.SupplierId,
            SupplierCode = supplierCode,
            ClearGlassKg = request.ClearGlassKg,
            ColouredGlassKg = request.ColouredGlassKg,
            TotalKg = request.ClearGlassKg + request.ColouredGlassKg,
            Condition = request.Condition.Trim(),
            CollectedAt = request.CollectedAt?.ToUniversalTime() ?? DateTime.UtcNow,
            IsSynced = true
        };

        dbContext.CollectionRecords.Add(collection);

        stop.Status = TripStopStatuses.Collected;
        stop.IsShortfall = collection.TotalKg < stop.Supplier.ExpectedKg;

        var nextStop = trip.TripStops
            .Where(s => s.Status == TripStopStatuses.Pending)
            .OrderBy(s => s.StopOrder)
            .FirstOrDefault();

        if (nextStop is null)
        {
            trip.Status = TripStatuses.Completed;
            trip.CompletedAt = DateTime.UtcNow;
        }
        else
        {
            nextStop.Status = TripStopStatuses.Next;
            trip.Status = TripStatuses.InProgress;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        return new CollectionSubmitResultDto
        {
            Success = true,
            CollectionRecordId = collection.Id,
            SupplierCode = collection.SupplierCode,
            Message = "Collection saved successfully.",
            TripStatus = trip.Status,
            NextSupplierCode = GetNextSupplierCode(trip),
            StatusCode = StatusCodes.Status201Created
        };
    }

    private static string? ValidateRequest(CollectionSubmitDto request)
    {
        if (string.IsNullOrWhiteSpace(request.SupplierCode))
        {
            return "supplierCode is required.";
        }

        if (request.TripId <= 0)
        {
            return "tripId must be greater than zero.";
        }

        if (request.ClearGlassKg < 0 || request.ColouredGlassKg < 0)
        {
            return "Glass quantities cannot be negative.";
        }

        if (request.ClearGlassKg + request.ColouredGlassKg <= 0)
        {
            return "At least one glass quantity must be greater than zero.";
        }

        if (string.IsNullOrWhiteSpace(request.Condition))
        {
            return "condition is required.";
        }

        return null;
    }

    private static CollectionSubmitResultDto Failure(string message, int statusCode, string? supplierId = null) => new()
    {
        Success = false,
        Message = message,
        SupplierCode = supplierId,
        StatusCode = statusCode
    };

    private static string? GetNextSupplierCode(Trip trip)
    {
        return trip.TripStops
            .Where(s => s.Status == TripStopStatuses.Next)
            .OrderBy(s => s.StopOrder)
            .Select(s => s.Supplier.SupplierId)
            .FirstOrDefault();
    }
}
