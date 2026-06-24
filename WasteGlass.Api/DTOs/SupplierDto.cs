using System.ComponentModel.DataAnnotations;
using WasteGlass.Api.Models;

namespace WasteGlass.Api.DTOs;

public class SupplierDto
{
    public int Id { get; set; }
    public string SupplierCode { get; set; } = string.Empty;
    public string BarcodeValue { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public decimal ExpectedKg { get; set; }
    public bool IsActive { get; set; }

    public static SupplierDto FromEntity(Supplier supplier) => new()
    {
        Id = supplier.Id,
        SupplierCode = supplier.SupplierId,
        BarcodeValue = supplier.BarcodeValue,
        Name = supplier.Name,
        Address = supplier.Address,
        Latitude = supplier.Latitude,
        Longitude = supplier.Longitude,
        ExpectedKg = supplier.ExpectedKg,
        IsActive = supplier.IsActive
    };
}

public class CreateSupplierDto
{
    [Required]
    [MaxLength(50)]
    public string SupplierId { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string BarcodeValue { get; set; } = string.Empty;

    [Required]
    [MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(300)]
    public string Address { get; set; } = string.Empty;

    [Range(-90, 90)]
    public double Latitude { get; set; }

    [Range(-180, 180)]
    public double Longitude { get; set; }

    [Range(0.01, 999999)]
    public decimal ExpectedKg { get; set; }
}

public class SupplierBarcodeTestDto
{
    public string SupplierCode { get; set; } = string.Empty;
    public string SupplierName { get; set; } = string.Empty;
    public decimal ExpectedKg { get; set; }
    public string BarcodeText { get; set; } = string.Empty;

    public static SupplierBarcodeTestDto FromEntity(Supplier supplier) => new()
    {
        SupplierCode = supplier.SupplierId,
        SupplierName = supplier.Name,
        ExpectedKg = supplier.ExpectedKg,
        BarcodeText = supplier.BarcodeValue
    };
}
