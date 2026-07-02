extends Node2D

const STATION_COLOR := Color(0.35, 0.75, 1.0)
const PLAYER_COLOR := Color(1.0, 0.86, 0.25)
const TIER_BORDER_COLORS := {
1: Color(0.95, 0.95, 0.98),
2: Color(0.35, 0.95, 0.45)
}
const NEUTRAL_PANEL := Color(0.07, 0.1, 0.17, 0.9)
const PANEL_BORDER := Color(0.35, 0.8, 1.0, 0.8)
const CREDIT_COLOR := Color(1.0, 0.86, 0.25)
const GOOD_COLOR := Color(0.35, 1.0, 0.55)
const BAD_COLOR := Color(1.0, 0.35, 0.35)

const BASE_MAX_SPEED := 250.0
const BOOST_MULTIPLIER := 1.75
const ACCELERATION := 520.0
const DRAG := 360.0
const DOCK_RANGE := 150.0
const DOCK_HOLD_TIME := 1.2
const BOUNDARY_PADDING := 24.0

const ECONOMY_TICK := 1.0
const NPC_TICK := 2.4
const SAVE_INTERVAL := 5.0
const SAVE_PATH := "user://savegame_v2.json"
const TRADE_LOG_LIMIT := 12
const RECENT_ACTION_LIMIT := 6

const BUY_MARGIN := 1.06
const SELL_MARGIN := 0.9

const SORT_KEYS := ["name", "tier", "amount", "value", "unit_price"]

const RESOURCE_CONFIG := {
"wood": {
"id": "wood",
"displayName": "Holz",
"tier": 1,
"category": "Rohstoff",
"icon": "▦",
"basePrice": 18.0,
"volumePerUnit": 1,
"description": "Leichtes Baumaterial für Grundversorgung."
},
"coal": {
"id": "coal",
"displayName": "Kohle",
"tier": 1,
"category": "Rohstoff",
"icon": "◼",
"basePrice": 21.0,
"volumePerUnit": 1,
"description": "Brennstoff und Industriegrundstoff."
},
"copper_plate": {
"id": "copper_plate",
"displayName": "Kupferplatte",
"tier": 2,
"category": "Verarbeitetes Material",
"icon": "▤",
"basePrice": 44.0,
"volumePerUnit": 2,
"description": "Leitfähiges Material für Module und Elektronik."
},
"plastic": {
"id": "plastic",
"displayName": "Plastik",
"tier": 2,
"category": "Verarbeitetes Material",
"icon": "⬡",
"basePrice": 40.0,
"volumePerUnit": 2,
"description": "Vielseitiger Verbundwerkstoff für Fertigung."
}
}

const RESOURCE_IDS := ["wood", "coal", "copper_plate", "plastic"]

const STATION_TYPE_CONFIG := {
"mining_outpost": {
"displayName": "Bergbau-Außenposten",
"capacity": 120,
"target": {"wood": 16, "coal": 50, "copper_plate": 14, "plastic": 10},
"production": {"coal": 4},
"consumption": {"plastic": 1, "copper_plate": 1}
},
"wood_processing": {
"displayName": "Holzverarbeitung",
"capacity": 115,
"target": {"wood": 48, "coal": 16, "copper_plate": 10, "plastic": 18},
"production": {"wood": 4},
"consumption": {"coal": 2, "plastic": 1}
},
"industry_hub": {
"displayName": "Industrie-Hub",
"capacity": 145,
"target": {"wood": 26, "coal": 28, "copper_plate": 30, "plastic": 30},
"production": {"copper_plate": 2, "plastic": 2},
"consumption": {"wood": 2, "coal": 2}
},
"trade_station": {
"displayName": "Handelsstation",
"capacity": 165,
"target": {"wood": 24, "coal": 24, "copper_plate": 22, "plastic": 22},
"production": {},
"consumption": {}
}
}

const HUMAN_FIRST := ["Nova", "Aurora", "Helios", "Kepler", "Atlas", "Vanguard", "Orion", "Argent", "Sol", "Pioneer"]
const HUMAN_LAST := ["Bastion", "Reach", "Harbor", "Ring", "Terminal", "Spire", "Yard", "Dock", "Station", "Port"]
const ALIEN_SYL_A := ["Xel", "Vra", "Qin", "Zho", "Taa", "Myr", "Kri", "Uul", "Ssa", "Nek"]
const ALIEN_SYL_B := ["'ra", "uun", "eth", "ix", "oq", "iri", "aal", "zen", "tor", "aak"]

var rng := RandomNumberGenerator.new()

var stations: Array = []
var npc_traders: Array = []
var player_inventory := {}
var player_avg_buy_price := {}

var player_position := Vector2(130, 120)
var player_velocity := Vector2.ZERO
var player_rotation := 0.0

var credits := 600
var is_docked := false
var docking_station = null
var docking_progress := 0.0
var was_dock_held := false
var has_own_station := false
var goal_reached_announced := false

var economy_accumulator := 0.0
var npc_accumulator := 0.0
var save_accumulator := 0.0
var visual_time := 0.0
var status := "Fly with WASD, hold C near station to dock, click controls to trade."

var trade_log: Array[String] = []
var toast_text := ""
var toast_time := 0.0

var sort_key := "value"
var sort_ascending := false
var search_query := ""
var quantity_value := 1
var selected_resource := "wood"
var selected_panel := "station"

var stars: Array[Dictionary] = []

var ui_buy_rect := Rect2()
var ui_sell_rect := Rect2()
var ui_plus1_rect := Rect2()
var ui_plus5_rect := Rect2()
var ui_max_rect := Rect2()
var ui_sell_all_rect := Rect2()
var ui_sort_rect := Rect2()
var ui_dir_rect := Rect2()
var ui_search_rect := Rect2()

var engine_player: AudioStreamPlayer
var boost_player: AudioStreamPlayer
var dock_start_player: AudioStreamPlayer
var dock_complete_player: AudioStreamPlayer

@onready var hud_label: Label = $CanvasLayer/HudLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
rng.set_seed(424242)
setup_default_state()
load_game_state()
generate_station_names_if_missing()
generate_starfield()
setup_audio()
update_hud()


