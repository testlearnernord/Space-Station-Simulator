using System;
using SimCore.Domain;

namespace SimCore.Ecs;

public readonly record struct Position(SystemId System, StationId? Station);
public readonly record struct FactionComp(FactionId Id);

public readonly record struct MarketEntry(CommodityId Commodity, int Supply, int Demand, float BasePrice);

public readonly record struct EnergyComp(int Production, int Consumption);
public readonly record struct ModuleSlots(int Max, int Used);

public readonly record struct ShipCargo(CommodityId Commodity, int Amount);
public readonly record struct ShipRoute(StationId From, StationId To, CommodityId Cargo);