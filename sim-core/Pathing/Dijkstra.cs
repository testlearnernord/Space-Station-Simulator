using System;
using System.Collections.Generic;
using System.Linq;

namespace SimCore.Pathing;

public class Graph
{
    private readonly Dictionary<int, List<int>> _adj = new();

    public void AddEdge(int a, int b)
    {
        if (!_adj.TryGetValue(a, out var la)) { la = new List<int>(); _adj[a] = la; }
        if (!_adj.TryGetValue(b, out var lb) ) { lb = new List<int>(); _adj[b] = lb; }
        la.Add(b); lb.Add(a);
    }

    public int? Shortest(int from, int to)
    {
        if (from == to) return 0;
        var q = new Queue<int>();
        var dist = new Dictionary<int,int>();
        q.Enqueue(from); dist[from] = 0;
        while (q.Count>0)
        {
            var u = q.Dequeue();
            if (!_adj.TryGetValue(u, out var neigh)) continue;
            foreach(var v in neigh)
            {
                if (dist.ContainsKey(v)) continue;
                dist[v] = dist[u] + 1;
                if (v == to) return dist[v];
                q.Enqueue(v);
            }
        }
        return null;
    }
}