func setup_default_state() -> void:
player_inventory = create_empty_inventory(32)
player_avg_buy_price = {}
stations = [
create_station("station_a", Vector2(260, 160), "mining_outpost", 4.0, 0.01),
create_station("station_b", Vector2(610, 220), "wood_processing", 10.0, 0.05),
create_station("station_c", Vector2(430, 460), "industry_hub", 7.0, -0.01),
create_station("station_d", Vector2(760, 420), "trade_station", 14.0, 0.08)
]
npc_traders = [
create_npc("Local Trader", 20, 0.65),
create_npc("Bulk Hauler", 28, 0.82),
create_npc("Opportunist", 18, 0.55)
]
for station in stations:
seed_station_inventory(station)


func _process(delta: float) -> void:
visual_time += delta
economy_accumulator += delta
npc_accumulator += delta
save_accumulator += delta

var boost_active := Input.is_key_pressed(KEY_SHIFT)
if is_docked:
player_velocity = Vector2.ZERO
if docking_station != null:
player_position = get_dock_point(docking_station)
player_rotation = (docking_station.position - player_position).angle()
if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
is_docked = false
status = "Undocked. Hold C near a station to dock again."
else:
handle_movement(delta, boost_active)
update_docking(delta)

if economy_accumulator >= ECONOMY_TICK:
economy_accumulator = 0.0
tick_economy()

if npc_accumulator >= NPC_TICK:
npc_accumulator = 0.0
run_npc_traders()

if save_accumulator >= SAVE_INTERVAL:
save_accumulator = 0.0
save_game_state()

if credits >= 2000 and not goal_reached_announced:
goal_reached_announced = true
status = "Goal reached! Keep trading or optimize station economies."

if credits >= 2600 and not has_own_station:
has_own_station = true
build_player_station()
status = "You founded a private station node."

if toast_time > 0.0:
toast_time -= delta
if toast_time <= 0.0:
toast_text = ""

update_hud()
queue_redraw()


func _exit_tree() -> void:
save_game_state()


func _unhandled_input(event: InputEvent) -> void:
if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
handle_left_click(event.position)
elif event is InputEventKey and event.pressed and not event.echo and is_docked:
handle_docked_key_input(event)


func _draw() -> void:
draw_space_background()
for i in range(stations.size()):
draw_station(stations[i], i)
draw_npc_markers()

if has_own_station:
draw_own_station_emblem()
else:
draw_ship(player_position, player_rotation)

if is_docked and docking_station != null:
draw_trade_interface()

if toast_text != "":
draw_toast()


func handle_left_click(pos: Vector2) -> void:
if is_docked and docking_station != null:
if ui_buy_rect.has_point(pos):
attempt_trade("buy")
return
if ui_sell_rect.has_point(pos):
attempt_trade("sell")
return
if ui_plus1_rect.has_point(pos):
quantity_value = min(quantity_value + 1, 999)
return
if ui_plus5_rect.has_point(pos):
quantity_value = min(quantity_value + 5, 999)
return
if ui_max_rect.has_point(pos):
quantity_value = get_max_buy_amount(selected_resource, docking_station)
quantity_value = max(1, quantity_value)
return
if ui_sell_all_rect.has_point(pos):
quantity_value = max(1, get_player_amount(selected_resource))
attempt_trade("sell")
return
if ui_sort_rect.has_point(pos):
cycle_sort_key()
return
if ui_dir_rect.has_point(pos):
sort_ascending = not sort_ascending
return
if ui_search_rect.has_point(pos):
selected_panel = "search"
return
if try_select_resource_card(pos):
return

try_trade_quick(pos)


func handle_docked_key_input(event: InputEventKey) -> void:
if event.keycode == KEY_TAB:
cycle_sort_key()
return
if event.keycode == KEY_R:
sort_ascending = not sort_ascending
return
if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:
quantity_value = min(quantity_value + 1, 999)
return
if event.keycode == KEY_MINUS:
quantity_value = max(1, quantity_value - 1)
return
if event.keycode == KEY_BACKSPACE:
if search_query.length() > 0:
search_query = search_query.substr(0, search_query.length() - 1)
return
if event.keycode == KEY_ESCAPE:
search_query = ""
return
var ch := char(event.unicode)
if ch != "" and ch.strip_edges() != "":
search_query += ch.to_lower()


func create_station(station_id: String, pos: Vector2, type_id: String, distance_factor: float, event_mod: float) -> Dictionary:
var type_cfg: Dictionary = STATION_TYPE_CONFIG[type_id]
return {
"id": station_id,
"name": station_id,
"position": pos,
"typeId": type_id,
"distance": distance_factor,
"eventMod": event_mod,
"inventory": create_empty_inventory(type_cfg.capacity),
"targetStock": type_cfg.target.duplicate(true)
}


func create_npc(name: String, capacity: int, efficiency: float) -> Dictionary:
return {
"name": name,
"inventory": create_empty_inventory(capacity),
"efficiency": efficiency
}


func create_empty_inventory(capacity: int) -> Dictionary:
return {
"capacity": capacity,
"stacks": {}
}


func seed_station_inventory(station: Dictionary) -> void:
for resource_id in RESOURCE_IDS:
var target := int(station.targetStock.get(resource_id, 0))
var seed := clampi(target + rng.randi_range(-6, 6), 2, target + 12)
add_to_inventory(station.inventory, resource_id, seed)


func generate_station_names_if_missing() -> void:
var used := {}
for station in stations:
var current_name := String(station.get("name", ""))
if current_name != "" and current_name != String(station.id) and not used.has(current_name):
used[current_name] = true
continue
var generated := ""
while generated == "" or used.has(generated):
generated = generate_random_station_name()
station.name = generated
used[generated] = true


func generate_random_station_name() -> String:
if rng.randf() < 0.5:
return "%s %s" % [HUMAN_FIRST[rng.randi_range(0, HUMAN_FIRST.size() - 1)], HUMAN_LAST[rng.randi_range(0, HUMAN_LAST.size() - 1)]]
return "%s%s Enclave" % [ALIEN_SYL_A[rng.randi_range(0, ALIEN_SYL_A.size() - 1)], ALIEN_SYL_B[rng.randi_range(0, ALIEN_SYL_B.size() - 1)]]


func handle_movement(delta: float, boost_active: bool) -> void:
var input_dir := Vector2.ZERO
if Input.is_action_pressed("move_left"):
input_dir.x -= 1.0
if Input.is_action_pressed("move_right"):
input_dir.x += 1.0
if Input.is_action_pressed("move_up"):
input_dir.y -= 1.0
if Input.is_action_pressed("move_down"):
input_dir.y += 1.0

