using WasteGlass.Api.Helpers;
using WasteGlass.Api.Models;

namespace WasteGlass.Api.Services;

public class RouteOptimizationService
{
    public RouteOptimizationResult OptimizeRoute(
        IReadOnlyList<Supplier> suppliers,
        double startLatitude,
        double startLongitude)
    {
        if (!GeoHelper.IsValidCoordinate(startLatitude, startLongitude))
        {
            throw new ArgumentOutOfRangeException(
                nameof(startLatitude),
                "Collector start latitude and longitude must be valid GPS coordinates.");
        }

        if (suppliers.Count == 0)
        {
            return new RouteOptimizationResult();
        }

        var validSuppliers = suppliers
            .Where(s => GeoHelper.IsValidCoordinate(s.Latitude, s.Longitude))
            .ToList();

        if (validSuppliers.Count == 0)
        {
            return new RouteOptimizationResult();
        }

        var nodes = BuildNodes(validSuppliers, startLatitude, startLongitude);
        var graph = BuildDistanceGraph(nodes);
        var unvisitedSupplierIndexes = Enumerable.Range(1, validSuppliers.Count).ToHashSet();
        var orderedStops = new List<OptimizedStop>();
        var currentNode = 0;
        var totalDistanceKm = 0.0;
        var stopOrder = 1;

        while (unvisitedSupplierIndexes.Count > 0)
        {
            // Dijkstra gives the shortest distance from the current node to all
            // other nodes in the weighted graph. For this assignment, we use it
            // in a nearest-next-stop style: pick the closest unvisited supplier,
            // move there, then repeat until all suppliers are ordered.
            var distances = CalculateDijkstraDistances(graph, currentNode);
            var nextNode = unvisitedSupplierIndexes
                .OrderBy(nodeIndex => distances[nodeIndex])
                .First();

            var segmentDistanceKm = graph[currentNode, nextNode];
            totalDistanceKm += segmentDistanceKm;

            orderedStops.Add(new OptimizedStop
            {
                Supplier = validSuppliers[nextNode - 1],
                StopOrder = stopOrder++,
                DistanceFromPreviousKm = Math.Round(segmentDistanceKm, 2)
            });

            unvisitedSupplierIndexes.Remove(nextNode);
            currentNode = nextNode;
        }

        return new RouteOptimizationResult
        {
            TotalDistanceKm = Math.Round(totalDistanceKm, 2),
            Stops = orderedStops,
            OrderedSuppliers = orderedStops.Select(stop => stop.Supplier).ToList()
        };
    }

    private static List<RouteNode> BuildNodes(
        IReadOnlyList<Supplier> suppliers,
        double startLatitude,
        double startLongitude)
    {
        var nodes = new List<RouteNode>
        {
            new("DEPOT", startLatitude, startLongitude)
        };

        nodes.AddRange(suppliers.Select(s => new RouteNode(s.SupplierId, s.Latitude, s.Longitude)));
        return nodes;
    }

    private static double[,] BuildDistanceGraph(IReadOnlyList<RouteNode> nodes)
    {
        var graph = new double[nodes.Count, nodes.Count];

        for (var i = 0; i < nodes.Count; i++)
        {
            for (var j = 0; j < nodes.Count; j++)
            {
                graph[i, j] = i == j
                    ? 0
                    : GeoHelper.CalculateHaversineDistanceKm(
                        nodes[i].Latitude,
                        nodes[i].Longitude,
                        nodes[j].Latitude,
                        nodes[j].Longitude);
            }
        }

        return graph;
    }

    private static double[] CalculateDijkstraDistances(double[,] graph, int sourceNode)
    {
        var nodeCount = graph.GetLength(0);
        var distances = Enumerable.Repeat(double.MaxValue, nodeCount).ToArray();
        var visited = new bool[nodeCount];

        distances[sourceNode] = 0;

        for (var i = 0; i < nodeCount - 1; i++)
        {
            var currentNode = GetMinimumDistanceNode(distances, visited);
            if (currentNode == -1)
            {
                break;
            }

            visited[currentNode] = true;

            for (var neighbor = 0; neighbor < nodeCount; neighbor++)
            {
                if (visited[neighbor] || graph[currentNode, neighbor] <= 0)
                {
                    continue;
                }

                var candidateDistance = distances[currentNode] + graph[currentNode, neighbor];
                if (candidateDistance < distances[neighbor])
                {
                    distances[neighbor] = candidateDistance;
                }
            }
        }

        return distances;
    }

    private static int GetMinimumDistanceNode(IReadOnlyList<double> distances, IReadOnlyList<bool> visited)
    {
        var minDistance = double.MaxValue;
        var minNode = -1;

        for (var node = 0; node < distances.Count; node++)
        {
            if (!visited[node] && distances[node] <= minDistance)
            {
                minDistance = distances[node];
                minNode = node;
            }
        }

        return minNode;
    }

    private sealed record RouteNode(string Id, double Latitude, double Longitude);
}

public class RouteOptimizationResult
{
    public List<Supplier> OrderedSuppliers { get; set; } = [];
    public double TotalDistanceKm { get; set; }
    public List<OptimizedStop> Stops { get; set; } = [];
}

public class OptimizedStop
{
    public Supplier Supplier { get; set; } = null!;
    public int StopOrder { get; set; }
    public double DistanceFromPreviousKm { get; set; }
}
