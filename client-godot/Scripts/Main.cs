using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using Godot;

#nullable enable

public partial class Main : Node2D
{
    private sealed class ResourceDef
    {
        public required string Id { get; init; }
        public required string DisplayName { get; init; }
        public required int Tier { get; init; }
        public required string Category { get; init; }
        public required string Icon { get; init; }
        public required float BasePrice { get; init; }
        public required int VolumePerUnit { get; init; }
        public required string Description { get; init; }
    }

    private sealed class Inventory
    {
        public required int Capacity { get; set; }
        public Dictionary<string, int> Stacks { get; } = new();
    }

    private sealed class StationType
    {
        public required string Id { get; init; }
        public required string DisplayName { get; init; }
        public required int Capacity { get; init; }
        public required Dictionary<string, int> TargetStock { get; init; }
        public required Dictionary<string, int> Production { get; init; }
        public required Dictionary<string, int> Consumption { get; init; }
    }

    private sealed class Station
    {
        public required string Id { get; init; }
        public required string Name { get; set; }
        public required string TypeId { get; init; }
        public required Vector2 Position { get; init; }
        public required float Distance { get; init; }
        public float EventMod { get; set; }
        public required Inventory Inventory { get; init; }
        public required Dictionary<string, int> TargetStock { get; init; }
    }

    private sealed class NpcTrader
    {
        public required string Name { get; init; }
        public required int CargoCapacity { get; init; }
        public required float Efficiency { get; init; }
    }

    private sealed class UiRow
    {
        public required string ResourceId { get; init; }
        public required int Amount { get; init; }
        public required int UnitPrice { get; init; }
        public required int TotalValue { get; init; }
        public required int TotalVolume { get; init; }
    }

    private sealed class SaveData
    {
        public int Version { get; set; }
        public int Credits { get; set; }
        public SaveVector2 PlayerPosition { get; set; } = new();
        public SaveInventory PlayerInventory { get; set; } = new();
        public Dictionary<string, float> PlayerAvgBuy { get; set; } = new();
        public List<SaveStation> Stations { get; set; } = new();
        public List<string> TradeLog { get; set; } = new();
        public bool GoalReached { get; set; }
        public bool HasOwnStation { get; set; }
        public string SelectedResource { get; set; } = DefaultResourceId;
        public int Quantity { get; set; }
        public string Search { get; set; } = string.Empty;
        public string SortKey { get; set; } = "value";
        public bool SortAscending { get; set; }
    }

    private sealed class SaveVector2
    {
        public float X { get; set; }
        public float Y { get; set; }
    }

    private sealed class SaveInventory
    {
        public int Capacity { get; set; }
        public Dictionary<string, int> Stacks { get; set; } = new();
    }

    private sealed class SaveStation
    {
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string TypeId { get; set; } = string.Empty;
        public SaveVector2 Position { get; set; } = new();
        public float Distance { get; set; }
        public float EventMod { get; set; }
        public Dictionary<string, int> TargetStock { get; set; } = new();
        public SaveInventory Inventory { get; set; } = new();
    }

    private const int SaveVersion = 2;
    private const string SavePath = "user://savegame.json";
    private const string DefaultResourceId = "wood";
    private const int CargoCapacity = 32;

    private const float Acceleration = 520f;
    private const float Drag = 360f;
    private const float BaseMaxSpeed = 250f;
    private const float BoostMultiplier = 1.75f;
    private const float DockRange = 150f;
    private const float DockHoldTime = 1.2f;

    private const float EconomyTick = 1f;
    private const float NpcTick = 2.4f;
    private const float SaveTick = 5f;
    private const int MaxTradeLogEntries = 12;
    private const int StarfieldStarCount = 95;
    private const int SeedVarianceMin = -6;
    private const int SeedVarianceMax = 6;
    private const int MinInitialStock = 2;
    private const int MaxInitialStockBonus = 12;
    private const float NpcMinTradeRatio = 0.35f;
    private const float NpcMaxTradeRatio = 0.8f;
    private const float BuyMarkup = 1.06f;
    private const float SellMarkdown = 0.9f;
    private const float PressureClampMin = -1.2f;
    private const float PressureClampMax = 1.2f;
    private const float PressurePriceFactor = 0.45f;
    private const float DistancePriceFactor = 0.01f;
    private const float MinPriceMultiplier = 0.45f;
    private const float MaxPriceMultiplier = 2.6f;
    private const float VeryHighDemandRatio = 0.45f;
    private const float LowStockRatio = 0.8f;
    private const float OverstockRatio = 1.5f;

    private static readonly Color StationColor = new(0.35f, 0.75f, 1f);
    private static readonly Color PlayerColor = new(1f, 0.86f, 0.25f);
    private static readonly Color PanelColor = new(0.07f, 0.1f, 0.17f, 0.92f);
    private static readonly Color PanelBorder = new(0.35f, 0.8f, 1f, 0.8f);
    private static readonly Color GoodColor = new(0.35f, 1f, 0.55f);
    private static readonly Color BadColor = new(1f, 0.35f, 0.35f);
    private static readonly Color CreditColor = new(1f, 0.86f, 0.25f);

    private static readonly Dictionary<int, Color> TierBorderColor = new()
    {
        [1] = new Color(0.95f, 0.95f, 0.98f),
        [2] = new Color(0.35f, 0.95f, 0.45f)
    };

    private static readonly Dictionary<string, ResourceDef> Resources = new()
    {
        ["wood"] = new() { Id = "wood", DisplayName = "Holz", Tier = 1, Category = "Rohstoff", Icon = "▦", BasePrice = 18f, VolumePerUnit = 1, Description = "Leichtes Baumaterial." },
        ["coal"] = new() { Id = "coal", DisplayName = "Kohle", Tier = 1, Category = "Rohstoff", Icon = "◼", BasePrice = 21f, VolumePerUnit = 1, Description = "Brennstoff und Industriegrundstoff." },
        ["copper_plate"] = new() { Id = "copper_plate", DisplayName = "Kupferplatte", Tier = 2, Category = "Verarbeitetes Material", Icon = "▤", BasePrice = 44f, VolumePerUnit = 2, Description = "Leitfähiges Material." },
        ["plastic"] = new() { Id = "plastic", DisplayName = "Plastik", Tier = 2, Category = "Verarbeitetes Material", Icon = "⬡", BasePrice = 40f, VolumePerUnit = 2, Description = "Vielseitiger Verbundwerkstoff." }
    };

    private static readonly string[] ResourceIds = ["wood", "coal", "copper_plate", "plastic"];
    private static readonly string[] SortKeys = ["name", "tier", "amount", "value", "unit_price"];