if input_dir != Vector2.ZERO:
input_dir = input_dir.normalized()
player_velocity += input_dir * ACCELERATION * (BOOST_MULTIPLIER if boost_active else 1.0) * delta
else:
player_velocity = player_velocity.move_toward(Vector2.ZERO, DRAG * delta)

var max_speed := BASE_MAX_SPEED * (BOOST_MULTIPLIER if boost_active else 1.0)
if player_velocity.length() > max_speed:
player_velocity = player_velocity.normalized() * max_speed
if player_velocity.length() > 8.0:
player_rotation = lerp_angle(player_rotation, player_velocity.angle(), delta * 7.5)

var viewport_size := get_viewport_rect().size
player_position += player_velocity * delta
player_position = player_position.clamp(Vector2(BOUNDARY_PADDING, BOUNDARY_PADDING), viewport_size - Vector2(BOUNDARY_PADDING, BOUNDARY_PADDING))


func update_docking(delta: float) -> void:
var dock_pressed := Input.is_key_pressed(KEY_C)
var candidate = find_closest_station(DOCK_RANGE)
if candidate == null:
docking_progress = 0.0
docking_station = null
was_dock_held = dock_pressed
return

if not dock_pressed:
if docking_progress > 0.0:
status = "Hold C to dock with %s." % candidate.name
docking_progress = 0.0
docking_station = candidate
was_dock_held = false
return

if not was_dock_held and dock_start_player != null:
dock_start_player.play()
was_dock_held = true

if docking_station != candidate:
docking_station = candidate
docking_progress = 0.0

var dock_point := get_dock_point(candidate)
var pull_strength := clampf(delta * 3.6, 0.0, 1.0)
player_position = player_position.lerp(dock_point, pull_strength)
player_velocity = player_velocity.lerp(Vector2.ZERO, pull_strength)
player_rotation = lerp_angle(player_rotation, (candidate.position - player_position).angle(), delta * 8.0)

docking_progress = minf(DOCK_HOLD_TIME, docking_progress + delta)
status = "Docking at %s... %d%%" % [candidate.name, int(round(100.0 * docking_progress / DOCK_HOLD_TIME))]

if docking_progress >= DOCK_HOLD_TIME:
is_docked = true
docking_station = candidate
docking_progress = 0.0
if dock_complete_player != null:
dock_complete_player.play()

was_dock_held = dock_pressed


func find_closest_station(max_distance: float):
if stations.is_empty():
return null
var closest = stations[0]
var best_distance := player_position.distance_to(closest.position)
for i in range(1, stations.size()):
var station = stations[i]
var dist := player_position.distance_to(station.position)
if dist < best_distance:
best_distance = dist
closest = station
return closest if best_distance <= max_distance else null


func tick_economy() -> void:
for station in stations:
for resource_id in RESOURCE_IDS:
var amount := get_inventory_amount(station.inventory, resource_id)
var drift := rng.randi_range(-1, 1)
if station_has_production(station, resource_id):
drift += int(STATION_TYPE_CONFIG[station.typeId].production[resource_id])
if station_has_consumption(station, resource_id):
drift -= int(STATION_TYPE_CONFIG[station.typeId].consumption[resource_id])
amount = max(0, amount + drift)
set_inventory_amount(station.inventory, resource_id, amount)

station.eventMod = clampf(float(station.eventMod) + rng.randf_range(-0.006, 0.006), -0.2, 0.2)
trim_inventory_to_capacity(station.inventory)


func station_has_production(station: Dictionary, resource_id: String) -> bool:
var prod: Dictionary = STATION_TYPE_CONFIG[station.typeId].production
return prod.has(resource_id)


func station_has_consumption(station: Dictionary, resource_id: String) -> bool:
var cons: Dictionary = STATION_TYPE_CONFIG[station.typeId].consumption
return cons.has(resource_id)


func run_npc_traders() -> void:
if stations.size() < 2:
return
for npc in npc_traders:
if rng.randf() > float(npc.efficiency):
continue
var route := find_best_npc_route(npc)
if route.is_empty():
continue
execute_npc_trade(npc, route)


func find_best_npc_route(npc: Dictionary) -> Dictionary:
var best := {}
var best_profit := 0.0
for resource_id in RESOURCE_IDS:
for from_idx in range(stations.size()):
for to_idx in range(stations.size()):
if from_idx == to_idx:
continue
var from_station: Dictionary = stations[from_idx]
var to_station: Dictionary = stations[to_idx]
var buy_price := get_station_buy_price(from_station, resource_id)
var sell_price := get_station_sell_price(to_station, resource_id)
var unit_profit := sell_price - buy_price
if unit_profit < 2.0:
continue
var station_stock := get_inventory_amount(from_station.inventory, resource_id)
var target_room := get_available_capacity(to_station.inventory)
var npc_room := get_available_capacity(npc.inventory)
var max_amount := min(station_stock, min(target_room / get_resource_volume(resource_id), npc_room / get_resource_volume(resource_id)))
if max_amount <= 0:
continue
var conservative := maxi(1, int(round(max_amount * rng.randf_range(0.35, 0.8))))
var expected := unit_profit * conservative
if expected > best_profit:
best_profit = expected
best = {
"resource": resource_id,
"from": from_idx,
"to": to_idx,
"amount": conservative,
"unitProfit": unit_profit
}
return best


func execute_npc_trade(npc: Dictionary, route: Dictionary) -> void:
var resource_id := String(route.resource)
var amount := int(route.amount)
var from_station: Dictionary = stations[int(route.from)]
var to_station: Dictionary = stations[int(route.to)]
amount = min(amount, get_inventory_amount(from_station.inventory, resource_id))
amount = min(amount, get_available_capacity(to_station.inventory) / get_resource_volume(resource_id))
if amount <= 0:
return
remove_from_inventory(from_station.inventory, resource_id, amount)
add_to_inventory(to_station.inventory, resource_id, amount)
trim_inventory_to_capacity(from_station.inventory)
trim_inventory_to_capacity(to_station.inventory)
var log_line := "NPC %s moved %d %s: %s → %s" % [npc.name, amount, RESOURCE_CONFIG[resource_id].displayName, from_station.name, to_station.name]
append_trade_log(log_line)


func get_station_buy_price(station: Dictionary, resource_id: String) -> int:
var price := calculate_station_base_price(station, resource_id) * BUY_MARGIN
return int(ceil(price))


