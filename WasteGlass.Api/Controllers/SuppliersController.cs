using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WasteGlass.Api.Data;
using WasteGlass.Api.DTOs;
using WasteGlass.Api.Models;

namespace WasteGlass.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SuppliersController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<SupplierDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetSuppliers(CancellationToken cancellationToken)
    {
        var suppliers = await dbContext.Suppliers
            .AsNoTracking()
            .OrderBy(s => s.SupplierId)
            .ToListAsync(cancellationToken);

        return Ok(suppliers.Select(SupplierDto.FromEntity));
    }

    [HttpGet("barcode-test-list")]
    [ProducesResponseType(typeof(IEnumerable<SupplierBarcodeTestDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBarcodeTestList(CancellationToken cancellationToken)
    {
        var suppliers = await dbContext.Suppliers
            .AsNoTracking()
            .OrderBy(s => s.SupplierId)
            .ToListAsync(cancellationToken);

        return Ok(suppliers.Select(SupplierBarcodeTestDto.FromEntity));
    }

    [HttpGet("{supplierId}")]
    [ProducesResponseType(typeof(SupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetSupplier(string supplierId, CancellationToken cancellationToken)
    {
        var supplier = await dbContext.Suppliers
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.SupplierId == supplierId, cancellationToken);

        if (supplier is null)
        {
            return NotFound(new { message = $"Supplier '{supplierId}' was not found." });
        }

        return Ok(SupplierDto.FromEntity(supplier));
    }

    [HttpPost]
    [Consumes("application/json")]
    [ProducesResponseType(typeof(SupplierDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> CreateSupplier(
        CreateSupplierDto request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var supplierId = request.SupplierId.Trim();
        var barcodeValue = request.BarcodeValue.Trim();
        var exists = await dbContext.Suppliers
            .AnyAsync(s => s.SupplierId == supplierId || s.BarcodeValue == barcodeValue, cancellationToken);

        if (exists)
        {
            return Conflict(new { message = $"SupplierId '{supplierId}' or barcode '{barcodeValue}' already exists." });
        }

        var supplier = new Supplier
        {
            SupplierId = supplierId,
            Name = request.Name.Trim(),
            Address = request.Address.Trim(),
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            ExpectedKg = request.ExpectedKg,
            BarcodeValue = barcodeValue,
            IsActive = true
        };

        dbContext.Suppliers.Add(supplier);
        await dbContext.SaveChangesAsync(cancellationToken);

        return CreatedAtAction(
            nameof(GetSupplier),
            new { supplierId = supplier.SupplierId },
            SupplierDto.FromEntity(supplier));
    }
}
