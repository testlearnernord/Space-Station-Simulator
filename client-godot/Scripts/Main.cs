using System;
using Godot;
using SimCore.Systems;

public partial class Main : Node2D
{
    private sealed class Station
    {
        public required string Name { get; init; }
        public required Vector2 Position { get; init; }
        public required float BasePrice { get; init; }
        public required float Distance { get; init; }
        public int Supply { get; set; }
        public int Demand { get; set; }
        public float EventMod { get; set; }
    }

    private static readonly Color StationColor = new(0.3f, 0.7f, 1.0f);
    private static readonly Color PlayerColor = new(1.0f, 0.85f, 0.2f);

    private readonly Station[] _stations =
    {
        new() { Name = "Atlas Hub", Position = new Vector2(260, 160), BasePrice = 34f, Supply = 50, Demand = 32, Distance = 4f, EventMod = 0.02f },
        new() { Name = "Kepler Dock", Position = new Vector2(610, 220), BasePrice = 39f, Supply = 28, Demand = 55, Distance = 11f, EventMod = 0.08f },
        new() { Name = "Helios Yard", Position = new Vector2(430, 460), BasePrice = 31f, Supply = 65, Demand = 24, Distance = 7f, EventMod = -0.03f },
        new() { Name = "Nova Ring", Position = new Vector2(760, 420), BasePrice = 45f, Supply = 20, Demand = 60, Distance = 15f, EventMod = 0.12f }
    };

    private readonly RandomNumberGenerator _rng = new();

    private Vector2 _playerPosition = new(130, 120);
    private float _economyAccumulator;

    private int _credits = 600;
    private int _cargo;
    private const int CargoCapacity = 30;

    private string _status = "Move with WASD. Click near a station to buy/sell alloys.";

    private Label _hudLabel = null!;
    private Label _statusLabel = null!;

    public override void _Ready()
    {
        _rng.Seed = 424242;
        _hudLabel = GetNode<Label>("CanvasLayer/HudLabel");
        _statusLabel = GetNode<Label>("CanvasLayer/StatusLabel");
        UpdateHud();
    }

    public override void _Process(double delta)
    {
        var dt = (float)delta;
        HandleMovement(dt);

        _economyAccumulator += dt;
        if (_economyAccumulator >= 1f)
        {
            _economyAccumulator = 0f;
            TickEconomy();
        }

        if (_credits >= 2000)
        {
            _status = "You win! Keep trading or share this page with friends.";
        }

        UpdateHud();
        QueueRedraw();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseButton { Pressed: true, ButtonIndex: MouseButton.Left })
        {
            TryTradeAtNearestStation();
        }
    }

    public override void _Draw()
    {
        DrawRect(new Rect2(Vector2.Zero, GetViewportRect().Size), new Color(0.03f, 0.04f, 0.08f), filled: true);

        foreach (var station in _stations)
        {
            DrawCircle(station.Position, 20f, StationColor);
            DrawString(ThemeDB.FallbackFont, station.Position + new Vector2(-45f, -30f), station.Name, fontSize: 14);
            DrawString(ThemeDB.FallbackFont, station.Position + new Vector2(-45f, 42f),
                $"Buy {GetBuyPrice(station):0} / Sell {GetSellPrice(station):0}", fontSize: 13);
        }

        DrawCircle(_playerPosition, 10f, PlayerColor);
        DrawString(ThemeDB.FallbackFont, _playerPosition + new Vector2(14f, 4f), "YOU", fontSize: 12);
    }

    private void HandleMovement(float delta)
    {
        var movement = Vector2.Zero;

        if (Input.IsActionPressed("move_left")) movement.X -= 1f;
        if (Input.IsActionPressed("move_right")) movement.X += 1f;
        if (Input.IsActionPressed("move_up")) movement.Y -= 1f;
        if (Input.IsActionPressed("move_down")) movement.Y += 1f;

        if (movement == Vector2.Zero)
        {
            return;
        }

        var speed = 240f;
        var viewportSize = GetViewportRect().Size;
        _playerPosition += movement.Normalized() * speed * delta;
        _playerPosition = _playerPosition.Clamp(new Vector2(24, 24), viewportSize - new Vector2(24, 24));
    }

    private void TickEconomy()
    {
        foreach (var station in _stations)
        {
            station.Supply = Math.Clamp(station.Supply + _rng.RandiRange(-4, 4), 8, 90);
            station.Demand = Math.Clamp(station.Demand + _rng.RandiRange(-4, 4), 8, 90);
            station.EventMod = Math.Clamp(station.EventMod + _rng.RandfRange(-0.01f, 0.01f), -0.25f, 0.25f);
        }
    }

    private void TryTradeAtNearestStation()
    {
        var target = FindClosestStation();
        if (target is null)
        {
            _status = "No station nearby. Move closer before trading.";
            return;
        }

        if (_cargo == 0)
        {
            var buyPrice = (int)MathF.Ceiling(GetBuyPrice(target));
            var affordable = buyPrice <= 0 ? 0 : _credits / buyPrice;
            var unitsToBuy = Math.Min(Math.Min(5, affordable), Math.Min(CargoCapacity - _cargo, target.Supply));

            if (unitsToBuy <= 0)
            {
                _status = "Not enough credits or supply to buy cargo.";
                return;
            }

            _credits -= unitsToBuy * buyPrice;
            _cargo += unitsToBuy;
            target.Supply -= unitsToBuy;
            target.Demand += unitsToBuy;
            _status = $"Bought {unitsToBuy} alloys at {buyPrice} cr each from {target.Name}.";
            return;
        }

        var sellPrice = (int)MathF.Floor(GetSellPrice(target));
        var unitsToSell = Math.Min(5, Math.Min(_cargo, target.Demand));

        if (unitsToSell <= 0)
        {
            _status = $"{target.Name} has no demand right now. Try another station.";
            return;
        }

        _credits += unitsToSell * Math.Max(1, sellPrice);
        _cargo -= unitsToSell;
        target.Demand -= unitsToSell;
        target.Supply += unitsToSell;
        _status = $"Sold {unitsToSell} alloys at {sellPrice} cr each to {target.Name}.";
    }

    private Station FindClosestStation()
    {
        Station best = null;
        var bestDistance = float.MaxValue;

        foreach (var station in _stations)
        {
            var distance = _playerPosition.DistanceTo(station.Position);
            if (distance < bestDistance)
            {
                bestDistance = distance;
                best = station;
            }
        }

        return bestDistance <= 85f ? best : null;
    }

    private float GetBuyPrice(Station station) =>
        Market.Price(station.BasePrice, station.Supply, station.Demand, station.Distance, 0.05f, station.EventMod);

    private float GetSellPrice(Station station)
    {
        var reference = Market.Price(station.BasePrice, station.Supply, station.Demand, station.Distance + 2f, 0.0f, station.EventMod);
        return MathF.Max(1f, MathF.Round(reference * 0.92f));
    }

    private void UpdateHud()
    {
        _hudLabel.Text = $"Credits: {_credits}   Cargo: {_cargo}/{CargoCapacity}   Goal: 2000";
        _statusLabel.Text = _status;
    }
}