func get_station_sell_price(station: Dictionary, resource_id: String) -> int:
var price := calculate_station_base_price(station, resource_id) * SELL_MARGIN
return maxi(1, int(floor(price)))


func calculate_station_base_price(station: Dictionary, resource_id: String) -> float:
var res: Dictionary = RESOURCE_CONFIG[resource_id]
var base_price := float(res.basePrice)
var target := maxf(1.0, float(station.targetStock.get(resource_id, 1)))
var current := float(get_inventory_amount(station.inventory, resource_id))
var pressure := clampf((target - current) / target, -1.2, 1.2)
var tier_bonus := 1.0 + 0.1 * float(res.tier - 1)
var volatility := 1.0 + pressure * 0.45 + float(station.eventMod)
var distance_factor := 1.0 + float(station.distance) * 0.01
var raw := base_price * tier_bonus * distance_factor * volatility
var min_price := base_price * 0.45
var max_price := base_price * 2.6
return clampf(raw, min_price, max_price)


func get_stock_state(station: Dictionary, resource_id: String) -> String:
var target := max(1, int(station.targetStock.get(resource_id, 1)))
var current := get_inventory_amount(station.inventory, resource_id)
var ratio := float(current) / float(target)
if ratio < 0.45:
return "Sehr gefragt"
if ratio < 0.8:
return "Knapp"
if ratio > 1.5:
return "Überschuss"
return "Stabil"


func draw_space_background() -> void:
var viewport_size := get_viewport_rect().size
draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.02, 0.07), true)
draw_circle(viewport_size * 0.75, 220.0, Color(0.08, 0.05, 0.16, 0.38))
draw_circle(viewport_size * Vector2(0.2, 0.85), 180.0, Color(0.06, 0.08, 0.2, 0.28))
for star in stars:
var pulse := 0.75 + 0.25 * sin(visual_time * star["speed"] + star["phase"])
var color: Color = star["color"]
color.a *= pulse
draw_circle(star["pos"], star["size"], color)


func draw_station(station: Dictionary, index: int) -> void:
var pulse := 0.84 + 0.16 * sin(visual_time * 1.4 + float(index))
var core_color := STATION_COLOR * pulse
var radius := 22.0 + 2.5 * sin(visual_time + float(index))
draw_circle(station.position, radius, core_color)
if index % 2 == 0:
draw_arc(station.position, radius + 8.0, 0.0, TAU, 48, Color(0.55, 0.9, 1.0, 0.65), 2.5)
else:
var ring_points := PackedVector2Array()
for p in range(6):
var angle := TAU * float(p) / 6.0 + visual_time * 0.2
ring_points.append(station.position + Vector2.RIGHT.rotated(angle) * (radius + 9.0))
draw_polyline(ring_points, Color(0.7, 0.9, 1.0, 0.7), 2.4, true)

var dock_point := get_dock_point(station)
draw_line(station.position, dock_point, Color(0.6, 0.95, 1.0, 0.7), 2.0)
draw_circle(dock_point, 5.0, Color(0.8, 1.0, 1.0, 0.8))

var focus_resource := selected_resource if RESOURCE_CONFIG.has(selected_resource) else "wood"
var buy := get_station_buy_price(station, focus_resource)
var sell := get_station_sell_price(station, focus_resource)
draw_string(ThemeDB.fallback_font, station.position + Vector2(-64.0, -34.0), station.name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14)
draw_string(ThemeDB.fallback_font, station.position + Vector2(-64.0, 46.0), "Buy %d / Sell %d" % [buy, sell], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)


func draw_npc_markers() -> void:
for i in range(npc_traders.size()):
var npc = npc_traders[i]
var anchor_station: Dictionary = stations[i % stations.size()]
var marker_pos := anchor_station.position + Vector2(28 + 9 * i, -24 - 5 * i)
draw_circle(marker_pos, 4.0, Color(0.72, 0.95, 0.45, 0.92))
draw_string(ThemeDB.fallback_font, marker_pos + Vector2(8, 4), npc.name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10)


func draw_ship(ship_pos: Vector2, rotation: float) -> void:
var forward := Vector2.RIGHT.rotated(rotation)
var side := forward.rotated(PI * 0.5)
var nose := ship_pos + forward * 13.0
var left := ship_pos - forward * 8.0 + side * 8.0
var right := ship_pos - forward * 8.0 - side * 8.0
var tail := ship_pos - forward * 11.0
draw_colored_polygon(PackedVector2Array([nose, left, tail, right]), PLAYER_COLOR)
draw_circle(ship_pos + forward * 1.5, 3.4, Color(0.5, 0.85, 1.0, 0.95))
if Input.is_key_pressed(KEY_SHIFT):
draw_line(tail + side * 3.0, tail - forward * 8.0, Color(1.0, 0.5, 0.2, 0.9), 2.0)
draw_line(tail - side * 3.0, tail - forward * 8.0, Color(1.0, 0.5, 0.2, 0.9), 2.0)


func draw_own_station_emblem() -> void:
draw_circle(player_position, 14.0, Color(0.78, 0.86, 1.0, 0.95))
draw_arc(player_position, 22.0, 0.0, TAU, 40, Color(0.88, 0.95, 1.0, 0.9), 2.5)
draw_string(ThemeDB.fallback_font, player_position + Vector2(16, 4), "HQ", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)


func draw_trade_interface() -> void:
var size := get_viewport_rect().size
var panel_height := minf(340.0, size.y - 120.0)
var panel_top := size.y - panel_height - 20.0
var left_rect := Rect2(Vector2(18, panel_top), Vector2(size.x * 0.34 - 24.0, panel_height))
var mid_rect := Rect2(Vector2(left_rect.end.x + 10, panel_top), Vector2(size.x * 0.31 - 16.0, panel_height))
var right_rect := Rect2(Vector2(mid_rect.end.x + 10, panel_top), Vector2(size.x - (mid_rect.end.x + 28), panel_height))

draw_panel(left_rect, "Spielerschiff")
draw_panel(mid_rect, "Handel")
draw_panel(right_rect, "%s · %s" % [docking_station.name, STATION_TYPE_CONFIG[docking_station.typeId].displayName])

draw_player_inventory_panel(left_rect)
draw_trade_controls(mid_rect)
draw_station_inventory_panel(right_rect)


