using System;
using System.Collections.Generic;
using System.Linq;
using SimCore.Domain;

namespace SimCore.Ecs;

public readonly record struct Position(SystemId System, StationId? Station);
public readonly record struct FactionComp(FactionId Id);

public readonly record struct MarketEntry(CommodityId Commodity, int Supply, int Demand, float BasePrice);

public readonly record struct EnergyComp(int Production, int Consumption);
public readonly record struct ModuleSlots(int Max, int Used);

public readonly record struct ShipCargo(CommodityId Commodity, int Amount);
public readonly record struct ShipRoute(StationId From, StationId To, CommodityId Cargo);

/// <summary>Mutable cargo hold shared by player and NPC agents.</summary>
public sealed class AgentInventory
{
    public int Capacity { get; }
    public Dictionary<CommodityId, int> Stacks { get; } = new();

    public AgentInventory(int capacity) { Capacity = capacity; }

    public int Get(CommodityId c) => Stacks.TryGetValue(c, out var v) ? v : 0;

    public void Set(CommodityId c, int amount)
    {
        if (amount <= 0) Stacks.Remove(c);
        else Stacks[c] = amount;
    }

    /// <param name="volumeOf">Returns volume-units per item for a given commodity.</param>
    public int UsedCapacity(Func<CommodityId, int> volumeOf) =>
        Stacks.Sum(kv => kv.Value * volumeOf(kv.Key));

    /// <param name="volumeOf">Returns volume-units per item for a given commodity.</param>
    public int AvailableCapacity(Func<CommodityId, int> volumeOf) =>
        Math.Max(0, Capacity - UsedCapacity(volumeOf));
}

/// <summary>Mutable credit balance for any agent.</summary>
public sealed class AgentCredits
{
    public float Balance { get; set; }
    public AgentCredits(float balance) { Balance = balance; }
}

public enum AgentRoleKind { Player, Npc }

public sealed class AgentRoleComp
{
    public AgentRoleKind Role { get; }
    public AgentRoleComp(AgentRoleKind role) { Role = role; }
}

public enum AgentStateKind { Idle, Traveling }

public sealed class AgentStateComp
{
    public AgentStateKind State { get; set; } = AgentStateKind.Idle;
}