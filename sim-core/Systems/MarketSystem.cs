using System;
using SimCore.Domain;

namespace SimCore.Systems;

public static class Market
{
    /// <summary>
    /// Pure function to compute price given supply/demand and modifiers.
    /// </summary>
    public static float Price(float basePrice, int supply, int demand, float distance, float factionTax, float eventMod)
    {
        // Basic supply-demand ratio (avoid div-by-zero)
        var sd = (supply + 1) / (float)(demand + 1);
        // Price modifier: scarcity increases price
        var scarcity = MathF.Max(0.2f, 1.0f / sd);
        // distance cost factor
        var distFactor = 1.0f + distance * 0.01f; // 1% per unit
        // tax and event modify price multiplicatively
        var raw = basePrice * scarcity * distFactor * (1.0f + factionTax) * (1.0f + eventMod);
        // clamp min price
        var min = MathF.Max(0.01f, basePrice * 0.1f);
        var clamped = MathF.Max(min, raw);
        // round to 2 decimals
        return MathF.Round(clamped * 100f) / 100f;
    }
}