func draw_panel(rect: Rect2, title: String) -> void:
draw_rect(rect, NEUTRAL_PANEL, true)
draw_rect(rect, PANEL_BORDER, false, 2.0)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 24), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16)


func draw_player_inventory_panel(rect: Rect2) -> void:
var cargo_used := get_used_capacity(player_inventory)
var cargo_cap := int(player_inventory.capacity)
var inv_value := get_inventory_value(player_inventory, docking_station, false)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 48), "Credits: %d" % credits, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, CREDIT_COLOR)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 68), "Cargo: %d / %d" % [cargo_used, cargo_cap], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 88), "Inventarwert: %d cr" % inv_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 108), "Suche: %s" % (search_query if search_query != "" else "(leer)"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

ui_search_rect = Rect2(rect.position + Vector2(10, 95), Vector2(rect.size.x - 20, 20))
ui_sort_rect = Rect2(rect.position + Vector2(10, 114), Vector2(rect.size.x * 0.58, 22))
ui_dir_rect = Rect2(rect.position + Vector2(14 + rect.size.x * 0.58, 114), Vector2(rect.size.x * 0.34 - 20, 22))
draw_rect(ui_sort_rect, Color(0.1, 0.18, 0.3, 0.8), true)
draw_rect(ui_dir_rect, Color(0.1, 0.18, 0.3, 0.8), true)
draw_string(ThemeDB.fallback_font, ui_sort_rect.position + Vector2(6, 15), "Sort: %s" % sort_label(sort_key), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
draw_string(ThemeDB.fallback_font, ui_dir_rect.position + Vector2(6, 15), "Dir: %s" % ("Auf" if sort_ascending else "Ab"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

var entries := get_inventory_rows(player_inventory, docking_station, false)
var start_y := rect.position.y + 146
if entries.is_empty():
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, start_y + 26), "Leeres Inventar. Kaufe Waren an Stationen.", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(0.75, 0.82, 0.93))
return
for i in range(min(entries.size(), 7)):
draw_resource_row(entries[i], Rect2(rect.position + Vector2(10, start_y + i * 28), Vector2(rect.size.x - 20, 24)), "player")


func draw_station_inventory_panel(rect: Rect2) -> void:
var inv := docking_station.inventory
var used := get_used_capacity(inv)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 48), "Lager: %d / %d" % [used, int(inv.capacity)], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 68), "Ziel: ausgeglichener Warenmix", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

var entries := get_inventory_rows(inv, docking_station, true)
var start_y := rect.position.y + 92
if entries.is_empty():
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, start_y + 22), "Stationlager ist aktuell leer.", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(0.76, 0.83, 0.93))
return
for i in range(min(entries.size(), 8)):
draw_resource_row(entries[i], Rect2(rect.position + Vector2(10, start_y + i * 28), Vector2(rect.size.x - 20, 24)), "station")


func draw_resource_row(entry: Dictionary, rect: Rect2, panel_name: String) -> void:
var resource_id := String(entry.resourceId)
var res: Dictionary = RESOURCE_CONFIG[resource_id]
var is_selected := selected_resource == resource_id and selected_panel == panel_name
var bg := Color(0.12, 0.17, 0.26, 0.9) if not is_selected else Color(0.16, 0.24, 0.35, 0.96)
draw_rect(rect, bg, true)
draw_rect(rect, PANEL_BORDER if is_selected else Color(0.2, 0.35, 0.55, 0.7), false, 1.0)

var icon_rect := Rect2(rect.position + Vector2(3, 2), Vector2(20, 20))
draw_rect(icon_rect, Color(0.06, 0.08, 0.13), true)
draw_rect(icon_rect, TIER_BORDER_COLORS[int(res.tier)], false, 2.0)
draw_string(ThemeDB.fallback_font, icon_rect.position + Vector2(4, 15), String(res.icon), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

draw_string(ThemeDB.fallback_font, rect.position + Vector2(28, 14), "%s T%d" % [res.displayName, int(res.tier)], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(28, 23), "Menge:%d  Wert:%d  Vol:%d" % [int(entry.amount), int(entry.totalValue), int(entry.totalVolume)], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10)
if panel_name == "station":
draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 110, 14), get_stock_state(docking_station, resource_id), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(0.65, 0.94, 1.0))


func draw_trade_controls(rect: Rect2) -> void:
var buy_price := get_station_buy_price(docking_station, selected_resource)
var sell_price := get_station_sell_price(docking_station, selected_resource)
var total_buy := buy_price * quantity_value
var total_sell := sell_price * quantity_value
var expected := get_expected_profit_delta(selected_resource, quantity_value, sell_price)

draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 48), "Ressource: %s" % RESOURCE_CONFIG[selected_resource].displayName, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 70), "Menge: %d" % quantity_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 92), "Kaufpreis: %d  Verkauf: %d" % [buy_price, sell_price], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 112), "Gesamt Kauf/Verkauf: %d / %d" % [total_buy, total_sell], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 132), "Gewinn ggü. Ø Einkauf: %d" % expected, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, GOOD_COLOR if expected >= 0 else BAD_COLOR)

ui_plus1_rect = Rect2(rect.position + Vector2(12, 154), Vector2(46, 24))
ui_plus5_rect = Rect2(rect.position + Vector2(64, 154), Vector2(46, 24))
ui_max_rect = Rect2(rect.position + Vector2(116, 154), Vector2(56, 24))
ui_sell_all_rect = Rect2(rect.position + Vector2(178, 154), Vector2(120, 24))
for button in [[ui_plus1_rect, "+1"], [ui_plus5_rect, "+5"], [ui_max_rect, "Max"], [ui_sell_all_rect, "Alles verkaufen"]]:
draw_rect(button[0], Color(0.14, 0.26, 0.4, 0.88), true)
draw_rect(button[0], PANEL_BORDER, false, 1.0)
draw_string(ThemeDB.fallback_font, button[0].position + Vector2(7, 16), button[1], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

ui_buy_rect = Rect2(rect.position + Vector2(12, 188), Vector2(rect.size.x - 24, 34))
ui_sell_rect = Rect2(rect.position + Vector2(12, 228), Vector2(rect.size.x - 24, 34))
draw_rect(ui_buy_rect, Color(0.18, 0.42, 0.2, 0.95), true)
draw_rect(ui_sell_rect, Color(0.17, 0.28, 0.48, 0.95), true)
draw_string(ThemeDB.fallback_font, ui_buy_rect.position + Vector2(10, 22), "Kaufen", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16)
draw_string(ThemeDB.fallback_font, ui_sell_rect.position + Vector2(10, 22), "Verkaufen", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16)

var free_cargo := get_available_capacity(player_inventory)
var need_cargo := quantity_value * get_resource_volume(selected_resource)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 280), "Credits: %d" % credits, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, CREDIT_COLOR)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 298), "Cargo frei / benötigt: %d / %d" % [free_cargo, need_cargo], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
var actions := get_recent_trades()
draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 318), "Letzte Trades:", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(90, 318), actions, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color(0.72, 0.88, 1.0))