    private static readonly Dictionary<string, StationType> StationTypes = new()
    {
        ["mining_outpost"] = new() { Id = "mining_outpost", DisplayName = "Bergbau-Außenposten", Capacity = 120,
            TargetStock = new() { ["wood"] = 16, ["coal"] = 50, ["copper_plate"] = 14, ["plastic"] = 10 },
            Production = new() { ["coal"] = 4 }, Consumption = new() { ["plastic"] = 1, ["copper_plate"] = 1 } },
        ["wood_processing"] = new() { Id = "wood_processing", DisplayName = "Holzverarbeitung", Capacity = 115,
            TargetStock = new() { ["wood"] = 48, ["coal"] = 16, ["copper_plate"] = 10, ["plastic"] = 18 },
            Production = new() { ["wood"] = 4 }, Consumption = new() { ["coal"] = 2, ["plastic"] = 1 } },
        ["industry_hub"] = new() { Id = "industry_hub", DisplayName = "Industrie-Hub", Capacity = 145,
            TargetStock = new() { ["wood"] = 26, ["coal"] = 28, ["copper_plate"] = 30, ["plastic"] = 30 },
            Production = new() { ["copper_plate"] = 2, ["plastic"] = 2 }, Consumption = new() { ["wood"] = 2, ["coal"] = 2 } },
        ["trade_station"] = new() { Id = "trade_station", DisplayName = "Handelsstation", Capacity = 165,
            TargetStock = new() { ["wood"] = 24, ["coal"] = 24, ["copper_plate"] = 22, ["plastic"] = 22 },
            Production = new(), Consumption = new() }
    };

    private readonly RandomNumberGenerator _rng = new();
    private readonly List<Station> _stations = new();
    private readonly List<NpcTrader> _npcs = new();
    private readonly Inventory _playerInventory = new() { Capacity = CargoCapacity };
    private readonly Dictionary<string, float> _avgBuyPrice = new();
    private readonly List<string> _tradeLog = new();
    private readonly List<Dictionary<string, Variant>> _stars = new();

    private Label _hudLabel = null!;
    private Label _statusLabel = null!;

    private Vector2 _playerPosition = new(130, 120);
    private Vector2 _playerVelocity;
    private float _playerRotation;

    private int _credits = 600;
    private bool _isDocked;
    private Station? _dockingStation;
    private float _dockingProgress;
    private bool _wasDockHeld;
    private bool _goalReached;
    private bool _hasOwnStation;

    private float _economyAccumulator;
    private float _npcAccumulator;
    private float _saveAccumulator;
    private float _visualTime;

    private string _status = "Fly with WASD, hold C near station to dock.";
    private string _sortKey = "value";
    private bool _sortAscending;
    private string _search = string.Empty;
    private string _selectedResourceId = DefaultResourceId;
    private int _quantity = 1;

    private string _toastText = string.Empty;
    private float _toastTimer;
    private bool _lastTradeFailed;

    private Rect2 _buyRect;
    private Rect2 _sellRect;
    private Rect2 _plusOneRect;
    private Rect2 _plusFiveRect;
    private Rect2 _maxRect;
    private Rect2 _sellAllRect;
    private Rect2 _sortRect;
    private Rect2 _dirRect;
    private readonly Dictionary<Rect2, string> _resourceHitRects = new();

    public override void _Ready()
    {
        _rng.Seed = 424242;
        _hudLabel = GetNode<Label>("CanvasLayer/HudLabel");
        _statusLabel = GetNode<Label>("CanvasLayer/StatusLabel");
        ValidateResourceConfig();

        SetupDefaults();
        LoadState();
        GenerateStarfield();
        EnsureResourceSelected();
        UpdateHud();
    }

    public override void _ExitTree() => SaveState();

    public override void _Process(double delta)
    {
        var dt = (float)delta;
        _visualTime += dt;

        if (_isDocked)
        {
            _playerVelocity = Vector2.Zero;
            if (_dockingStation is not null)
            {
                _playerPosition = GetDockPoint(_dockingStation);
                _playerRotation = (_dockingStation.Position - _playerPosition).Angle();
            }

            if (Input.IsActionPressed("move_left") || Input.IsActionPressed("move_right") ||
                Input.IsActionPressed("move_up") || Input.IsActionPressed("move_down"))
            {
                _isDocked = false;
                _status = "Undocked. Hold C near a station to dock again.";
            }
        }
        else
        {
            HandleMovement(dt);
            UpdateDocking(dt);
        }

        _economyAccumulator += dt;
        _npcAccumulator += dt;
        _saveAccumulator += dt;

        if (_economyAccumulator >= EconomyTick)
        {
            _economyAccumulator = 0f;
            TickEconomy();
        }

        if (_npcAccumulator >= NpcTick)
        {
            _npcAccumulator = 0f;
            RunNpcTrades();
        }

        if (_saveAccumulator >= SaveTick)
        {
            _saveAccumulator = 0f;
            SaveState();
        }

        if (_credits >= 2000 && !_goalReached)
        {
            _goalReached = true;
            _status = "Goal reached! Keep optimizing your trade routes.";
        }

        if (_credits >= 2600 && !_hasOwnStation)
        {
            _hasOwnStation = true;
            BuildPlayerStation();
            _status = "You founded a private station node.";
        }

        if (_toastTimer > 0f)
        {
            _toastTimer -= dt;
            if (_toastTimer <= 0f)
            {
                _toastText = string.Empty;
            }
        }

        UpdateHud();
        QueueRedraw();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseButton { Pressed: true, ButtonIndex: MouseButton.Left } mb)
        {
            HandleLeftClick(mb.Position);
            return;
        }

        if (!_isDocked || @event is not InputEventKey { Pressed: true, Echo: false } key) return;

