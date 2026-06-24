namespace WasteGlass.Api.Helpers;

public static class GeoHelper
{
    private const double EarthRadiusKm = 6371.0;

    public static double CalculateHaversineDistanceKm(
        double lat1,
        double lon1,
        double lat2,
        double lon2)
    {
        ValidateCoordinates(lat1, lon1);
        ValidateCoordinates(lat2, lon2);

        // Haversine estimates the great-circle distance between two GPS points
        // on the earth's surface. It is a good practical fit for nearby route
        // planning where road-network data is not available.
        var dLat = ToRadians(lat2 - lat1);
        var dLon = ToRadians(lon2 - lon1);

        var lat1Radians = ToRadians(lat1);
        var lat2Radians = ToRadians(lat2);

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
            + Math.Cos(lat1Radians) * Math.Cos(lat2Radians)
            * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return EarthRadiusKm * c;
    }

    public static bool IsValidCoordinate(double latitude, double longitude)
    {
        return !double.IsNaN(latitude)
            && !double.IsInfinity(latitude)
            && !double.IsNaN(longitude)
            && !double.IsInfinity(longitude)
            && latitude is >= -90 and <= 90
            && longitude is >= -180 and <= 180;
    }

    public static double HaversineDistanceKm(
        double latitude1,
        double longitude1,
        double latitude2,
        double longitude2)
    {
        return CalculateHaversineDistanceKm(latitude1, longitude1, latitude2, longitude2);
    }

    private static void ValidateCoordinates(double latitude, double longitude)
    {
        if (!IsValidCoordinate(latitude, longitude))
        {
            throw new ArgumentOutOfRangeException(
                nameof(latitude),
                $"Invalid GPS coordinate: latitude {latitude}, longitude {longitude}.");
        }
    }

    private static double ToRadians(double degrees) => degrees * Math.PI / 180;
}
