# Space Station Simulator

Single-player space-station management simulator with economic simulation, trade, and modular stations.

## Project Structure

- `/sim-core/` - .NET 8 simulation kernel (pure logic, no UI dependencies)
- `/sim-core.Tests/` - xUnit tests for pricing, pathing, AI, save/load
- `/client-godot/` - Godot 4 C# client (top-down views, UI)
- `/content/` - JSON data files (commodities, factions, systems, stations)
- `/.github/workflows/` - CI pipelines (build, test, web deploy)

## Features (Minimal Playable Demo)

- **4 trade stations** with continuously shifting supply and demand
- **Fixed station pricing** calculated through `sim-core` market logic
- **Mouse + keyboard trading gameplay loop** with clear win condition
- **Deterministic economy ticks** with seeded variation over time
- **Web export + GitHub Pages deployment** for in-browser play

## Controls

- **WASD** - Move your ship
- **Left Click (near station)** - Trade cargo at nearest station
- **Goal** - Reach **2000 credits** by buying low and selling high

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

## Play in Browser via GitHub Pages

1. In GitHub, go to **Settings → Pages** and set source to **GitHub Actions**.
   - You need repository admin permissions to change this setting.
2. Push to `main`.
3. Wait for **Deploy Godot Web** workflow to finish.
4. Open the published Pages URL for your repository.

## Troubleshooting

If the project doesn't start, verify in Godot Editor:
- **Project → Project Settings → Application → Run → Main Scene** = `res://Scenes/Main.tscn`

If Pages does not publish, verify repository permissions allow Actions to deploy Pages artifacts.

## Content Schema

Content files use simple JSON schemas:
- `commodities.json` - Trade goods with base prices and volatility
- `factions.json` - Political entities with tax rates and trade bias
- `systems.json` - Star systems with positions and hyperlane connections
- `stations/*.json` - Individual stations with markets, modules, energy

See `/content/` folder for examples.
