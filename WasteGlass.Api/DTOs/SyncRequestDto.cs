using System.ComponentModel.DataAnnotations;

namespace WasteGlass.Api.DTOs;

public class SyncRequestDto
{
    [Required]
    [MinLength(1)]
    public List<CollectionSubmitDto> Records { get; set; } = [];
}

public class SyncResponseDto
{
    public bool Success { get; set; }
    public int SyncedCount { get; set; }
    public int FailedCount { get; set; }
    public List<SyncRecordResultDto> Results { get; set; } = [];
}

public class SyncRecordResultDto
{
    public string SupplierCode { get; set; } = string.Empty;
    public bool Success { get; set; }
    public bool AlreadySynced { get; set; }
    public string? TripStatus { get; set; }
    public string Message { get; set; } = string.Empty;
}
