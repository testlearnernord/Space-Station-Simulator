using System;
using System.Collections.Generic;

namespace SimCore.Ecs;

public sealed class EventBus
{
    private readonly List<object> _events = new();

    public void Publish<T>(T ev) where T : class
    {
        lock (_events)
        {
            _events.Add(ev!);
        }
    }

    public T[] Drain<T>() where T : class
    {
        lock (_events)
        {
            var outList = new List<T>();
            for (int i = _events.Count - 1; i >= 0; i--)
            {
                if (_events[i] is T t) outList.Add(t);
            }
            _events.Clear();
            return outList.ToArray();
        }
    }
}