# Copilot Instructions – Space Station Simulator

## Project Structure

- `client-godot/` – Godot 4.3 game client (GDScript, no C#)
- `sim-core/` – .NET 8 core simulation library (C#)
- `sim-core.Tests/` – .NET 8 unit tests (C#)

## GDScript Rules (critical – prevents grey screen on web export)

The game runs in the browser via Godot Web export. Any GDScript parse error causes a **grey/blank screen** for the player. CI enforces this with `godot --headless --check-only --quit`.

### ❌ Never use `:=` (type inference) with Dictionary values

```gdscript
# WRONG – causes "Cannot infer the type" parse error in Godot 4.3
var price := station["price"]
var vol := res["volume_per_unit"]
```

### ✅ Always use explicit type annotations with Dictionary values

```gdscript
# CORRECT – always declare the type explicitly
var price: float = float(station["price"])
var vol: int = int(res["volume_per_unit"])
var name: String = str(station["display_name"])
```

### Rule summary
- Dictionary lookups (`dict["key"]`) always return `Variant` in GDScript 4 – the type can never be inferred automatically.
- Always write `var x: SomeType = SomeType(dict["key"])` when reading from a Dictionary.
- This applies to all Dictionaries: `RESOURCES`, `STATION_TYPES`, `player_inventory`, `station`, `row`, etc.

## Web Export Constraints

- The Godot client uses **pure GDScript only** (no C#/Mono). Godot 4 does not support C# on the Web export target.
- Do not add C# scripts to `client-godot/`.

## CI Validation

Before opening a pull request, ensure these checks pass locally:

```bash
# Validate GDScript syntax (prevents grey screen)
cd client-godot
godot --headless --check-only --quit

# Run .NET unit tests
dotnet test sim-core.Tests/sim-core.Tests.csproj
```

Both checks run automatically on every PR via GitHub Actions (`.github/workflows/ci.yml`).
