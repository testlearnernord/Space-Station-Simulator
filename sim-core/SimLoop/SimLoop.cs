using System;
using System.Diagnostics;
using System.Threading;
using SimCore.Ecs;

namespace SimCore.SimLoopNS;

public sealed class SimLoop
{
    private readonly World _world;
    private readonly Thread _thread;
    private volatile bool _running;
    private readonly double _tickInterval = 0.1; // 10Hz

    public event Action<double>? OnTick;

    public SimLoop(World world)
    {
        _world = world;
        _thread = new Thread(Run) { IsBackground = true, Name = "SimLoop" };
    }

    public void Start()
    {
        _running = true;
        _thread.Start();
    }

    public void Stop() => _running = false;

    private void Run()
    {
        var sw = Stopwatch.StartNew();
        double acc = 0;
        double prev = sw.Elapsed.TotalSeconds;
        while (_running)
        {
            var now = sw.Elapsed.TotalSeconds;
            var dt = now - prev;
            prev = now;
            acc += dt;
            while (acc >= _tickInterval)
            {
                try
                {
                    OnTick?.Invoke(_tickInterval);
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"SimLoop tick error: {ex}");
                }
                acc -= _tickInterval;
            }
            Thread.Sleep(1);
        }
    }
}