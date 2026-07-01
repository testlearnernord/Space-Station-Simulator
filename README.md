# Space Station Simulator

Single-player space-station management simulator with economic simulation, trade, and modular stations.

## Project Structure

- `/sim-core/` - .NET 8 simulation kernel (pure logic, no UI dependencies)
- `/sim-core.Tests/` - xUnit tests for pricing, pathing, AI, save/load
- `/client-godot/` - Godot 4 C# client (top-down views, UI)
- `/content/` - JSON data files (commodities, factions, systems, stations)
- `/.github/workflows/` - CI pipelines (build, test, export)

## Features (Minimal Viable Demo)

- **3 Factions**, **6 Systems**, **12 Stations**, **24 Commodities**
- **Fixed 10Hz simulation** with deterministic RNG seeds
- **Market system** with supply/demand pricing and distance modifiers
- **Greedy trade AI** for 8 autonomous ships
- **Energy management** with production/consumption and throttling
- **Save/Load** with gzip compression and version stamps
- **Galaxy map** with pan/zoom, clickable stations
- **Event system** (demand shocks, blockades, escorts)

## Controls

- **WASD** - Pan galaxy view
- **Mouse Wheel** - Zoom in/out
- **Click** - Select stations/systems

## Build Instructions

```bash
# Build simulation core
cd sim-core
dotnet build

# Run tests
cd ../sim-core.Tests
dotnet test
```

## Run Locally

1. Install **Godot 4.x .NET** (version 4.3 or higher)
2. Open `client-godot/project.godot` in Godot Editor
3. Press **F5** to run

### Troubleshooting

If the project doesn't start, verify in Godot Editor:
- **Project → Project Settings → Application → Run → Main Scene** = `res://Scenes/Main.tscn`

## Content Schema

Content files use simple JSON schemas:
- `commodities.json` - Trade goods with base prices and volatility
- `factions.json` - Political entities with tax rates and trade bias
- `systems.json` - Star systems with positions and hyperlane connections
- `stations/*.json` - Individual stations with markets, modules, energy

See `/content/` folder for examples.