func try_select_resource_card(pos: Vector2) -> bool:
var size := get_viewport_rect().size
var panel_height := minf(340.0, size.y - 120.0)
var panel_top := size.y - panel_height - 20.0
var left_rect := Rect2(Vector2(18, panel_top), Vector2(size.x * 0.34 - 24.0, panel_height))
var right_rect := Rect2(Vector2(left_rect.end.x + 10 + size.x * 0.31 - 16.0 + 10, panel_top), Vector2(size.x - (left_rect.end.x + 10 + size.x * 0.31 - 16.0 + 28), panel_height))

var player_entries := get_inventory_rows(player_inventory, docking_station, false)
for i in range(min(player_entries.size(), 7)):
var row_rect := Rect2(left_rect.position + Vector2(10, 146 + i * 28), Vector2(left_rect.size.x - 20, 24))
if row_rect.has_point(pos):
selected_resource = player_entries[i].resourceId
selected_panel = "player"
return true

var station_entries := get_inventory_rows(docking_station.inventory, docking_station, true)
for j in range(min(station_entries.size(), 8)):
var s_rect := Rect2(right_rect.position + Vector2(10, 92 + j * 28), Vector2(right_rect.size.x - 20, 24))
if s_rect.has_point(pos):
selected_resource = station_entries[j].resourceId
selected_panel = "station"
return true
return false


func attempt_trade(mode: String) -> void:
var amount := max(1, quantity_value)
var result := validate_trade(mode, selected_resource, amount)
if not result.ok:
status = result.message
show_toast(result.message, BAD_COLOR)
return

if mode == "buy":
var unit_buy := get_station_buy_price(docking_station, selected_resource)
var total_cost := unit_buy * amount
credits -= total_cost
remove_from_inventory(docking_station.inventory, selected_resource, amount)
add_to_inventory(player_inventory, selected_resource, amount)
update_avg_buy_price(selected_resource, amount, unit_buy)
append_trade_log("Gekauft: %d %s @ %d von %s" % [amount, RESOURCE_CONFIG[selected_resource].displayName, unit_buy, docking_station.name])
status = "Kauf erfolgreich: %d %s" % [amount, RESOURCE_CONFIG[selected_resource].displayName]
show_toast("Kauf erfolgreich", GOOD_COLOR)
else:
var unit_sell := get_station_sell_price(docking_station, selected_resource)
var total_gain := unit_sell * amount
credits += total_gain
remove_from_inventory(player_inventory, selected_resource, amount)
add_to_inventory(docking_station.inventory, selected_resource, amount)
append_trade_log("Verkauft: %d %s @ %d an %s" % [amount, RESOURCE_CONFIG[selected_resource].displayName, unit_sell, docking_station.name])
status = "Verkauf erfolgreich: %d %s" % [amount, RESOURCE_CONFIG[selected_resource].displayName]
show_toast("Verkauf erfolgreich", GOOD_COLOR)

credits = max(0, credits)
trim_inventory_to_capacity(player_inventory)
trim_inventory_to_capacity(docking_station.inventory)


func validate_trade(mode: String, resource_id: String, amount: int) -> Dictionary:
if amount <= 0:
return {"ok": false, "message": "Ungültige Menge."}
if not RESOURCE_CONFIG.has(resource_id):
return {"ok": false, "message": "Unbekannte Ressource."}

if mode == "buy":
var unit_price := get_station_buy_price(docking_station, resource_id)
var total := unit_price * amount
if credits < total:
return {"ok": false, "message": "Nicht genug Credits."}
if get_inventory_amount(docking_station.inventory, resource_id) < amount:
return {"ok": false, "message": "Station hat zu wenig Bestand."}
if get_available_capacity(player_inventory) < amount * get_resource_volume(resource_id):
return {"ok": false, "message": "Nicht genug Frachtraum."}
return {"ok": true, "message": "ok"}

if mode == "sell":
if get_inventory_amount(player_inventory, resource_id) < amount:
return {"ok": false, "message": "Ressource nicht im Inventar."}
if get_available_capacity(docking_station.inventory) < amount * get_resource_volume(resource_id):
return {"ok": false, "message": "Stationslager ist voll."}
return {"ok": true, "message": "ok"}

return {"ok": false, "message": "Ungültige Handelsaktion."}


func try_trade_quick(_pos: Vector2) -> void:
if not is_docked or docking_station == null:
status = "Trade ist nur im Dock möglich."


func cycle_sort_key() -> void:
var idx := SORT_KEYS.find(sort_key)
idx = (idx + 1) % SORT_KEYS.size()
sort_key = SORT_KEYS[idx]


func sort_label(key: String) -> String:
match key:
"name":
return "Name"
"tier":
return "Tier"
"amount":
return "Menge"
"value":
return "Gesamtwert"
"unit_price":
return "Preis/Einheit"
_:
return key


func get_inventory_rows(inventory: Dictionary, reference_station: Dictionary, use_station_prices: bool) -> Array:
var rows := []
for resource_id in RESOURCE_IDS:
var amount := get_inventory_amount(inventory, resource_id)
if amount <= 0:
continue
var res: Dictionary = RESOURCE_CONFIG[resource_id]
var unit_price := get_station_sell_price(reference_station, resource_id)
if use_station_prices:
unit_price = get_station_buy_price(reference_station, resource_id)
var total_value := unit_price * amount
var total_volume := amount * int(res.volumePerUnit)
var row := {
"resourceId": resource_id,
"amount": amount,
"tier": int(res.tier),
"name": String(res.displayName),
"unitPrice": unit_price,
"totalValue": total_value,
"totalVolume": total_volume
}
if search_query != "" and not String(res.displayName).to_lower().contains(search_query):
continue
rows.append(row)

