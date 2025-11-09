using Xunit;
using SimCore.Pathing;

namespace SimCore.Tests;

public class PathingTests
{
    [Fact]
    public void Shortest_returns_expected_distance()
    {
        var g = new Graph();
        g.AddEdge(1,2); g.AddEdge(2,3);
        var d = g.Shortest(1,3);
        Assert.Equal(2, d);
    }

    [Fact]
    public void Shortest_returns_null_when_disconnected()
    {
        var g = new Graph(); g.AddEdge(1,2); g.AddEdge(3,4);
        var d = g.Shortest(1,4);
        Assert.Null(d);
    }
}