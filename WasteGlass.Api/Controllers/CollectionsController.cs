using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using WasteGlass.Api.DTOs;
using WasteGlass.Api.Services;

namespace WasteGlass.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CollectionsController(CollectionService collectionService) : ControllerBase
{
    [HttpPost]
    [Consumes("application/json")]
    [ProducesResponseType(typeof(CollectionSubmitResultDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(CollectionSubmitResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(CollectionSubmitResultDto), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(CollectionSubmitResultDto), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SubmitCollection(
        CollectionSubmitDto request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var result = await collectionService.SubmitCollectionAsync(request, cancellationToken);
        return StatusCode(result.StatusCode, result);
    }

    [HttpPost("sync")]
    [Consumes("application/json")]
    [ProducesResponseType(typeof(SyncResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(SyncResponseDto), StatusCodes.Status207MultiStatus)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SyncCollections(
        SyncRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var result = await collectionService.SyncCollectionsAsync(request, cancellationToken);
        return result.Success
            ? Ok(result)
            : StatusCode(StatusCodes.Status207MultiStatus, result);
    }
}
