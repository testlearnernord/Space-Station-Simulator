using System;

namespace SimCore.Domain;

/// <summary>Domain identifier types (small, immutable, value types)</summary>
public readonly record struct FactionId(int Value);
public readonly record struct SystemId(int Value);
public readonly record struct StationId(int Value);
public readonly record struct ShipId(int Value);
public readonly record struct CommodityId(int Value);