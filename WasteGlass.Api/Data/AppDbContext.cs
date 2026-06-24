using Microsoft.EntityFrameworkCore;
using WasteGlass.Api.Models;

namespace WasteGlass.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Supplier> Suppliers => Set<Supplier>();
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<TripStop> TripStops => Set<TripStop>();
    public DbSet<CollectionRecord> CollectionRecords => Set<CollectionRecord>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Supplier>(entity =>
        {
            entity.HasKey(s => s.Id);
            entity.HasIndex(s => s.SupplierId).IsUnique();
            entity.HasIndex(s => s.BarcodeValue).IsUnique();
            entity.Property(s => s.SupplierId).HasMaxLength(50).IsRequired();
            entity.Property(s => s.BarcodeValue).HasMaxLength(50).IsRequired();
            entity.Property(s => s.Name).HasMaxLength(150).IsRequired();
            entity.Property(s => s.Address).HasMaxLength(300).IsRequired();
            entity.Property(s => s.ExpectedKg).HasPrecision(10, 2);
            entity.Property(s => s.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<Trip>(entity =>
        {
            entity.ToTable(t => t.HasCheckConstraint(
                "CK_Trips_Status",
                "\"Status\" IN ('InProgress', 'Completed')"));
            entity.HasKey(t => t.Id);
            entity.HasIndex(t => t.TripDate);
            entity.Property(t => t.Status).HasMaxLength(30).IsRequired();
            entity.Property(t => t.StartedAt).IsRequired();
            entity.HasMany(t => t.TripStops)
                .WithOne(s => s.Trip)
                .HasForeignKey(s => s.TripId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(t => t.CollectionRecords)
                .WithOne(c => c.Trip)
                .HasForeignKey(c => c.TripId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<TripStop>(entity =>
        {
            entity.ToTable(t => t.HasCheckConstraint(
                "CK_TripStops_Status",
                "\"Status\" IN ('Pending', 'Next', 'Collected')"));
            entity.HasKey(ts => ts.Id);
            entity.HasIndex(ts => new { ts.TripId, ts.SupplierId });
            entity.Property(ts => ts.Status).HasMaxLength(30).IsRequired();
            entity.HasOne(ts => ts.Supplier)
                .WithMany(s => s.TripStops)
                .HasForeignKey(ts => ts.SupplierId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<CollectionRecord>(entity =>
        {
            entity.HasKey(c => c.Id);
            entity.Property(c => c.SupplierCode).HasMaxLength(50).IsRequired();
            entity.Property(c => c.ClearGlassKg).HasPrecision(10, 2);
            entity.Property(c => c.ColouredGlassKg).HasPrecision(10, 2);
            entity.Property(c => c.TotalKg).HasPrecision(10, 2);
            entity.Property(c => c.Condition).HasMaxLength(200).IsRequired();
            entity.HasOne(c => c.Supplier)
                .WithMany(s => s.CollectionRecords)
                .HasForeignKey(c => c.SupplierId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