        if (key.Keycode == Key.Tab)
        {
            CycleSort();
        }
        else if (key.Keycode == Key.R)
        {
            _sortAscending = !_sortAscending;
        }
        else if (key.Keycode is Key.Plus or Key.KpAdd or Key.Equal)
        {
            _quantity = Math.Min(999, _quantity + 1);
        }
        else if (key.Keycode is Key.Minus or Key.KpSubtract)
        {
            _quantity = Math.Max(1, _quantity - 1);
        }
        else if (key.Keycode == Key.Backspace)
        {
            if (_search.Length > 0) _search = _search[..^1];
        }
        else if (key.Keycode == Key.Escape)
        {
            _search = string.Empty;
        }
        else if (key.Unicode is > 31 and < 127)
        {
            var ch = char.ToLowerInvariant((char)key.Unicode);
            if (!char.IsControl(ch)) _search += ch;
        }
    }

    public override void _Draw()
    {
        DrawBackground();
        for (var i = 0; i < _stations.Count; i++) DrawStation(_stations[i], i);
        DrawNpcMarkers();

        if (_hasOwnStation) DrawOwnStation();
        else DrawShip();

        _resourceHitRects.Clear();
        if (_isDocked && _dockingStation is not null) DrawTradeInterface(_dockingStation);

        if (!string.IsNullOrEmpty(_toastText)) DrawToast();
    }

    private void SetupDefaults()
    {
        _stations.Clear();
        _npcs.Clear();
        _playerInventory.Stacks.Clear();
        _avgBuyPrice.Clear();

        _stations.Add(CreateStation("station_a", "Atlas Hub", new Vector2(260, 160), "mining_outpost", 4f, 0.01f));
        _stations.Add(CreateStation("station_b", "Kepler Dock", new Vector2(610, 220), "wood_processing", 10f, 0.05f));
        _stations.Add(CreateStation("station_c", "Helios Yard", new Vector2(430, 460), "industry_hub", 7f, -0.01f));
        _stations.Add(CreateStation("station_d", "Nova Ring", new Vector2(760, 420), "trade_station", 14f, 0.08f));

        foreach (var station in _stations)
        {
            foreach (var resourceId in ResourceIds)
            {
                var target = station.TargetStock[resourceId];
                var initialStock = Math.Clamp(target + _rng.RandiRange(SeedVarianceMin, SeedVarianceMax), MinInitialStock, target + MaxInitialStockBonus);
                AddToInventory(station.Inventory, resourceId, initialStock);
            }
        }

        _npcs.Add(new NpcTrader { Name = "Local Trader", CargoCapacity = 20, Efficiency = 0.65f });
        _npcs.Add(new NpcTrader { Name = "Bulk Hauler", CargoCapacity = 28, Efficiency = 0.82f });
        _npcs.Add(new NpcTrader { Name = "Opportunist", CargoCapacity = 18, Efficiency = 0.55f });
    }

    private Station CreateStation(string id, string name, Vector2 position, string typeId, float distance, float eventMod)
    {
        var type = StationTypes[typeId];
        return new Station
        {
            Id = id,
            Name = name,
            TypeId = typeId,
            Position = position,
            Distance = distance,
            EventMod = eventMod,
            Inventory = new Inventory { Capacity = type.Capacity },
            TargetStock = type.TargetStock.ToDictionary(k => k.Key, v => v.Value)
        };
    }

    private void HandleMovement(float dt)
    {
        var movement = Vector2.Zero;
        if (Input.IsActionPressed("move_left")) movement.X -= 1f;
        if (Input.IsActionPressed("move_right")) movement.X += 1f;
        if (Input.IsActionPressed("move_up")) movement.Y -= 1f;
        if (Input.IsActionPressed("move_down")) movement.Y += 1f;

        if (movement != Vector2.Zero)
        {
            var boost = Input.IsKeyPressed(Key.Shift) ? BoostMultiplier : 1f;
            _playerVelocity += movement.Normalized() * Acceleration * boost * dt;
        }
        else
        {
            _playerVelocity = _playerVelocity.MoveToward(Vector2.Zero, Drag * dt);
        }

        var maxSpeed = BaseMaxSpeed * (Input.IsKeyPressed(Key.Shift) ? BoostMultiplier : 1f);
        if (_playerVelocity.Length() > maxSpeed)
        {
            _playerVelocity = _playerVelocity.Normalized() * maxSpeed;
        }

        if (_playerVelocity.Length() > 8f)
        {
            _playerRotation = Mathf.LerpAngle(_playerRotation, _playerVelocity.Angle(), dt * 7.5f);
        }

        var size = GetViewportRect().Size;
        _playerPosition += _playerVelocity * dt;
        _playerPosition = _playerPosition.Clamp(new Vector2(24, 24), size - new Vector2(24, 24));
    }

    private void UpdateDocking(float dt)
    {
        var candidate = FindClosestStation(DockRange);
        var dockPressed = Input.IsKeyPressed(Key.C);

        if (candidate is null)
        {
            _dockingProgress = 0;
            _dockingStation = null;
            _wasDockHeld = dockPressed;
            return;
        }

        if (!dockPressed)
        {
            if (_dockingProgress > 0f) _status = $"Hold C to dock with {candidate.Name}.";
            _dockingStation = candidate;
            _dockingProgress = 0f;
            _wasDockHeld = false;
            return;
        }

        if (_dockingStation != candidate)
        {
            _dockingStation = candidate;
            _dockingProgress = 0f;
        }

        _playerPosition = _playerPosition.Lerp(GetDockPoint(candidate), Mathf.Clamp(dt * 3.6f, 0f, 1f));
        _playerVelocity = _playerVelocity.Lerp(Vector2.Zero, Mathf.Clamp(dt * 3.6f, 0f, 1f));
        _dockingProgress = Math.Min(DockHoldTime, _dockingProgress + dt);

        _status = $"Docking at {candidate.Name}... {(int)Mathf.Round(100f * _dockingProgress / DockHoldTime)}%";
        if (_dockingProgress >= DockHoldTime)
        {
            _isDocked = true;
            _dockingStation = candidate;
            _dockingProgress = 0f;
        }

        _wasDockHeld = true;
    }

    private Station? FindClosestStation(float maxDistance)
    {
        Station? closest = null;
        var best = float.MaxValue;

        foreach (var station in _stations)
        {
            var dist = _playerPosition.DistanceTo(station.Position);
            if (dist < best)
            {
                best = dist;
                closest = station;
            }
        }

        return best <= maxDistance ? closest : null;
    }

    private void TickEconomy()
    {
        foreach (var station in _stations)
        {
            var type = StationTypes[station.TypeId];
            foreach (var resourceId in ResourceIds)
            {
                var amount = GetInventoryAmount(station.Inventory, resourceId);
                var drift = _rng.RandiRange(-1, 1);
                if (type.Production.TryGetValue(resourceId, out var prod)) drift += prod;
                if (type.Consumption.TryGetValue(resourceId, out var cons)) drift -= cons;
                SetInventoryAmount(station.Inventory, resourceId, Math.Max(0, amount + drift));
            }

            station.EventMod = Mathf.Clamp(station.EventMod + _rng.RandfRange(-0.006f, 0.006f), -0.2f, 0.2f);
            TrimInventoryToCapacity(station.Inventory);
        }
    }

    private void RunNpcTrades()
    {
        if (_stations.Count < 2) return;

        foreach (var npc in _npcs)
        {
            if (_rng.Randf() > npc.Efficiency) continue;
            var route = FindNpcRoute(npc);
            if (route is null) continue;

            var resourceId = route.Value.resourceId;
            var from = route.Value.from;
            var to = route.Value.to;
            var amount = route.Value.amount;

            amount = Math.Min(amount, GetInventoryAmount(from.Inventory, resourceId));
            amount = Math.Min(amount, GetAvailableCapacity(to.Inventory) / Resources[resourceId].VolumePerUnit);
            if (amount <= 0) continue;

            RemoveFromInventory(from.Inventory, resourceId, amount);
            AddToInventory(to.Inventory, resourceId, amount);

            AddTradeLog($"NPC {npc.Name}: {amount} {Resources[resourceId].Icon} {Resources[resourceId].DisplayName} {from.Name} → {to.Name}");
        }
    }

    private (string resourceId, Station from, Station to, int amount)? FindNpcRoute(NpcTrader npc)
    {
        float bestProfit = 0f;
        (string resourceId, Station from, Station to, int amount)? best = null;

        foreach (var resourceId in ResourceIds)
        {
            var volume = Resources[resourceId].VolumePerUnit;
            foreach (var from in _stations)
            {
                foreach (var to in _stations)
                {
                    if (from.Id == to.Id) continue;

                    var unitProfit = GetStationSellPrice(to, resourceId) - GetStationBuyPrice(from, resourceId);
                    if (unitProfit < 2) continue;

                    var amount = Math.Min(GetInventoryAmount(from.Inventory, resourceId), npc.CargoCapacity / volume);
                    amount = Math.Min(amount, GetAvailableCapacity(to.Inventory) / volume);
                    amount = Math.Max(0, (int)Mathf.Round(amount * _rng.RandfRange(NpcMinTradeRatio, NpcMaxTradeRatio)));
                    if (amount <= 0) continue;

                    var expected = unitProfit * amount;
                    if (expected <= bestProfit) continue;

                    bestProfit = expected;
                    best = (resourceId, from, to, amount);
                }
            }
        }

        return best;
    }

    private int GetStationBuyPrice(Station station, string resourceId)
    {
        var basePrice = CalculateBasePrice(station, resourceId);
        return (int)MathF.Ceiling(basePrice * BuyMarkup);
    }

    private int GetStationSellPrice(Station station, string resourceId)
    {
        var basePrice = CalculateBasePrice(station, resourceId);
        return Math.Max(1, (int)MathF.Floor(basePrice * SellMarkdown));
    }

    private float CalculateBasePrice(Station station, string resourceId)
    {
        var resource = Resources[resourceId];
        var target = Math.Max(1, station.TargetStock[resourceId]);
        var current = GetInventoryAmount(station.Inventory, resourceId);
        var pressure = Mathf.Clamp((target - current) / (float)target, PressureClampMin, PressureClampMax);

        var tierBonus = 1f + 0.1f * (resource.Tier - 1);
        var volatility = 1f + pressure * PressurePriceFactor + station.EventMod;
        var distance = 1f + station.Distance * DistancePriceFactor;

        var raw = resource.BasePrice * tierBonus * volatility * distance;
        return Mathf.Clamp(raw, resource.BasePrice * MinPriceMultiplier, resource.BasePrice * MaxPriceMultiplier);
    }

    private string GetStockState(Station station, string resourceId)
    {
        var target = Math.Max(1, station.TargetStock[resourceId]);
        var ratio = GetInventoryAmount(station.Inventory, resourceId) / (float)target;

        if (ratio < VeryHighDemandRatio) return "Sehr gefragt";
        if (ratio < LowStockRatio) return "Knapp";
        if (ratio > OverstockRatio) return "Überschuss";
        return "Stabil";
    }

    private void HandleLeftClick(Vector2 pos)
    {
        if (_isDocked && _dockingStation is not null)
        {
            if (_buyRect.HasPoint(pos)) { AttemptTrade(true); return; }
            if (_sellRect.HasPoint(pos)) { AttemptTrade(false); return; }
            if (_plusOneRect.HasPoint(pos)) { _quantity = Math.Min(999, _quantity + 1); return; }
            if (_plusFiveRect.HasPoint(pos)) { _quantity = Math.Min(999, _quantity + 5); return; }
            if (_maxRect.HasPoint(pos)) { _quantity = Math.Max(1, MaxBuy(_selectedResourceId, _dockingStation)); return; }
            if (_sellAllRect.HasPoint(pos)) { _quantity = Math.Max(1, GetInventoryAmount(_playerInventory, _selectedResourceId)); AttemptTrade(false); return; }
            if (_sortRect.HasPoint(pos)) { CycleSort(); return; }
            if (_dirRect.HasPoint(pos)) { _sortAscending = !_sortAscending; return; }

            foreach (var hit in _resourceHitRects)
            {
                if (!hit.Key.HasPoint(pos)) continue;
                _selectedResourceId = hit.Value;
                return;
            }
        }
    }

    private void AttemptTrade(bool buy)
    {
        if (_dockingStation is null) return;
        var resourceId = _selectedResourceId;
        var amount = Math.Max(1, _quantity);
        var resource = Resources[resourceId];

        if (buy)
        {
            var price = GetStationBuyPrice(_dockingStation, resourceId);
            var cost = amount * price;

            if (_credits < cost) { FailTrade("Nicht genug Credits."); return; }
            if (GetInventoryAmount(_dockingStation.Inventory, resourceId) < amount) { FailTrade("Station hat zu wenig Bestand."); return; }
            if (GetAvailableCapacity(_playerInventory) < amount * resource.VolumePerUnit) { FailTrade("Nicht genug Frachtraum."); return; }

            _credits -= cost;
            RemoveFromInventory(_dockingStation.Inventory, resourceId, amount);
            AddToInventory(_playerInventory, resourceId, amount);
            UpdateAverageBuy(resourceId, amount, price);

            AddTradeLog($"Gekauft: {amount} {resource.Icon} {resource.DisplayName} @ {price} von {_dockingStation.Name}");
            SuccessTrade("Kauf erfolgreich.");
            return;
        }

        var sellPrice = GetStationSellPrice(_dockingStation, resourceId);
        var gain = amount * sellPrice;

        if (GetInventoryAmount(_playerInventory, resourceId) < amount) { FailTrade("Ressource fehlt im Inventar."); return; }
        if (GetAvailableCapacity(_dockingStation.Inventory) < amount * resource.VolumePerUnit) { FailTrade("Stationslager ist voll."); return; }

        _credits += gain;
        RemoveFromInventory(_playerInventory, resourceId, amount);
        AddToInventory(_dockingStation.Inventory, resourceId, amount);

        AddTradeLog($"Verkauft: {amount} {resource.Icon} {resource.DisplayName} @ {sellPrice} an {_dockingStation.Name}");
        SuccessTrade("Verkauf erfolgreich.");
    }

    private void DrawBackground()
    {
        var size = GetViewportRect().Size;
        DrawRect(new Rect2(Vector2.Zero, size), new Color(0.01f, 0.02f, 0.07f), true);
        DrawCircle(size * 0.75f, 220f, new Color(0.08f, 0.05f, 0.16f, 0.38f));
        DrawCircle(size * new Vector2(0.2f, 0.85f), 180f, new Color(0.06f, 0.08f, 0.2f, 0.28f));

        foreach (var star in _stars)
        {
            var pulse = 0.75f + 0.25f * Mathf.Sin(_visualTime * star["speed"].AsSingle() + star["phase"].AsSingle());
            var c = (Color)star["color"];
            c.A *= pulse;
            DrawCircle((Vector2)star["pos"], star["size"].AsSingle(), c);
        }
    }

    private void DrawStation(Station station, int index)
    {
        var pulse = 0.84f + 0.16f * Mathf.Sin(_visualTime * 1.4f + index);
        var radius = 22f + 2.5f * Mathf.Sin(_visualTime + index);
        DrawCircle(station.Position, radius, StationColor * pulse);

        if (index % 2 == 0)
        {
            DrawArc(station.Position, radius + 8f, 0f, Mathf.Tau, 48, new Color(0.55f, 0.9f, 1f, 0.65f), 2.5f);
        }
        else
        {
            DrawArc(station.Position, radius + 9f, _visualTime * 0.2f, _visualTime * 0.2f + Mathf.Tau, 24, new Color(0.7f, 0.9f, 1f, 0.7f), 2.4f);
        }

        var focus = Resources.ContainsKey(_selectedResourceId) ? _selectedResourceId : DefaultResourceId;
        DrawString(ThemeDB.FallbackFont, station.Position + new Vector2(-64, -34), station.Name, fontSize: 14);
        DrawString(ThemeDB.FallbackFont, station.Position + new Vector2(-64, 46),
            $"Buy {GetStationBuyPrice(station, focus)} / Sell {GetStationSellPrice(station, focus)}", fontSize: 13);

        var dockPoint = GetDockPoint(station);
        DrawLine(station.Position, dockPoint, new Color(0.6f, 0.95f, 1f, 0.7f), 2f);
        DrawCircle(dockPoint, 5f, new Color(0.8f, 1f, 1f, 0.8f));
    }

    private void DrawNpcMarkers()
    {
        if (_stations.Count == 0) return;

        for (var i = 0; i < _npcs.Count; i++)
        {
            var anchor = _stations[i % _stations.Count];
            var markerPos = anchor.Position + new Vector2(28 + 9 * i, -24 - 5 * i);
            DrawCircle(markerPos, 4f, new Color(0.72f, 0.95f, 0.45f, 0.92f));
            DrawString(ThemeDB.FallbackFont, markerPos + new Vector2(8, 4), _npcs[i].Name, fontSize: 10);
        }
    }

    private void DrawShip()
    {
        var forward = Vector2.Right.Rotated(_playerRotation);
        var side = forward.Rotated(Mathf.Pi * 0.5f);
        var nose = _playerPosition + forward * 13f;
        var left = _playerPosition - forward * 8f + side * 8f;
        var right = _playerPosition - forward * 8f - side * 8f;
        var tail = _playerPosition - forward * 11f;

        DrawLine(nose, left, PlayerColor, 2f);
        DrawLine(left, tail, PlayerColor, 2f);
        DrawLine(tail, right, PlayerColor, 2f);
        DrawLine(right, nose, PlayerColor, 2f);
        DrawCircle(_playerPosition + forward * 1.5f, 3.4f, new Color(0.5f, 0.85f, 1f, 0.95f));
    }

    private void DrawOwnStation()
    {
        DrawCircle(_playerPosition, 14f, new Color(0.78f, 0.86f, 1f, 0.95f));
        DrawArc(_playerPosition, 22f, 0f, Mathf.Tau, 40, new Color(0.88f, 0.95f, 1f, 0.9f), 2.5f);
        DrawString(ThemeDB.FallbackFont, _playerPosition + new Vector2(16, 4), "HQ", fontSize: 12);
    }

    private void DrawTradeInterface(Station station)
    {
        var size = GetViewportRect().Size;
        var panelHeight = Math.Min(340f, size.Y - 120f);
        var panelTop = size.Y - panelHeight - 20f;

        var left = new Rect2(new Vector2(18, panelTop), new Vector2(size.X * 0.34f - 24f, panelHeight));
        var middle = new Rect2(new Vector2(left.End.X + 10, panelTop), new Vector2(size.X * 0.31f - 16f, panelHeight));
        var right = new Rect2(new Vector2(middle.End.X + 10, panelTop), new Vector2(size.X - (middle.End.X + 28), panelHeight));

        DrawPanel(left, "Spielerschiff");
        DrawPanel(middle, "Handel");
        DrawPanel(right, $"{station.Name} · {StationTypes[station.TypeId].DisplayName}");

        DrawPlayerPanel(left, station);
        DrawTradePanel(middle, station);
        DrawStationPanel(right, station);
    }

    private void DrawPanel(Rect2 rect, string title)
    {
        DrawRect(rect, PanelColor, true);
        DrawRect(rect, PanelBorder, false, 2f);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 24), title, fontSize: 16);
    }

    private void DrawPlayerPanel(Rect2 rect, Station station)
    {
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 48), $"Credits: {_credits}", fontSize: 14, modulate: CreditColor);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 68), $"Cargo: {GetUsedCapacity(_playerInventory)} / {_playerInventory.Capacity}", fontSize: 13);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 88), $"Inventarwert: {GetInventoryValue(_playerInventory, station, false)} cr", fontSize: 13);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 108), $"Suche: {(string.IsNullOrEmpty(_search) ? "(leer)" : _search)}", fontSize: 12);

        _sortRect = new Rect2(rect.Position + new Vector2(10, 114), new Vector2(rect.Size.X * 0.58f, 22));
        _dirRect = new Rect2(rect.Position + new Vector2(14 + rect.Size.X * 0.58f, 114), new Vector2(rect.Size.X * 0.34f - 20, 22));
        DrawRect(_sortRect, new Color(0.1f, 0.18f, 0.3f, 0.8f), true);
        DrawRect(_dirRect, new Color(0.1f, 0.18f, 0.3f, 0.8f), true);
        DrawString(ThemeDB.FallbackFont, _sortRect.Position + new Vector2(6, 15), $"Sort: {SortLabel(_sortKey)}", fontSize: 12);
        DrawString(ThemeDB.FallbackFont, _dirRect.Position + new Vector2(6, 15), $"Dir: {(_sortAscending ? "Auf" : "Ab")}", fontSize: 12);

        var rows = GetRows(_playerInventory, station, false);
        var startY = rect.Position.Y + 146;

        if (rows.Count == 0)
        {
            DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, startY + 26), "Leeres Inventar. Kaufe Waren an Stationen.", fontSize: 13);
            return;
        }

        for (var i = 0; i < Math.Min(rows.Count, 7); i++)
        {
            var rowRect = new Rect2(rect.Position + new Vector2(10, startY + i * 28), new Vector2(rect.Size.X - 20, 24));
            DrawRow(rows[i], rowRect, false, station);
        }
    }

    private void DrawStationPanel(Rect2 rect, Station station)
    {
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 48), $"Lager: {GetUsedCapacity(station.Inventory)} / {station.Inventory.Capacity}", fontSize: 13);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 68), "Ziel: ausgeglichener Warenmix", fontSize: 12);

        var rows = GetRows(station.Inventory, station, true);
        var startY = rect.Position.Y + 92;

        if (rows.Count == 0)
        {
            DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, startY + 22), "Stationlager ist aktuell leer.", fontSize: 13);
            return;
        }

        for (var i = 0; i < Math.Min(rows.Count, 8); i++)
        {
            var rowRect = new Rect2(rect.Position + new Vector2(10, startY + i * 28), new Vector2(rect.Size.X - 20, 24));
            DrawRow(rows[i], rowRect, true, station);
        }
    }

    private void DrawRow(UiRow row, Rect2 rect, bool stationRow, Station station)
    {
        var res = Resources[row.ResourceId];
        var selected = _selectedResourceId == row.ResourceId;

        DrawRect(rect, selected ? new Color(0.16f, 0.24f, 0.35f, 0.96f) : new Color(0.12f, 0.17f, 0.26f, 0.9f), true);
        DrawRect(rect, selected ? PanelBorder : new Color(0.2f, 0.35f, 0.55f, 0.7f), false, 1f);

        var iconRect = new Rect2(rect.Position + new Vector2(3, 2), new Vector2(20, 20));
        DrawRect(iconRect, new Color(0.06f, 0.08f, 0.13f), true);
        DrawRect(iconRect, TierBorderColor[res.Tier], false, 2f);
        DrawString(ThemeDB.FallbackFont, iconRect.Position + new Vector2(4, 15), res.Icon, fontSize: 12);

        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(28, 14), $"{res.DisplayName} T{res.Tier}", fontSize: 12);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(28, 23), $"Menge:{row.Amount} Wert:{row.TotalValue} Vol:{row.TotalVolume}", fontSize: 10);

        if (stationRow)
        {
            DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(rect.Size.X - 105, 14), GetStockState(station, row.ResourceId), fontSize: 10, modulate: new Color(0.65f, 0.94f, 1f));
        }

        _resourceHitRects[rect] = row.ResourceId;
    }

    private void DrawTradePanel(Rect2 rect, Station station)
    {
        var buy = GetStationBuyPrice(station, _selectedResourceId);
        var sell = GetStationSellPrice(station, _selectedResourceId);
        var totalBuy = buy * _quantity;
        var totalSell = sell * _quantity;
        var expected = ExpectedProfit(_selectedResourceId, _quantity, sell);

        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 48), $"Ressource: {Resources[_selectedResourceId].DisplayName}", fontSize: 14);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 70), $"Menge: {_quantity}", fontSize: 13);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 92), $"Kaufpreis: {buy}  Verkauf: {sell}", fontSize: 12);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 112), $"Gesamt Kauf/Verkauf: {totalBuy} / {totalSell}", fontSize: 12);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 132), $"Gewinn ggü. Ø Einkauf: {expected}", fontSize: 12, modulate: expected >= 0 ? GoodColor : BadColor);

        _plusOneRect = new Rect2(rect.Position + new Vector2(12, 154), new Vector2(46, 24));
        _plusFiveRect = new Rect2(rect.Position + new Vector2(64, 154), new Vector2(46, 24));
        _maxRect = new Rect2(rect.Position + new Vector2(116, 154), new Vector2(56, 24));
        _sellAllRect = new Rect2(rect.Position + new Vector2(178, 154), new Vector2(120, 24));

        DrawButton(_plusOneRect, "+1");
        DrawButton(_plusFiveRect, "+5");
        DrawButton(_maxRect, "Max");
        DrawButton(_sellAllRect, "Alles verkaufen");

        _buyRect = new Rect2(rect.Position + new Vector2(12, 188), new Vector2(rect.Size.X - 24, 34));
        _sellRect = new Rect2(rect.Position + new Vector2(12, 228), new Vector2(rect.Size.X - 24, 34));

        DrawRect(_buyRect, new Color(0.18f, 0.42f, 0.2f, 0.95f), true);
        DrawRect(_sellRect, new Color(0.17f, 0.28f, 0.48f, 0.95f), true);
        DrawString(ThemeDB.FallbackFont, _buyRect.Position + new Vector2(10, 22), "Kaufen", fontSize: 16);
        DrawString(ThemeDB.FallbackFont, _sellRect.Position + new Vector2(10, 22), "Verkaufen", fontSize: 16);

        var neededCargo = _quantity * Resources[_selectedResourceId].VolumePerUnit;
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 280), $"Credits: {_credits}", fontSize: 12, modulate: CreditColor);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 298), $"Cargo frei / benötigt: {GetAvailableCapacity(_playerInventory)} / {neededCargo}", fontSize: 12);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(12, 318), "Letzte Trades:", fontSize: 11);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(90, 318), RecentTrades(), fontSize: 11, modulate: new Color(0.72f, 0.88f, 1f));
    }

    private void DrawButton(Rect2 rect, string text)
    {
        DrawRect(rect, new Color(0.14f, 0.26f, 0.4f, 0.88f), true);
        DrawRect(rect, PanelBorder, false, 1f);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(7, 16), text, fontSize: 12);
    }

    private void DrawToast()
    {
        var size = GetViewportRect().Size;
        var rect = new Rect2(new Vector2(size.X * 0.5f - 120, 22), new Vector2(240, 30));
        DrawRect(rect, new Color(0.05f, 0.1f, 0.2f, 0.92f), true);
        DrawRect(rect, new Color(0.5f, 0.9f, 1f, 0.85f), false, 1f);
        DrawString(ThemeDB.FallbackFont, rect.Position + new Vector2(10, 20), _toastText, fontSize: 13);
    }

    private Vector2 GetDockPoint(Station station) => station.Position + new Vector2(34f, 0f);

    private List<UiRow> GetRows(Inventory inventory, Station reference, bool buyPrices)
    {
        var rows = new List<UiRow>();
        foreach (var resourceId in ResourceIds)
        {
            var amount = GetInventoryAmount(inventory, resourceId);
            if (amount <= 0) continue;

            var res = Resources[resourceId];
            if (!string.IsNullOrWhiteSpace(_search) && !res.DisplayName.Contains(_search, StringComparison.OrdinalIgnoreCase)) continue;

            var unit = buyPrices ? GetStationBuyPrice(reference, resourceId) : GetStationSellPrice(reference, resourceId);
            rows.Add(new UiRow
            {
                ResourceId = resourceId,
                Amount = amount,
                UnitPrice = unit,
                TotalValue = amount * unit,
                TotalVolume = amount * res.VolumePerUnit
            });
        }

        rows.Sort((a, b) => CompareRows(a, b) * (_sortAscending ? 1 : -1));
        return rows;
    }

    private int CompareRows(UiRow a, UiRow b)
    {
        return _sortKey switch
        {
            "name" => string.Compare(Resources[a.ResourceId].DisplayName, Resources[b.ResourceId].DisplayName, StringComparison.Ordinal),
            "tier" => Resources[a.ResourceId].Tier.CompareTo(Resources[b.ResourceId].Tier),
            "amount" => a.Amount.CompareTo(b.Amount),
            "unit_price" => a.UnitPrice.CompareTo(b.UnitPrice),
            _ => a.TotalValue.CompareTo(b.TotalValue)
        };
    }

    private int GetInventoryAmount(Inventory inventory, string resourceId)
        => inventory.Stacks.TryGetValue(resourceId, out var amount) ? amount : 0;

    private void SetInventoryAmount(Inventory inventory, string resourceId, int amount)
    {
        if (amount <= 0) inventory.Stacks.Remove(resourceId);
        else inventory.Stacks[resourceId] = amount;
    }

    private int AddToInventory(Inventory inventory, string resourceId, int requested)
    {
        if (requested <= 0) return 0;
        var volume = Resources[resourceId].VolumePerUnit;
        var maxAdd = GetAvailableCapacity(inventory) / volume;
        var add = Math.Min(requested, maxAdd);
        if (add <= 0) return 0;

        SetInventoryAmount(inventory, resourceId, GetInventoryAmount(inventory, resourceId) + add);
        return add;
    }

    private int RemoveFromInventory(Inventory inventory, string resourceId, int requested)
    {
        if (requested <= 0) return 0;
        var remove = Math.Min(requested, GetInventoryAmount(inventory, resourceId));
        SetInventoryAmount(inventory, resourceId, GetInventoryAmount(inventory, resourceId) - remove);
        return remove;
    }

    private int GetUsedCapacity(Inventory inventory)
    {
        var used = 0;
        foreach (var kv in inventory.Stacks)
        {
            used += kv.Value * Resources[kv.Key].VolumePerUnit;
        }
        return used;
    }

    private int GetAvailableCapacity(Inventory inventory) => Math.Max(0, inventory.Capacity - GetUsedCapacity(inventory));

    private void TrimInventoryToCapacity(Inventory inventory)
    {
        var over = GetUsedCapacity(inventory) - inventory.Capacity;
        if (over <= 0) return;

        foreach (var resourceId in ResourceIds)
        {
            if (over <= 0) break;
            var amount = GetInventoryAmount(inventory, resourceId);
            if (amount <= 0) continue;

            var volume = Resources[resourceId].VolumePerUnit;
            var removable = Math.Min(amount, (int)MathF.Ceiling(over / (float)volume));
            SetInventoryAmount(inventory, resourceId, amount - removable);
            over -= removable * volume;
        }
    }

    private int GetInventoryValue(Inventory inventory, Station station, bool buyPrices)
    {
        var total = 0;
        foreach (var resourceId in ResourceIds)
        {
            var amount = GetInventoryAmount(inventory, resourceId);
            if (amount <= 0) continue;
            total += amount * (buyPrices ? GetStationBuyPrice(station, resourceId) : GetStationSellPrice(station, resourceId));
        }
        return total;
    }

    private int MaxBuy(string resourceId, Station station)
    {
        var price = Math.Max(1, GetStationBuyPrice(station, resourceId));
        var affordable = _credits / price;
        var stock = GetInventoryAmount(station.Inventory, resourceId);
        var room = GetAvailableCapacity(_playerInventory) / Resources[resourceId].VolumePerUnit;
        return Math.Max(0, Math.Min(stock, Math.Min(affordable, room)));
    }

    private int ExpectedProfit(string resourceId, int amount, int sellPrice)
    {
        var avg = _avgBuyPrice.TryGetValue(resourceId, out var value) ? value : sellPrice;
        return (int)MathF.Round((sellPrice - avg) * amount);
    }

    private void UpdateAverageBuy(string resourceId, int amount, int unitPrice)
    {
        var newAmount = GetInventoryAmount(_playerInventory, resourceId);
        var oldAmount = newAmount - amount;
        if (newAmount <= 0)
        {
            _avgBuyPrice.Remove(resourceId);
            return;
        }
        var oldAvg = _avgBuyPrice.TryGetValue(resourceId, out var current) ? current : unitPrice;
        _avgBuyPrice[resourceId] = ((oldAvg * oldAmount) + amount * unitPrice) / newAmount;
    }

    private void AddTradeLog(string message)
    {
        _tradeLog.Add(message);
        while (_tradeLog.Count > MaxTradeLogEntries) _tradeLog.RemoveAt(0);
    }

    private string RecentTrades()
    {
        if (_tradeLog.Count == 0) return "Keine";
        var take = _tradeLog.Skip(Math.Max(0, _tradeLog.Count - 2)).Reverse();
        return string.Join(" | ", take);
    }

    private void SuccessTrade(string text)
    {
        _status = text;
        _toastText = text;
        _toastTimer = 2f;
        _lastTradeFailed = false;
    }

    private void FailTrade(string text)
    {
        _status = text;
        _toastText = text;
        _toastTimer = 2f;
        _lastTradeFailed = true;
    }

    private void UpdateHud()
    {
        var valuation = _dockingStation ?? _stations.FirstOrDefault();
        var shipValue = valuation is null ? 0 : GetInventoryValue(_playerInventory, valuation, false);
        _hudLabel.Text = $"Credits: {_credits}   Cargo: {GetUsedCapacity(_playerInventory)}/{_playerInventory.Capacity}   Stationen: {_stations.Count}   Schiffswert: {shipValue}   Ziel: 2000";

        var dockText = _isDocked && _dockingStation is not null
            ? $"Docked at {_dockingStation.Name}"
            : (_dockingStation is not null && Input.IsKeyPressed(Key.C) && _dockingProgress > 0f
                ? $"Docking {(int)Mathf.Round(100f * _dockingProgress / DockHoldTime)}%"
                : "Undocked");

        _statusLabel.Modulate = _lastTradeFailed ? BadColor : Color.Color8(255, 255, 255);

        _statusLabel.Text = $"{dockText} | {_status}";
    }

    private void BuildPlayerStation()
    {
        var station = CreateStation("player_hq", "Player Nexus", _playerPosition + new Vector2(90, -40), "trade_station", 5f, 0f);
        foreach (var resourceId in ResourceIds)
        {
            AddToInventory(station.Inventory, resourceId, 8);
        }
        _stations.Add(station);
    }

    private void CycleSort()
    {
        var index = Array.IndexOf(SortKeys, _sortKey);
        _sortKey = SortKeys[(index + 1) % SortKeys.Length];
    }

    private static string SortLabel(string sortKey) => sortKey switch
    {
        "name" => "Name",
        "tier" => "Tier",
        "amount" => "Menge",
        "value" => "Gesamtwert",
        "unit_price" => "Preis/Einheit",
        _ => sortKey
    };

    private void EnsureResourceSelected()
    {
        if (!Resources.ContainsKey(_selectedResourceId)) _selectedResourceId = DefaultResourceId;
    }

    private void GenerateStarfield()
    {
        _stars.Clear();
        var size = GetViewportRect().Size;
        for (var i = 0; i < StarfieldStarCount; i++)
        {
            _stars.Add(new Dictionary<string, Variant>
            {
                ["pos"] = new Vector2(_rng.RandfRange(0f, size.X), _rng.RandfRange(0f, size.Y)),
                ["size"] = _rng.RandfRange(0.7f, 2.2f),
                ["phase"] = _rng.RandfRange(0f, Mathf.Tau),
                ["speed"] = _rng.RandfRange(0.8f, 2.2f),
                ["color"] = new Color(
                    0.78f + _rng.RandfRange(0f, 0.2f),
                    0.78f + _rng.RandfRange(0f, 0.2f),
                    0.9f + _rng.RandfRange(0f, 0.1f),
                    0.45f + _rng.RandfRange(0f, 0.5f))
            });
        }
    }

    private void SaveState()
    {
        try
        {
            var save = new SaveData
            {
                Version = SaveVersion,
                Credits = _credits,
                PlayerPosition = new SaveVector2 { X = _playerPosition.X, Y = _playerPosition.Y },
                PlayerInventory = SaveInventoryFrom(_playerInventory),
                PlayerAvgBuy = _avgBuyPrice.ToDictionary(k => k.Key, v => v.Value),
                Stations = _stations.Select(st => new SaveStation
                {
                    Id = st.Id,
                    Name = st.Name,
                    TypeId = st.TypeId,
                    Position = new SaveVector2 { X = st.Position.X, Y = st.Position.Y },
                    Distance = st.Distance,
                    EventMod = st.EventMod,
                    TargetStock = st.TargetStock.ToDictionary(k => k.Key, v => v.Value),
                    Inventory = SaveInventoryFrom(st.Inventory)
                }).ToList(),
                TradeLog = _tradeLog.ToList(),
                GoalReached = _goalReached,
                HasOwnStation = _hasOwnStation,
                SelectedResource = _selectedResourceId,
                Quantity = _quantity,
                Search = _search,
                SortKey = _sortKey,
                SortAscending = _sortAscending
            };

            File.WriteAllText(ProjectSettings.GlobalizePath(SavePath), JsonSerializer.Serialize(save));
        }
        catch (Exception ex)
        {
            GD.PushWarning($"Save failed: {ex.Message}");
        }
    }

    private void LoadState()
    {
        try
        {
            var fullPath = ProjectSettings.GlobalizePath(SavePath);
            if (!File.Exists(fullPath)) return;

            var data = JsonSerializer.Deserialize<SaveData>(File.ReadAllText(fullPath));
            if (data is null) return;

            _credits = Math.Max(0, data.Credits);
            _playerPosition = new Vector2(data.PlayerPosition.X, data.PlayerPosition.Y);

            RestoreInventory(_playerInventory, data.PlayerInventory, CargoCapacity);

            _avgBuyPrice.Clear();
            foreach (var kv in data.PlayerAvgBuy) _avgBuyPrice[kv.Key] = kv.Value;

            if (data.Stations.Count > 0)
            {
                _stations.Clear();
                foreach (var st in data.Stations)
                {
                    var typeId = StationTypes.ContainsKey(st.TypeId) ? st.TypeId : "trade_station";
                    var station = CreateStation(st.Id, string.IsNullOrWhiteSpace(st.Name) ? st.Id : st.Name,
                        new Vector2(st.Position.X, st.Position.Y), typeId, st.Distance, st.EventMod);

                    if (st.TargetStock.Count > 0)
                    {
                        station.TargetStock.Clear();
                        foreach (var resourceId in ResourceIds)
                        {
                            station.TargetStock[resourceId] = st.TargetStock.TryGetValue(resourceId, out var target)
                                ? Math.Max(0, target)
                                : StationTypes[typeId].TargetStock[resourceId];
                        }
                    }

                    RestoreInventory(station.Inventory, st.Inventory, StationTypes[typeId].Capacity);
                    _stations.Add(station);
                }
            }

            _tradeLog.Clear();
            _tradeLog.AddRange(data.TradeLog.Take(MaxTradeLogEntries));
            _goalReached = data.GoalReached;
            _hasOwnStation = data.HasOwnStation;
            _selectedResourceId = string.IsNullOrWhiteSpace(data.SelectedResource) ? DefaultResourceId : data.SelectedResource;
            _quantity = Math.Max(1, data.Quantity);
            _search = data.Search ?? string.Empty;
            _sortKey = string.IsNullOrWhiteSpace(data.SortKey) ? "value" : data.SortKey;
            _sortAscending = data.SortAscending;

            EnsureResourceSelected();
        }
        catch (Exception ex)
        {
            GD.PushWarning($"Load failed, using defaults: {ex.Message}");
        }
    }

    private static SaveInventory SaveInventoryFrom(Inventory inventory)
        => new() { Capacity = inventory.Capacity, Stacks = inventory.Stacks.ToDictionary(k => k.Key, v => v.Value) };

    private static void RestoreInventory(Inventory target, SaveInventory source, int fallbackCapacity)
    {
        target.Stacks.Clear();
        target.Capacity = source.Capacity > 0 ? source.Capacity : fallbackCapacity;

        foreach (var resourceId in ResourceIds)
        {
            if (!source.Stacks.TryGetValue(resourceId, out var amount) || amount <= 0) continue;
            target.Stacks[resourceId] = amount;
        }
    }

    private static void ValidateResourceConfig()
    {
        foreach (var pair in Resources)
        {
            if (pair.Key == pair.Value.Id) continue;
            GD.PushWarning($"Resource key '{pair.Key}' does not match id '{pair.Value.Id}'.");
        }
    }
}

#nullable disable
