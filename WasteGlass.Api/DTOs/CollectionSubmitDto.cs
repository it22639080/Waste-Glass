using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace WasteGlass.Api.DTOs;

public class CollectionSubmitDto
{
    [Range(1, int.MaxValue)]
    public int TripId { get; set; }

    [Required]
    [MaxLength(50)]
    public string SupplierCode { get; set; } = string.Empty;

    [Range(0, 999999)]
    public decimal ClearGlassKg { get; set; }

    [Range(0, 999999)]
    public decimal ColouredGlassKg { get; set; }

    [Required]
    [MaxLength(200)]
    public string Condition { get; set; } = string.Empty;

    public DateTime? CollectedAt { get; set; }
}

public class CollectionSubmitResultDto
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public int? CollectionRecordId { get; set; }
    public string? SupplierCode { get; set; }
    public bool AlreadySynced { get; set; }
    public string? TripStatus { get; set; }
    public string? NextSupplierCode { get; set; }
    public int StatusCode { get; set; } = StatusCodes.Status200OK;
}
