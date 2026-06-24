using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WasteGlass.Api.DTOs;
using WasteGlass.Api.Services;

namespace WasteGlass.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TripsController(TripService tripService) : ControllerBase
{
    [HttpGet("today")]
    [ProducesResponseType(typeof(TripSequenceDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetTodayTrip(CancellationToken cancellationToken)
    {
        try
        {
            var trip = await tripService.GetOrCreateTodayTripAsync(cancellationToken);
            return Ok(trip);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPost("generate-today")]
    [ProducesResponseType(typeof(TripSequenceDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GenerateTodayTrip(CancellationToken cancellationToken)
    {
        try
        {
            var trip = await tripService.GetOrCreateTodayTripAsync(cancellationToken);
            return Ok(trip);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("{tripId:int}/report")]
    [ProducesResponseType(typeof(TripReportDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetTripReport(int tripId, CancellationToken cancellationToken)
    {
        var report = await tripService.GetTripReportAsync(tripId, cancellationToken);

        if (report is null)
        {
            return NotFound(new { message = $"Trip {tripId} was not found." });
        }

        return Ok(report);
    }
}