rows.sort_custom(func(a, b):
var result := false
match sort_key:
"name":
result = String(a.name) < String(b.name)
"tier":
result = int(a.tier) < int(b.tier)
"amount":
result = int(a.amount) < int(b.amount)
"unit_price":
result = int(a.unitPrice) < int(b.unitPrice)
_:
result = int(a.totalValue) < int(b.totalValue)
return result if sort_ascending else not result
)
return rows


func get_expected_profit_delta(resource_id: String, amount: int, sell_price: int) -> int:
var avg := float(player_avg_buy_price.get(resource_id, float(sell_price)))
return int(round((float(sell_price) - avg) * amount))


func update_avg_buy_price(resource_id: String, amount: int, unit_price: int) -> void:
var existing_amount := get_inventory_amount(player_inventory, resource_id) - amount
var previous_avg := float(player_avg_buy_price.get(resource_id, float(unit_price)))
var total_cost := previous_avg * existing_amount + float(unit_price * amount)
var new_amount := get_inventory_amount(player_inventory, resource_id)
if new_amount <= 0:
player_avg_buy_price.erase(resource_id)
return
player_avg_buy_price[resource_id] = total_cost / float(new_amount)


func get_max_buy_amount(resource_id: String, station: Dictionary) -> int:
var unit_price := get_station_buy_price(station, resource_id)
var affordable := credits / maxi(1, unit_price)
var stock := get_inventory_amount(station.inventory, resource_id)
var room := get_available_capacity(player_inventory) / get_resource_volume(resource_id)
return maxi(0, mini(stock, mini(affordable, room)))


func get_resource_volume(resource_id: String) -> int:
return int(RESOURCE_CONFIG[resource_id].volumePerUnit)


func get_inventory_amount(inventory: Dictionary, resource_id: String) -> int:
return int(inventory.stacks.get(resource_id, 0))


func set_inventory_amount(inventory: Dictionary, resource_id: String, amount: int) -> void:
if amount <= 0:
inventory.stacks.erase(resource_id)
return
inventory.stacks[resource_id] = amount


func add_to_inventory(inventory: Dictionary, resource_id: String, amount: int) -> int:
if amount <= 0:
return 0
var free_volume := get_available_capacity(inventory)
var volume_per_unit := get_resource_volume(resource_id)
var max_add := free_volume / maxi(1, volume_per_unit)
var to_add := mini(amount, max_add)
if to_add <= 0:
return 0
set_inventory_amount(inventory, resource_id, get_inventory_amount(inventory, resource_id) + to_add)
return to_add


func remove_from_inventory(inventory: Dictionary, resource_id: String, amount: int) -> int:
if amount <= 0:
return 0
var current := get_inventory_amount(inventory, resource_id)
var to_remove := mini(current, amount)
set_inventory_amount(inventory, resource_id, current - to_remove)
return to_remove


func get_used_capacity(inventory: Dictionary) -> int:
var used := 0
for resource_id in inventory.stacks.keys():
used += int(inventory.stacks[resource_id]) * get_resource_volume(String(resource_id))
return used


func get_available_capacity(inventory: Dictionary) -> int:
return maxi(0, int(inventory.capacity) - get_used_capacity(inventory))


func trim_inventory_to_capacity(inventory: Dictionary) -> void:
var over := get_used_capacity(inventory) - int(inventory.capacity)
if over <= 0:
return
for resource_id in RESOURCE_IDS:
if over <= 0:
break
var current := get_inventory_amount(inventory, resource_id)
if current <= 0:
continue
var volume := get_resource_volume(resource_id)
var removable := mini(current, int(ceil(float(over) / float(volume))))
set_inventory_amount(inventory, resource_id, current - removable)
over -= removable * volume


func get_player_amount(resource_id: String) -> int:
return get_inventory_amount(player_inventory, resource_id)


func get_inventory_value(inventory: Dictionary, station: Dictionary, use_buy: bool) -> int:
var total := 0
for resource_id in RESOURCE_IDS:
var amount := get_inventory_amount(inventory, resource_id)
if amount <= 0:
continue
var unit_price := get_station_buy_price(station, resource_id) if use_buy else get_station_sell_price(station, resource_id)
total += unit_price * amount
return total


func get_recent_trades() -> String:
if trade_log.is_empty():
return "Keine"
var count := min(2, trade_log.size())
var lines := []
for i in range(count):
lines.append(trade_log[trade_log.size() - 1 - i])
return " | ".join(lines)


func append_trade_log(text: String) -> void:
trade_log.append(text)
while trade_log.size() > TRADE_LOG_LIMIT:
trade_log.remove_at(0)


func show_toast(text: String, color: Color) -> void:
toast_text = text
toast_time = 2.0
status_label.modulate = color


func draw_toast() -> void:
var size := get_viewport_rect().size
var rect := Rect2(Vector2(size.x * 0.5 - 120, 22), Vector2(240, 30))
draw_rect(rect, Color(0.05, 0.1, 0.2, 0.92), true)
draw_rect(rect, Color(0.5, 0.9, 1.0, 0.85), false, 1.0)
draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 20), toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)


func update_hud() -> void:
var cargo_used := get_used_capacity(player_inventory)
var cargo_cap := int(player_inventory.capacity)
var known_stations := stations.size()
var ship_value := get_inventory_value(player_inventory, docking_station if docking_station != null else stations[0], false)
var dock_text := "Docked at %s" % docking_station.name if is_docked and docking_station != null else "Undocked"
if docking_station != null and not is_docked and docking_progress > 0.0 and Input.is_key_pressed(KEY_C):
dock_text = "Docking %d%%" % int(round(100.0 * docking_progress / DOCK_HOLD_TIME))

hud_label.text = "Credits: %d   Cargo: %d/%d   Stationen: %d   Schiffswert: %d   Ziel: 2000   %s" % [credits, cargo_used, cargo_cap, known_stations, ship_value, dock_text]
status_label.modulate = Color(1, 1, 1, 1)
status_label.text = status


func build_player_station() -> void:
var station := create_station("player_hq", player_position + Vector2(90, -40), "trade_station", 5.0, 0.0)
station.name = "Player Nexus"
seed_station_inventory(station)
stations.append(station)


func get_dock_point(station: Dictionary) -> Vector2:
return station.position + Vector2(34.0, 0.0)


