using System;
using System.Collections.Generic;
using System.Threading;
using SimCore.Domain;

namespace SimCore.Ecs;

public sealed class World
{
    // Very small, explicit storage for demo purposes
    private int _nextEntity = 1;
    public readonly Dictionary<int, Dictionary<Type, object>> Entities = new();
    public readonly Random Rng;
    public readonly EventBus Events = new();

    public World(int seed)
    {
        Rng = new Random(seed);
    }

    public int CreateEntity()
    {
        var id = Interlocked.Increment(ref _nextEntity);
        Entities[id] = new Dictionary<Type, object>();
        return id;
    }

    public void AddComponent<T>(int entity, T comp) where T : class
    {
        Entities[entity][typeof(T)] = comp!;
    }

    public bool TryGetComponent<T>(int entity, out T? comp) where T : class
    {
        if (Entities.TryGetValue(entity, out var map) && map.TryGetValue(typeof(T), out var o))
        {
            comp = o as T;
            return true;
        }
        comp = null;
        return false;
    }
}