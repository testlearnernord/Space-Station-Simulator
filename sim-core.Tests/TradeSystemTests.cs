using System;
using Xunit;
using SimCore.Domain;
using SimCore.Ecs;
using SimCore.Systems;

namespace SimCore.Tests;

public class TradeSystemTests
{
    private static readonly CommodityId Food = new(1);
    private static readonly CommodityId Ore = new(2);

    // Volume: Food = 1 unit/item, Ore = 2 units/item
    private static int Volume(CommodityId c) => c == Ore ? 2 : 1;

    // ── AgentInventory ────────────────────────────────────────────────────────

    [Fact]
    public void AgentInventory_Get_returns_zero_for_missing_commodity()
    {
        var inv = new AgentInventory(50);
        Assert.Equal(0, inv.Get(Food));
    }

    [Fact]
    public void AgentInventory_Set_stores_and_removes_items()
    {
        var inv = new AgentInventory(50);
        inv.Set(Food, 10);
        Assert.Equal(10, inv.Get(Food));
        inv.Set(Food, 0);
        Assert.Equal(0, inv.Get(Food));
        Assert.False(inv.Stacks.ContainsKey(Food));
    }

    [Fact]
    public void AgentInventory_UsedCapacity_accounts_for_volume()
    {
        var inv = new AgentInventory(50);
        inv.Set(Food, 5);   // 5 × 1 = 5 volume
        inv.Set(Ore, 3);    // 3 × 2 = 6 volume
        Assert.Equal(11, inv.UsedCapacity(Volume));
    }

    [Fact]
    public void AgentInventory_AvailableCapacity_is_clamped_to_zero()
    {
        var inv = new AgentInventory(10);
        inv.Set(Food, 12); // Force overfill via raw Set
        Assert.Equal(0, inv.AvailableCapacity(Volume));
    }

    // ── ExecuteBuy ────────────────────────────────────────────────────────────

    [Fact]
    public void ExecuteBuy_succeeds_and_mutates_state()
    {
        var credits = new AgentCredits(500f);
        var agentInv = new AgentInventory(50);
        var stationInv = new AgentInventory(200);
        stationInv.Set(Food, 20);

        var result = TradeSystem.ExecuteBuy(credits, agentInv, stationInv, Food, 5, 10f, Volume);

        Assert.True(result.Success);
        Assert.Equal(TradeError.None, result.Error);
        Assert.Equal(450f, credits.Balance, precision: 2);
        Assert.Equal(5, agentInv.Get(Food));
        Assert.Equal(15, stationInv.Get(Food));
    }

    [Fact]
    public void ExecuteBuy_fails_with_insufficient_funds()
    {
        var credits = new AgentCredits(10f);
        var agentInv = new AgentInventory(50);
        var stationInv = new AgentInventory(200);
        stationInv.Set(Food, 20);

        var result = TradeSystem.ExecuteBuy(credits, agentInv, stationInv, Food, 5, 10f, Volume);

        Assert.False(result.Success);
        Assert.Equal(TradeError.InsufficientFunds, result.Error);
        Assert.Equal(10f, credits.Balance);   // unchanged
        Assert.Equal(0, agentInv.Get(Food));  // unchanged
        Assert.Equal(20, stationInv.Get(Food)); // unchanged
    }

    [Fact]
    public void ExecuteBuy_fails_with_insufficient_station_stock()
    {
        var credits = new AgentCredits(500f);
        var agentInv = new AgentInventory(50);
        var stationInv = new AgentInventory(200);
        stationInv.Set(Food, 2); // only 2 available

        var result = TradeSystem.ExecuteBuy(credits, agentInv, stationInv, Food, 5, 10f, Volume);

        Assert.False(result.Success);
        Assert.Equal(TradeError.InsufficientStock, result.Error);
    }

    [Fact]
    public void ExecuteBuy_fails_when_agent_cargo_full()
    {
        var credits = new AgentCredits(500f);
        var agentInv = new AgentInventory(3);  // only 3 volume free
        var stationInv = new AgentInventory(200);
        stationInv.Set(Food, 20);

        // Buying 5 Food needs 5 volume > 3 available
        var result = TradeSystem.ExecuteBuy(credits, agentInv, stationInv, Food, 5, 10f, Volume);

        Assert.False(result.Success);
        Assert.Equal(TradeError.InsufficientCapacity, result.Error);
    }

    [Fact]
    public void ExecuteBuy_returns_invalid_amount_for_zero()
    {
        var credits = new AgentCredits(500f);
        var agentInv = new AgentInventory(50);
        var stationInv = new AgentInventory(200);
        stationInv.Set(Food, 20);

        var result = TradeSystem.ExecuteBuy(credits, agentInv, stationInv, Food, 0, 10f, Volume);

        Assert.False(result.Success);
        Assert.Equal(TradeError.InvalidAmount, result.Error);
    }

    // ── ExecuteSell ───────────────────────────────────────────────────────────

    [Fact]
    public void ExecuteSell_succeeds_and_mutates_state()
    {
        var credits = new AgentCredits(100f);
        var agentInv = new AgentInventory(50);
        agentInv.Set(Food, 10);
        var stationInv = new AgentInventory(200);

        var result = TradeSystem.ExecuteSell(credits, agentInv, stationInv, Food, 4, 15f, Volume);

        Assert.True(result.Success);
        Assert.Equal(160f, credits.Balance, precision: 2);
        Assert.Equal(6, agentInv.Get(Food));
        Assert.Equal(4, stationInv.Get(Food));
    }

    [Fact]
    public void ExecuteSell_fails_when_agent_has_insufficient_stock()
    {
        var credits = new AgentCredits(100f);
        var agentInv = new AgentInventory(50);
        agentInv.Set(Food, 2); // only 2
        var stationInv = new AgentInventory(200);

        var result = TradeSystem.ExecuteSell(credits, agentInv, stationInv, Food, 5, 15f, Volume);

        Assert.False(result.Success);
        Assert.Equal(TradeError.InsufficientStock, result.Error);
        Assert.Equal(100f, credits.Balance); // unchanged
    }

    [Fact]
    public void ExecuteSell_fails_when_station_cargo_full()
    {
        var credits = new AgentCredits(100f);
        var agentInv = new AgentInventory(50);
        agentInv.Set(Ore, 5);
        var stationInv = new AgentInventory(4); // only 4 volume left, Ore needs 2/unit → fits 2 but not 5
        var result = TradeSystem.ExecuteSell(credits, agentInv, stationInv, Ore, 5, 30f, Volume);

        Assert.False(result.Success);
        Assert.Equal(TradeError.InsufficientCapacity, result.Error);
    }

    [Fact]
    public void ExecuteBuy_then_ExecuteSell_is_balanced()
    {
        var credits = new AgentCredits(200f);
        var agentInv = new AgentInventory(50);
        var stationInv = new AgentInventory(200);
        stationInv.Set(Food, 20);

        // Buy 5 at 10 each → costs 50
        TradeSystem.ExecuteBuy(credits, agentInv, stationInv, Food, 5, 10f, Volume);
        Assert.Equal(150f, credits.Balance, precision: 2);

        // Sell 5 at 12 each → gains 60
        TradeSystem.ExecuteSell(credits, agentInv, stationInv, Food, 5, 12f, Volume);
        Assert.Equal(210f, credits.Balance, precision: 2);
        Assert.Equal(0, agentInv.Get(Food));
        Assert.Equal(20, stationInv.Get(Food));
    }
}
