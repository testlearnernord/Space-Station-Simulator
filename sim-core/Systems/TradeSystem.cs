using System;
using SimCore.Domain;
using SimCore.Ecs;

namespace SimCore.Systems;

public enum TradeError { None, InvalidAmount, InsufficientFunds, InsufficientStock, InsufficientCapacity }

public readonly record struct TradeResult(bool Success, TradeError Error);

/// <summary>
/// Pure trade operations shared by player and NPC agents.
/// Both ExecuteBuy and ExecuteSell mutate the provided inventory/credit objects on success.
/// </summary>
public static class TradeSystem
{
    /// <summary>
    /// Agent buys <paramref name="amount"/> units of <paramref name="commodity"/> from a station.
    /// </summary>
    /// <param name="agentCredits">Agent credit balance (mutated on success).</param>
    /// <param name="agentInventory">Agent cargo hold (mutated on success).</param>
    /// <param name="stationInventory">Station stock (mutated on success).</param>
    /// <param name="commodity">Commodity being traded.</param>
    /// <param name="amount">Number of units to buy.</param>
    /// <param name="unitBuyPrice">Price the station charges per unit.</param>
    /// <param name="volumeOf">Returns volume-units per item for a given commodity.</param>
    public static TradeResult ExecuteBuy(
        AgentCredits agentCredits,
        AgentInventory agentInventory,
        AgentInventory stationInventory,
        CommodityId commodity,
        int amount,
        float unitBuyPrice,
        Func<CommodityId, int> volumeOf)
    {
        if (amount <= 0) return new(false, TradeError.InvalidAmount);

        float cost = amount * unitBuyPrice;
        if (agentCredits.Balance < cost)
            return new(false, TradeError.InsufficientFunds);

        if (stationInventory.Get(commodity) < amount)
            return new(false, TradeError.InsufficientStock);

        int volumeNeeded = amount * volumeOf(commodity);
        if (agentInventory.AvailableCapacity(volumeOf) < volumeNeeded)
            return new(false, TradeError.InsufficientCapacity);

        agentCredits.Balance -= cost;
        stationInventory.Set(commodity, stationInventory.Get(commodity) - amount);
        agentInventory.Set(commodity, agentInventory.Get(commodity) + amount);
        return new(true, TradeError.None);
    }

    /// <summary>
    /// Agent sells <paramref name="amount"/> units of <paramref name="commodity"/> to a station.
    /// </summary>
    /// <param name="agentCredits">Agent credit balance (mutated on success).</param>
    /// <param name="agentInventory">Agent cargo hold (mutated on success).</param>
    /// <param name="stationInventory">Station stock (mutated on success).</param>
    /// <param name="commodity">Commodity being traded.</param>
    /// <param name="amount">Number of units to sell.</param>
    /// <param name="unitSellPrice">Price the station pays per unit.</param>
    /// <param name="volumeOf">Returns volume-units per item for a given commodity.</param>
    public static TradeResult ExecuteSell(
        AgentCredits agentCredits,
        AgentInventory agentInventory,
        AgentInventory stationInventory,
        CommodityId commodity,
        int amount,
        float unitSellPrice,
        Func<CommodityId, int> volumeOf)
    {
        if (amount <= 0) return new(false, TradeError.InvalidAmount);

        if (agentInventory.Get(commodity) < amount)
            return new(false, TradeError.InsufficientStock);

        int volumeNeeded = amount * volumeOf(commodity);
        if (stationInventory.AvailableCapacity(volumeOf) < volumeNeeded)
            return new(false, TradeError.InsufficientCapacity);

        float gain = amount * unitSellPrice;
        agentCredits.Balance += gain;
        agentInventory.Set(commodity, agentInventory.Get(commodity) - amount);
        stationInventory.Set(commodity, stationInventory.Get(commodity) + amount);
        return new(true, TradeError.None);
    }
}
