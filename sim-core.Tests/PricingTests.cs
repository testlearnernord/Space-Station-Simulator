using Xunit;
using SimCore.Systems;

namespace SimCore.Tests;

public class PricingTests
{
    [Theory]
    [InlineData(12f, 90, 10, 5f, 0.06f, 0f)]
    [InlineData(30f, 1, 100, 50f, 0.02f, 0.5f)]
    public void Price_produces_reasonable_values(float baseP, int s, int d, float dist, float tax, float ev)
    {
        var p = Market.Price(baseP, s, d, dist, tax, ev);
        Assert.True(p >= 0.01f);
    }

    [Fact]
    public void Price_rounds_two_decimals()
    {
        var p = Market.Price(13.3333f, 10, 5, 1f, 0.0f, 0f);
        var decimals = (p * 100) % 1;
        Assert.Equal(0f, decimals);
    }
}