func generate_starfield() -> void:
stars.clear()
var viewport_size := get_viewport_rect().size
for _i in range(95):
stars.append({
"pos": Vector2(rng.randf_range(0.0, viewport_size.x), rng.randf_range(0.0, viewport_size.y)),
"size": rng.randf_range(0.7, 2.2),
"phase": rng.randf_range(0.0, TAU),
"speed": rng.randf_range(0.8, 2.2),
"color": Color(0.78 + rng.randf_range(0.0, 0.2), 0.78 + rng.randf_range(0.0, 0.2), 0.9 + rng.randf_range(0.0, 0.1), 0.45 + rng.randf_range(0.0, 0.5))
})


func setup_audio() -> void:
engine_player = AudioStreamPlayer.new()
engine_player.stream = create_tone_stream(0.10, 170.0, 210.0, 0.22)
engine_player.volume_db = -8.0
add_child(engine_player)

boost_player = AudioStreamPlayer.new()
boost_player.stream = create_tone_stream(0.16, 210.0, 420.0, 0.35)
boost_player.volume_db = -7.0
add_child(boost_player)

dock_start_player = AudioStreamPlayer.new()
dock_start_player.stream = create_tone_stream(0.20, 500.0, 280.0, 0.30)
dock_start_player.volume_db = -6.0
add_child(dock_start_player)

dock_complete_player = AudioStreamPlayer.new()
dock_complete_player.stream = create_tone_stream(0.35, 260.0, 640.0, 0.35)
dock_complete_player.volume_db = -5.0
add_child(dock_complete_player)


func create_tone_stream(duration: float, freq_start: float, freq_end: float, amplitude: float) -> AudioStreamWAV:
var sample_rate := 44100
var sample_count := maxi(2, int(duration * sample_rate))
var data := PackedByteArray()
data.resize(sample_count * 2)
var phase := 0.0
for i in range(sample_count):
var t := float(i) / float(maxi(1, sample_count - 1))
var freq := lerpf(freq_start, freq_end, t)
phase += TAU * freq / float(sample_rate)
var envelope := pow(1.0 - t, 1.4)
var sample_value := sin(phase) * amplitude * envelope
data.encode_s16(i * 2, int(clampf(sample_value * 32767.0, -32767.0, 32767.0)))
var stream := AudioStreamWAV.new()
stream.format = AudioStreamWAV.FORMAT_16_BITS
stream.mix_rate = sample_rate
stream.stereo = false
stream.data = data
return stream


func save_game_state() -> void:
var save_data := {
"version": 2,
"credits": credits,
"playerPosition": {"x": player_position.x, "y": player_position.y},
"playerInventory": inventory_to_save_dict(player_inventory),
"playerAvgBuy": player_avg_buy_price,
"stations": [],
"tradeLog": trade_log,
"hasOwnStation": has_own_station,
"goalReached": goal_reached_announced,
"selectedResource": selected_resource,
"quantity": quantity_value
}
for station in stations:
save_data.stations.append({
"id": station.id,
"name": station.name,
"position": {"x": station.position.x, "y": station.position.y},
"typeId": station.typeId,
"distance": station.distance,
"eventMod": station.eventMod,
"targetStock": station.targetStock,
"inventory": inventory_to_save_dict(station.inventory)
})
var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
if file == null:
return
file.store_string(JSON.stringify(save_data))


func inventory_to_save_dict(inventory: Dictionary) -> Dictionary:
return {
"capacity": int(inventory.capacity),
"stacks": inventory.stacks.duplicate(true)
}


func load_game_state() -> void:
if not FileAccess.file_exists(SAVE_PATH):
return
var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
if file == null:
return
var parsed = JSON.parse_string(file.get_as_text())
if typeof(parsed) != TYPE_DICTIONARY:
return
var data: Dictionary = parsed
credits = max(0, int(data.get("credits", credits)))
if data.has("playerPosition"):
var pos: Dictionary = data.playerPosition
player_position = Vector2(float(pos.get("x", player_position.x)), float(pos.get("y", player_position.y)))
if data.has("playerInventory"):
player_inventory = inventory_from_save_dict(data.playerInventory, int(player_inventory.capacity))
if data.has("playerAvgBuy") and typeof(data.playerAvgBuy) == TYPE_DICTIONARY:
player_avg_buy_price = data.playerAvgBuy.duplicate(true)
if data.has("stations") and typeof(data.stations) == TYPE_ARRAY:
stations.clear()
for saved_station in data.stations:
if typeof(saved_station) != TYPE_DICTIONARY:
continue
var station_dict: Dictionary = saved_station
var type_id := String(station_dict.get("typeId", "trade_station"))
if not STATION_TYPE_CONFIG.has(type_id):
type_id = "trade_station"
var station := create_station(
String(station_dict.get("id", "station_%d" % stations.size())),
Vector2(float(station_dict.get("position", {}).get("x", 320.0)), float(station_dict.get("position", {}).get("y", 220.0))),
type_id,
float(station_dict.get("distance", 6.0)),
float(station_dict.get("eventMod", 0.0))
)
station.name = String(station_dict.get("name", station.name))
if station_dict.has("targetStock") and typeof(station_dict.targetStock) == TYPE_DICTIONARY:
station.targetStock = station_dict.targetStock.duplicate(true)
if station_dict.has("inventory"):
station.inventory = inventory_from_save_dict(station_dict.inventory, int(station.inventory.capacity))
stations.append(station)
if stations.is_empty():
setup_default_state()
if data.has("tradeLog") and typeof(data.tradeLog) == TYPE_ARRAY:
trade_log.clear()
for item in data.tradeLog:
trade_log.append(String(item))
if data.has("hasOwnStation"):
has_own_station = bool(data.hasOwnStation)
if data.has("goalReached"):
goal_reached_announced = bool(data.goalReached)
selected_resource = String(data.get("selectedResource", selected_resource))
if not RESOURCE_CONFIG.has(selected_resource):
selected_resource = "wood"
quantity_value = max(1, int(data.get("quantity", quantity_value)))


func inventory_from_save_dict(data: Dictionary, fallback_capacity: int) -> Dictionary:
var inv := create_empty_inventory(int(data.get("capacity", fallback_capacity)))
if data.has("stacks") and typeof(data.stacks) == TYPE_DICTIONARY:
for resource_id in data.stacks.keys():
var id := String(resource_id)
if RESOURCE_CONFIG.has(id):
set_inventory_amount(inv, id, max(0, int(data.stacks[resource_id])))
trim_inventory_to_capacity(inv)
return inv
