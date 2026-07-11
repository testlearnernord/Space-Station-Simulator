extends Node2D

# ─── Constants ────────────────────────────────────────────────────────────────

const SAVE_VERSION := 2
const SAVE_PATH := "user://savegame.json"
const DEFAULT_RESOURCE_ID := "wood"
const CARGO_CAPACITY := 32

const ACCELERATION := 520.0
const DRAG := 360.0
const BASE_MAX_SPEED := 250.0
const BOOST_MULTIPLIER := 1.75
const DOCK_RANGE := 150.0
const DOCK_HOLD_TIME := 1.2

const ECONOMY_TICK := 1.0
const NPC_TICK := 2.4
const SAVE_TICK := 5.0
const MAX_TRADE_LOG := 12
const STARFIELD_COUNT := 95
const NPC_VISUAL_SPEED := 180.0
const NPC_VISUAL_MIN_TRAVEL := 1.3
const NPC_VISUAL_MAX_TRAVEL := 4.2
const NPC_IDLE_RADIUS := 4.0
const NPC_ANCHOR_BASE_ANGLE := 0.95
const NPC_ANCHOR_ANGLE_STEP := 1.63
const NPC_IDLE_SPEED := 0.9
const NPC_IDLE_SWAY_RATIO := 1.17
const SEED_VARIANCE_MIN := -6
const SEED_VARIANCE_MAX := 6
const MIN_INITIAL_STOCK := 2
const MAX_INITIAL_STOCK_BONUS := 12
const NPC_MIN_TRADE_RATIO := 0.35
const NPC_MAX_TRADE_RATIO := 0.8
const BUY_MARKUP := 1.06
const SELL_MARKDOWN := 0.9
const PRESSURE_CLAMP_MIN := -1.2
const PRESSURE_CLAMP_MAX := 1.2
const PRESSURE_PRICE_FACTOR := 0.45
const DISTANCE_PRICE_FACTOR := 0.01
const MIN_PRICE_MULTIPLIER := 0.45
const MAX_PRICE_MULTIPLIER := 2.6
const VERY_HIGH_DEMAND_RATIO := 0.45
const LOW_STOCK_RATIO := 0.8
const OVERSTOCK_RATIO := 1.5

const STATION_COLOR := Color(0.35, 0.75, 1.0)
const PLAYER_COLOR := Color(1.0, 0.86, 0.25)
const PANEL_COLOR := Color(0.07, 0.1, 0.17, 0.92)
const PANEL_BORDER := Color(0.35, 0.8, 1.0, 0.8)
const GOOD_COLOR := Color(0.35, 1.0, 0.55)
const BAD_COLOR := Color(1.0, 0.35, 0.35)
const CREDIT_COLOR := Color(1.0, 0.86, 0.25)

const TIER_BORDER_COLOR := {
	1: Color(0.95, 0.95, 0.98),
	2: Color(0.35, 0.95, 0.45)
}

const DEFAULT_RNG_SEED := 424242
const NPC_MARKER_COLOR := Color(0.72, 0.95, 0.45, 0.92)
const ROW_SELECTED_BG := Color(0.16, 0.24, 0.35, 0.96)
const ROW_DEFAULT_BG := Color(0.12, 0.17, 0.26, 0.9)
const ROW_HOVER_BG := Color(0.17, 0.24, 0.34, 0.95)
const ROW_PRESS_BG := Color(0.22, 0.3, 0.42, 0.98)
const ROW_DEFAULT_BORDER := Color(0.2, 0.35, 0.55, 0.7)
const ICON_BG_COLOR := Color(0.06, 0.08, 0.13)
const CONTROL_BG_COLOR := Color(0.1, 0.18, 0.3, 0.8)
const STOCK_STATE_COLOR := Color(0.65, 0.94, 1.0)
const STOCK_STATE_OFFSET := 105.0
const TRADE_LOG_COLOR := Color(0.72, 0.88, 1.0)
const BUY_BUTTON_COLOR := Color(0.18, 0.42, 0.2, 0.95)
const SELL_BUTTON_COLOR := Color(0.17, 0.28, 0.48, 0.95)
const UI_BUTTON_BG := Color(0.14, 0.26, 0.4, 0.88)
const UI_BUTTON_HOVER_BG := Color(0.18, 0.32, 0.5, 0.94)
const UI_BUTTON_PRESS_BG := Color(0.23, 0.39, 0.6, 0.98)
const TOAST_BG_COLOR := Color(0.05, 0.1, 0.2, 0.92)
const TOAST_BORDER_COLOR := Color(0.5, 0.9, 1.0, 0.85)
const INTERACT_FEEDBACK_TIME := 0.14

# Resource definitions: id -> {id, display_name, tier, category, icon, base_price, volume_per_unit, description}
const RESOURCES := {
	"wood": {
		"id": "wood", "display_name": "Holz", "tier": 1, "category": "Rohstoff",
		"icon": "▦", "base_price": 18.0, "volume_per_unit": 1, "description": "Leichtes Baumaterial."
	},
	"coal": {
		"id": "coal", "display_name": "Kohle", "tier": 1, "category": "Rohstoff",
		"icon": "◼", "base_price": 21.0, "volume_per_unit": 1, "description": "Brennstoff und Industriegrundstoff."
	},
	"copper_plate": {
		"id": "copper_plate", "display_name": "Kupferplatte", "tier": 2, "category": "Verarbeitetes Material",
		"icon": "▤", "base_price": 44.0, "volume_per_unit": 2, "description": "Leitfähiges Material."
	},
	"plastic": {
		"id": "plastic", "display_name": "Plastik", "tier": 2, "category": "Verarbeitetes Material",
		"icon": "⬡", "base_price": 40.0, "volume_per_unit": 2, "description": "Vielseitiger Verbundwerkstoff."
	}
}

const RESOURCE_IDS := ["wood", "coal", "copper_plate", "plastic"]
const SORT_KEYS := ["name", "tier", "amount", "value", "unit_price"]

# Station type definitions: capacity, target_stock, production, consumption
const STATION_TYPES := {
	"mining_outpost": {
		"id": "mining_outpost", "display_name": "Bergbau-Außenposten", "capacity": 120,
		"target_stock": {"wood": 16, "coal": 50, "copper_plate": 14, "plastic": 10},
		"production": {"coal": 4}, "consumption": {"plastic": 1, "copper_plate": 1}
	},
	"wood_processing": {
		"id": "wood_processing", "display_name": "Holzverarbeitung", "capacity": 115,
		"target_stock": {"wood": 48, "coal": 16, "copper_plate": 10, "plastic": 18},
		"production": {"wood": 4}, "consumption": {"coal": 2, "plastic": 1}
	},
	"industry_hub": {
		"id": "industry_hub", "display_name": "Industrie-Hub", "capacity": 145,
		"target_stock": {"wood": 26, "coal": 28, "copper_plate": 30, "plastic": 30},
		"production": {"copper_plate": 2, "plastic": 2}, "consumption": {"wood": 2, "coal": 2}
	},
	"trade_station": {
		"id": "trade_station", "display_name": "Handelsstation", "capacity": 165,
		"target_stock": {"wood": 24, "coal": 24, "copper_plate": 22, "plastic": 22},
		"production": {}, "consumption": {}
	}
}

# ─── State ────────────────────────────────────────────────────────────────────

var rng := RandomNumberGenerator.new()
var stations: Array = []
var npcs: Array = []
# Unified agent dict for the player — same structure as NPC agents.
# Keys: "credits" (int), "inventory" (Dictionary with "capacity" and "stacks")
var player_agent: Dictionary = {"credits": 600, "inventory": {"capacity": CARGO_CAPACITY, "stacks": {}}}
var avg_buy_price: Dictionary = {}
var trade_log: Array = []
var stars: Array = []

var player_position := Vector2(130, 120)
var player_velocity := Vector2.ZERO
var player_rotation := 0.0
var is_docked := false
var docking_station = null
var docking_progress := 0.0
var was_dock_held := false
var goal_reached := false
var has_own_station := false

var economy_accumulator := 0.0
var npc_accumulator := 0.0
var save_accumulator := 0.0
var visual_time := 0.0

var status := "Fly with WASD, hold C near station to dock."
var sort_key := "value"
var sort_ascending := false
var search := ""
var selected_resource_id := DEFAULT_RESOURCE_ID
var quantity := 1

var toast_text := ""
var toast_timer := 0.0
var last_trade_failed := false

var buy_rect := Rect2()
var sell_rect := Rect2()
var plus_one_rect := Rect2()
var plus_five_rect := Rect2()
var max_rect := Rect2()
var sell_all_rect := Rect2()
var sort_rect := Rect2()
var dir_rect := Rect2()
var control_hit_rects: Array = []
var mouse_position := Vector2.ZERO
var hovered_control_id := ""
var feedback_control_id := ""
var feedback_timer := 0.0

var engine_player: AudioStreamPlayer
var boost_player: AudioStreamPlayer
var dock_start_player: AudioStreamPlayer
var dock_complete_player: AudioStreamPlayer
var ui_hover_player: AudioStreamPlayer
var ui_click_player: AudioStreamPlayer
var trade_success_player: AudioStreamPlayer
var trade_fail_player: AudioStreamPlayer
var audio_prime_player: AudioStreamPlayer
var audio_primed := false
var engine_sound_cooldown := 0.0

@onready var hud_label: Label = $CanvasLayer/HudLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel

# ─── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	rng.seed = DEFAULT_RNG_SEED
	setup_defaults()
	load_state()
	generate_starfield()
	setup_audio()
	ensure_resource_selected()
	update_hud()


func _exit_tree() -> void:
	save_state()


func _process(delta: float) -> void:
	visual_time += delta
	engine_sound_cooldown = maxf(0.0, engine_sound_cooldown - delta)

	if is_docked:
		player_velocity = Vector2.ZERO
		if docking_station != null:
			player_position = get_dock_point(docking_station)
			player_rotation = (docking_station["position"] - player_position).angle()
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or \
				Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
			is_docked = false
			status = "Undocked. Hold C near a station to dock again."
	else:
		handle_movement(delta)
		update_docking(delta)

	economy_accumulator += delta
	npc_accumulator += delta
	save_accumulator += delta

	if economy_accumulator >= ECONOMY_TICK:
		economy_accumulator = 0.0
		tick_economy()

	if npc_accumulator >= NPC_TICK:
		npc_accumulator = 0.0
		run_npc_trades()

	update_npc_visuals(delta)

	if save_accumulator >= SAVE_TICK:
		save_accumulator = 0.0
		save_state()

	if int(player_agent["credits"]) >= 2000 and not goal_reached:
		goal_reached = true
		status = "Goal reached! Keep optimizing your trade routes."

	if int(player_agent["credits"]) >= 2600 and not has_own_station:
		has_own_station = true
		build_player_station()
		status = "You founded a private station node."

	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_text = ""

	if feedback_timer > 0.0:
		feedback_timer -= delta
		if feedback_timer <= 0.0:
			feedback_control_id = ""

	update_hud()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position
		update_hovered_control(true)
		return

	if event is InputEventMouseButton:
		mouse_position = event.position

	if event is InputEventMouseButton and event.pressed:
		prime_audio()

	if event is InputEventKey and event.pressed and not event.echo:
		prime_audio()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_left_click(event.position)
		return

	if not is_docked:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.keycode == KEY_TAB:
		cycle_sort()
	elif event.keycode == KEY_R:
		sort_ascending = not sort_ascending
	elif event.keycode == KEY_KP_ADD or event.keycode == KEY_EQUAL:
		quantity = mini(999, quantity + 1)
	elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
		quantity = maxi(1, quantity - 1)
	elif event.keycode == KEY_BACKSPACE:
		if search.length() > 0:
			search = search.substr(0, search.length() - 1)
	elif event.keycode == KEY_ESCAPE:
		search = ""
	elif event.unicode > 31 and event.unicode < 127:
		search += char(event.unicode).to_lower()


func _draw() -> void:
	draw_background()
	for i in range(stations.size()):
		draw_station_node(stations[i], i)
	draw_npc_markers()

	if has_own_station:
		draw_own_station()
	else:
		draw_ship()

	control_hit_rects.clear()
	if is_docked and docking_station != null:
		draw_trade_interface(docking_station)

	if not toast_text.is_empty():
		draw_toast()

# ─── Setup ────────────────────────────────────────────────────────────────────

func setup_defaults() -> void:
	stations.clear()
	npcs.clear()
	player_agent = {"credits": 600, "inventory": {"capacity": CARGO_CAPACITY, "stacks": {}}}
	avg_buy_price.clear()

	stations.append(create_station("station_a", "Atlas Hub", Vector2(260, 160), "mining_outpost", 4.0, 0.01))
	stations.append(create_station("station_b", "Kepler Dock", Vector2(610, 220), "wood_processing", 10.0, 0.05))
	stations.append(create_station("station_c", "Helios Yard", Vector2(430, 460), "industry_hub", 7.0, -0.01))
	stations.append(create_station("station_d", "Nova Ring", Vector2(760, 420), "trade_station", 14.0, 0.08))

	for station in stations:
		for resource_id in RESOURCE_IDS:
			var target: int = station["target_stock"][resource_id]
			var initial := clampi(target + rng.randi_range(SEED_VARIANCE_MIN, SEED_VARIANCE_MAX), MIN_INITIAL_STOCK, target + MAX_INITIAL_STOCK_BONUS)
			add_to_inventory(station["inventory"], resource_id, initial)

	npcs.append(create_npc("Local Trader", 20, 0.65, 0))
	npcs.append(create_npc("Bulk Hauler", 28, 0.82, 1))
	npcs.append(create_npc("Opportunist", 18, 0.55, 2))
	sync_npc_visuals()


func create_station(id: String, sname: String, position: Vector2, type_id: String, distance: float, event_mod: float) -> Dictionary:
	var stype: Dictionary = STATION_TYPES[type_id]
	var target_stock := {}
	for k in stype["target_stock"]:
		target_stock[k] = stype["target_stock"][k]
	return {
		"id": id,
		"name": sname,
		"type_id": type_id,
		"position": position,
		"distance": distance,
		"event_mod": event_mod,
		"inventory": {"capacity": stype["capacity"], "stacks": {}},
		"target_stock": target_stock
	}


func create_npc(npc_name: String, cargo_capacity: int, efficiency: float, station_index: int) -> Dictionary:
	var anchor_station: Dictionary = stations[station_index % stations.size()]
	var anchor_station_id: String = str(anchor_station["id"])
	return {
		"name": npc_name,
		"cargo_capacity": cargo_capacity,
		"efficiency": efficiency,
		"home_station_id": anchor_station_id,
		"anchor_station_id": anchor_station_id,
		"route_from_id": "",
		"route_to_id": "",
		"travel_progress": 1.0,
		"travel_time": NPC_VISUAL_MIN_TRAVEL,
		"visual_position": get_station_npc_anchor(anchor_station, station_index),
		"visual_rotation": 0.0,
		"idle_phase": rng.randf_range(0.0, TAU),
		"cargo_resource_id": "",
		# Agent fields — same model as the player
		"inventory": {"capacity": cargo_capacity, "stacks": {}},
		"credits": 400,
		"state": "idle",
		"cargo_amount": 0,
		"destination_station_id": ""
	}

# ─── Movement ─────────────────────────────────────────────────────────────────

func handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"): input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"): input_dir.x += 1.0
	if Input.is_action_pressed("move_up"): input_dir.y -= 1.0
	if Input.is_action_pressed("move_down"): input_dir.y += 1.0

	var boost_active := Input.is_key_pressed(KEY_SHIFT)

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		var boost := BOOST_MULTIPLIER if boost_active else 1.0
		player_velocity += input_dir * ACCELERATION * boost * delta
		if engine_sound_cooldown <= 0.0 and not engine_player.playing:
			engine_player.play()
			engine_sound_cooldown = 0.14
	else:
		player_velocity = player_velocity.move_toward(Vector2.ZERO, DRAG * delta)

	if boost_active and input_dir != Vector2.ZERO and not boost_player.playing:
		boost_player.play()

	var max_speed := BASE_MAX_SPEED * (BOOST_MULTIPLIER if boost_active else 1.0)
	if player_velocity.length() > max_speed:
		player_velocity = player_velocity.normalized() * max_speed

	if player_velocity.length() > 8.0:
		player_rotation = lerp_angle(player_rotation, player_velocity.angle(), delta * 7.5)

	var viewport_size := get_viewport_rect().size
	player_position += player_velocity * delta
	player_position = player_position.clamp(Vector2(24.0, 24.0), viewport_size - Vector2(24.0, 24.0))

# ─── Docking ──────────────────────────────────────────────────────────────────

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
			status = "Hold C to dock with %s." % candidate["name"]
		docking_station = candidate
		docking_progress = 0.0
		was_dock_held = false
		return

	if not was_dock_held:
		dock_start_player.play()
		was_dock_held = true

	if docking_station != candidate:
		docking_station = candidate
		docking_progress = 0.0

	var pull := clampf(delta * 3.6, 0.0, 1.0)
	player_position = player_position.lerp(get_dock_point(candidate), pull)
	player_velocity = player_velocity.lerp(Vector2.ZERO, pull)
	player_rotation = lerp_angle(player_rotation, (candidate["position"] - player_position).angle(), delta * 8.0)

	docking_progress = minf(DOCK_HOLD_TIME, docking_progress + delta)
	status = "Docking at %s... %d%%" % [candidate["name"], int(round(100.0 * docking_progress / DOCK_HOLD_TIME))]

	if docking_progress >= DOCK_HOLD_TIME:
		is_docked = true
		docking_station = candidate
		docking_progress = 0.0
		dock_complete_player.play()

	was_dock_held = dock_pressed


func find_closest_station(max_distance: float):
	var closest = null
	var best := INF
	for station in stations:
		var dist: float = player_position.distance_to(station["position"])
		if dist < best:
			best = dist
			closest = station
	return closest if best <= max_distance else null


func get_dock_point(station: Dictionary) -> Vector2:
	return station["position"] + Vector2(34.0, 0.0)


func get_station_by_id(station_id: String) -> Dictionary:
	for station in stations:
		var station_id_str: String = str(station["id"])
		if station_id_str == station_id:
			return station
	return {}


func get_station_npc_anchor(station: Dictionary, npc_index: int) -> Vector2:
	var angle: float = NPC_ANCHOR_BASE_ANGLE + float(npc_index) * NPC_ANCHOR_ANGLE_STEP
	var radius: float = 24.0 + float(npc_index % 2) * 8.0
	var station_position: Vector2 = Vector2(station["position"])
	return station_position + Vector2(cos(angle), sin(angle)) * radius


func sync_npc_visuals() -> void:
	for npc_index in range(npcs.size()):
		var npc: Dictionary = npcs[npc_index]
		var anchor_station_id: String = str(npc.get("anchor_station_id", npc.get("home_station_id", "")))
		var anchor_station: Dictionary = get_station_by_id(anchor_station_id)
		if anchor_station.is_empty() and not stations.is_empty():
			anchor_station = stations[npc_index % stations.size()]
			var fallback_id: String = str(anchor_station["id"])
			npc["anchor_station_id"] = fallback_id
			if not npc.has("home_station_id") or str(npc.get("home_station_id", "")).is_empty():
				npc["home_station_id"] = fallback_id
		if anchor_station.is_empty():
			continue
		npc["route_from_id"] = ""
		npc["route_to_id"] = ""
		npc["travel_progress"] = 1.0
		npc["cargo_resource_id"] = ""
		npc["visual_position"] = get_station_npc_anchor(anchor_station, npc_index)
		npc["visual_rotation"] = 0.0


func start_npc_visual_route(npc: Dictionary, npc_index: int, from: Dictionary, to: Dictionary, resource_id: String) -> void:
	# Use the NPC's current visual position as the start so it never teleports.
	var cur_pos: Vector2 = Vector2(npc.get("visual_position", get_station_npc_anchor(from, npc_index)))
	var end_pos: Vector2 = get_station_npc_anchor(to, npc_index)
	var distance: float = cur_pos.distance_to(end_pos)
	var from_id: String = str(from["id"])
	var to_id: String = str(to["id"])
	npc["anchor_station_id"] = to_id
	npc["route_from_id"] = from_id
	npc["route_to_id"] = to_id
	npc["travel_progress"] = 0.0
	npc["travel_time"] = clampf(distance / NPC_VISUAL_SPEED, NPC_VISUAL_MIN_TRAVEL, NPC_VISUAL_MAX_TRAVEL)
	npc["route_start_pos"] = cur_pos
	npc["visual_rotation"] = (end_pos - cur_pos).angle()
	npc["cargo_resource_id"] = resource_id


func update_npc_visuals(delta: float) -> void:
	for npc_index in range(npcs.size()):
		var npc: Dictionary = npcs[npc_index]
		var route_from_id: String = str(npc.get("route_from_id", ""))
		var route_to_id: String = str(npc.get("route_to_id", ""))
		var travel_progress: float = float(npc.get("travel_progress", 1.0))

		if not route_from_id.is_empty() and not route_to_id.is_empty() and travel_progress < 1.0:
			var from_station: Dictionary = get_station_by_id(route_from_id)
			var to_station: Dictionary = get_station_by_id(route_to_id)
			if from_station.is_empty() or to_station.is_empty():
				npc["route_from_id"] = ""
				npc["route_to_id"] = ""
				npc["travel_progress"] = 1.0
				npc["cargo_resource_id"] = ""
				continue

			var travel_time: float = maxf(0.001, float(npc.get("travel_time", NPC_VISUAL_MIN_TRAVEL)))
			travel_progress = minf(1.0, travel_progress + delta / travel_time)
			var eased: float = travel_progress * travel_progress * (3.0 - 2.0 * travel_progress)
			# Use the stored route_start_pos so the NPC travels from where it
			# actually was when the route began, avoiding visual teleportation.
			var start_pos: Vector2 = Vector2(npc.get("route_start_pos", get_station_npc_anchor(from_station, npc_index)))
			var end_pos: Vector2 = get_station_npc_anchor(to_station, npc_index)
			npc["visual_position"] = start_pos.lerp(end_pos, eased)
			npc["visual_rotation"] = (end_pos - start_pos).angle()
			npc["travel_progress"] = travel_progress

			if travel_progress >= 1.0:
				# Phase 3 – NPC sells its cargo on arrival
				var npc_state: String = str(npc.get("state", "idle"))
				var cr_id: String = str(npc.get("cargo_resource_id", ""))
				var c_amount: int = int(npc.get("cargo_amount", 0))
				if npc_state == "traveling_to_sell" and c_amount > 0 and not cr_id.is_empty() and RESOURCES.has(cr_id):
					var dest_id: String = str(npc.get("destination_station_id", npc.get("anchor_station_id", "")))
					var dest: Dictionary = get_station_by_id(dest_id)
					var npc_inv: Dictionary = npc.get("inventory", {})
					if not dest.is_empty() and not npc_inv.is_empty():
						var sell_price: int = get_station_sell_price(dest, cr_id)
						var ok: bool = agent_sell_to_station(npc, npc_inv, dest, cr_id, c_amount)
						if ok:
							var res: Dictionary = RESOURCES[cr_id]
							add_trade_log("NPC %s: Verkauft %d %s @ %d bei %s (Kontostand: %d cr)" % [
								str(npc.get("name", "NPC")), c_amount, str(res["display_name"]),
								sell_price, str(dest["name"]), int(npc.get("credits", 0))])
				npc["state"] = "idle"
				npc["cargo_amount"] = 0
				npc["destination_station_id"] = ""
				npc["route_from_id"] = ""
				npc["route_to_id"] = ""
				npc["cargo_resource_id"] = ""
			continue

		var anchor_station_id: String = str(npc.get("anchor_station_id", npc.get("home_station_id", "")))
		var anchor_station: Dictionary = get_station_by_id(anchor_station_id)
		if anchor_station.is_empty() and not stations.is_empty():
			anchor_station = stations[npc_index % stations.size()]
			npc["anchor_station_id"] = str(anchor_station["id"])
		if anchor_station.is_empty():
			continue
		var anchor_pos: Vector2 = get_station_npc_anchor(anchor_station, npc_index)
		var idle_phase: float = float(npc.get("idle_phase", 0.0))
		var idle_angle: float = visual_time * NPC_IDLE_SPEED + idle_phase
		var idle_offset: Vector2 = Vector2(cos(idle_angle), sin(idle_angle * NPC_IDLE_SWAY_RATIO)) * NPC_IDLE_RADIUS
		npc["visual_position"] = anchor_pos + idle_offset
		if idle_offset.length_squared() > 0.0001:
			npc["visual_rotation"] = idle_offset.angle()

# ─── Economy ──────────────────────────────────────────────────────────────────

func tick_economy() -> void:
	for station in stations:
		var stype: Dictionary = STATION_TYPES[station["type_id"]]
		for resource_id in RESOURCE_IDS:
			var amount: int = get_inventory_amount(station["inventory"], resource_id)
			var drift: int = rng.randi_range(-1, 1)
			if stype["production"].has(resource_id):
				drift += stype["production"][resource_id]
			if stype["consumption"].has(resource_id):
				drift -= stype["consumption"][resource_id]
			set_inventory_amount(station["inventory"], resource_id, maxi(0, amount + drift))
		station["event_mod"] = clampf(station["event_mod"] + rng.randf_range(-0.006, 0.006), -0.2, 0.2)
		trim_inventory_to_capacity(station["inventory"])

# ─── NPC Trading ──────────────────────────────────────────────────────────────

func run_npc_trades() -> void:
	if stations.size() < 2:
		return
	for npc_index in range(npcs.size()):
		var npc: Dictionary = npcs[npc_index]
		# Only idle NPCs start new trades
		var npc_state: String = str(npc.get("state", "idle"))
		if npc_state != "idle":
			continue
		if rng.randf() > float(npc["efficiency"]):
			continue
		var route = find_npc_route(npc)
		if route == null:
			continue
		var resource_id: String = route["resource_id"]
		var from: Dictionary = route["from"]
		var to: Dictionary = route["to"]
		var amount: int = route["amount"]
		var npc_inv: Dictionary = npc["inventory"]
		var vol: int = int(RESOURCES[resource_id]["volume_per_unit"])
		amount = mini(amount, get_inventory_amount(from["inventory"], resource_id))
		amount = mini(amount, get_available_capacity(npc_inv) / vol)
		if amount <= 0:
			continue
		# Phase 1 – NPC buys cargo from the source station
		var ok: bool = agent_buy_from_station(npc, npc_inv, from, resource_id, amount)
		if not ok:
			continue
		npc["cargo_amount"] = amount
		npc["state"] = "traveling_to_sell"
		npc["destination_station_id"] = str(to["id"])
		start_npc_visual_route(npc, npc_index, from, to, resource_id)
		var res: Dictionary = RESOURCES[resource_id]
		var buy_price: int = get_station_buy_price(from, resource_id)
		add_trade_log("NPC %s: Kauft %d %s @ %d von %s" % [str(npc["name"]), amount, str(res["display_name"]), buy_price, str(from["name"])])


func find_npc_route(npc: Dictionary):
	var npc_credits: int = int(npc.get("credits", 0))
	var npc_inv: Dictionary = npc.get("inventory", {})
	var npc_free: int = get_available_capacity(npc_inv) if not npc_inv.is_empty() else int(npc.get("cargo_capacity", 20))
	var best_score: float = 0.0
	var best = null
	for resource_id in RESOURCE_IDS:
		var vol: int = int(RESOURCES[resource_id]["volume_per_unit"])
		for from in stations:
			for to in stations:
				if from["id"] == to["id"]:
					continue
				var buy_price: int = get_station_buy_price(from, resource_id)
				var sell_price: int = get_station_sell_price(to, resource_id)
				var unit_profit: float = float(sell_price - buy_price)
				var from_ratio: float = get_stock_ratio(from, resource_id)
				var to_ratio: float = get_stock_ratio(to, resource_id)
				var rebalance_gap: float = maxf(0.0, from_ratio - to_ratio)
				var rebalance_bonus_per_unit: float = rebalance_gap * 9.0
				if unit_profit < 0.0 and rebalance_bonus_per_unit < 1.8:
					continue
				var max_amount: int = mini(get_inventory_amount(from["inventory"], resource_id), npc_free / vol)
				max_amount = mini(max_amount, get_available_capacity(to["inventory"]) / vol)
				if buy_price > 0:
					max_amount = mini(max_amount, npc_credits / buy_price)
				var amount: int = maxi(0, int(round(float(max_amount) * rng.randf_range(NPC_MIN_TRADE_RATIO, NPC_MAX_TRADE_RATIO))))
				if amount <= 0:
					continue
				var expected: float = (unit_profit + rebalance_bonus_per_unit) * float(amount)
				if expected <= best_score:
					continue
				best_score = expected
				best = {"resource_id": resource_id, "from": from, "to": to, "amount": amount}
	return best

# ─── Pricing ──────────────────────────────────────────────────────────────────

func get_station_buy_price(station: Dictionary, resource_id: String) -> int:
	return ceili(calculate_base_price(station, resource_id) * BUY_MARKUP)


func get_station_sell_price(station: Dictionary, resource_id: String) -> int:
	return maxi(1, floori(calculate_base_price(station, resource_id) * SELL_MARKDOWN))


func calculate_base_price(station: Dictionary, resource_id: String) -> float:
	var res: Dictionary = RESOURCES[resource_id]
	var target: int = maxi(1, station["target_stock"][resource_id])
	var current: int = get_inventory_amount(station["inventory"], resource_id)
	var pressure: float = clampf(float(target - current) / float(target), PRESSURE_CLAMP_MIN, PRESSURE_CLAMP_MAX)
	var tier_bonus: float = 1.0 + 0.1 * (float(res["tier"]) - 1.0)
	var volatility: float = 1.0 + pressure * PRESSURE_PRICE_FACTOR + float(station["event_mod"])
	var distance_factor: float = 1.0 + float(station["distance"]) * DISTANCE_PRICE_FACTOR
	var raw: float = res["base_price"] * tier_bonus * volatility * distance_factor
	return clampf(raw, res["base_price"] * MIN_PRICE_MULTIPLIER, res["base_price"] * MAX_PRICE_MULTIPLIER)


func get_stock_state(station: Dictionary, resource_id: String) -> String:
	var target: int = maxi(1, station["target_stock"][resource_id])
	var ratio: float = float(get_inventory_amount(station["inventory"], resource_id)) / float(target)
	if ratio < VERY_HIGH_DEMAND_RATIO: return "Sehr gefragt"
	if ratio < LOW_STOCK_RATIO: return "Knapp"
	if ratio > OVERSTOCK_RATIO: return "Überschuss"
	return "Stabil"


func get_stock_ratio(station: Dictionary, resource_id: String) -> float:
	var target: int = maxi(1, int(station["target_stock"][resource_id]))
	var current: int = get_inventory_amount(station["inventory"], resource_id)
	return float(current) / float(target)


func get_station_primary_resource_id(station: Dictionary) -> String:
	var stype: Dictionary = STATION_TYPES[station["type_id"]]
	var production: Dictionary = stype["production"]
	var best_resource_id: String = ""
	var best_production: int = -1
	for resource_id in RESOURCE_IDS:
		var produced: int = int(production.get(resource_id, 0))
		if produced > best_production:
			best_production = produced
			best_resource_id = resource_id
	if best_production > 0 and not best_resource_id.is_empty():
		return best_resource_id

	var best_ratio: float = -99999.0
	for resource_id in RESOURCE_IDS:
		var ratio: float = get_stock_ratio(station, resource_id)
		if ratio > best_ratio:
			best_ratio = ratio
			best_resource_id = resource_id
	return best_resource_id if not best_resource_id.is_empty() else DEFAULT_RESOURCE_ID

# ─── Trade ────────────────────────────────────────────────────────────────────

# Shared agent trade helpers — used identically for player and NPCs.
# agent_dict must contain a "credits" key (int).
# agent_inv is the agent's inventory dict (with "capacity" and "stacks").

func agent_buy_from_station(agent_dict: Dictionary, agent_inv: Dictionary, station: Dictionary, resource_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
	var price: int = get_station_buy_price(station, resource_id)
	var cost: int = amount * price
	var agent_creds: int = int(agent_dict.get("credits", 0))
	if agent_creds < cost:
		return false
	if get_inventory_amount(station["inventory"], resource_id) < amount:
		return false
	var res: Dictionary = RESOURCES[resource_id]
	var vol: int = int(res["volume_per_unit"])
	if get_available_capacity(agent_inv) < amount * vol:
		return false
	agent_dict["credits"] = agent_creds - cost
	remove_from_inventory(station["inventory"], resource_id, amount)
	add_to_inventory(agent_inv, resource_id, amount)
	return true


func agent_sell_to_station(agent_dict: Dictionary, agent_inv: Dictionary, station: Dictionary, resource_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
	if get_inventory_amount(agent_inv, resource_id) < amount:
		return false
	var res: Dictionary = RESOURCES[resource_id]
	var vol: int = int(res["volume_per_unit"])
	if get_available_capacity(station["inventory"]) < amount * vol:
		return false
	var sell_price: int = get_station_sell_price(station, resource_id)
	var gain: int = amount * sell_price
	agent_dict["credits"] = int(agent_dict.get("credits", 0)) + gain
	remove_from_inventory(agent_inv, resource_id, amount)
	add_to_inventory(station["inventory"], resource_id, amount)
	return true


func handle_left_click(pos: Vector2) -> void:
	if not is_docked or docking_station == null:
		return
	var control_id: String = get_control_id_at(pos)
	if control_id.is_empty():
		return

	trigger_control_feedback(control_id)
	play_ui_click()

	match control_id:
		"buy":
			attempt_trade(true)
		"sell":
			attempt_trade(false)
		"plus_one":
			quantity = mini(999, quantity + 1)
		"plus_five":
			quantity = mini(999, quantity + 5)
		"max":
			quantity = maxi(1, calc_max_buy(selected_resource_id, docking_station))
		"sell_all":
			quantity = maxi(1, get_inventory_amount(player_agent["inventory"], selected_resource_id))
			attempt_trade(false)
		"sort":
			cycle_sort()
		"dir":
			sort_ascending = not sort_ascending
		_:
			if control_id.begins_with("resource:"):
				selected_resource_id = control_id.trim_prefix("resource:")


func attempt_trade(buy: bool) -> void:
	if docking_station == null:
		return
	var resource_id := selected_resource_id
	var amount := maxi(1, quantity)
	var res: Dictionary = RESOURCES[resource_id]

	if buy:
		var price: int = get_station_buy_price(docking_station, resource_id)
		var cost: int = amount * price
		if int(player_agent["credits"]) < cost: fail_trade("Nicht genug Credits."); return
		if get_inventory_amount(docking_station["inventory"], resource_id) < amount: fail_trade("Station hat zu wenig Bestand."); return
		if get_available_capacity(player_agent["inventory"]) < amount * int(res["volume_per_unit"]): fail_trade("Nicht genug Frachtraum."); return
		agent_buy_from_station(player_agent, player_agent["inventory"], docking_station, resource_id, amount)
		update_average_buy(resource_id, amount, price)
		add_trade_log("Gekauft: %d [%s] %s @ %d von %s" % [amount, get_resource_short_label(resource_id), res["display_name"], price, docking_station["name"]])
		success_trade("Kauf erfolgreich.")
		return

	var sell_price: int = get_station_sell_price(docking_station, resource_id)
	if get_inventory_amount(player_agent["inventory"], resource_id) < amount: fail_trade("Ressource fehlt im Inventar."); return
	if get_available_capacity(docking_station["inventory"]) < amount * int(res["volume_per_unit"]): fail_trade("Stationslager ist voll."); return
	var sell_ok: bool = agent_sell_to_station(player_agent, player_agent["inventory"], docking_station, resource_id, amount)
	if not sell_ok:
		fail_trade("Verkauf fehlgeschlagen.")
		return
	add_trade_log("Verkauft: %d [%s] %s @ %d an %s" % [amount, get_resource_short_label(resource_id), res["display_name"], sell_price, docking_station["name"]])
	success_trade("Verkauf erfolgreich.")

# ─── Drawing ──────────────────────────────────────────────────────────────────

func draw_background() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.02, 0.07), true)
	draw_circle(viewport_size * 0.75, 220.0, Color(0.08, 0.05, 0.16, 0.38))
	draw_circle(viewport_size * Vector2(0.2, 0.85), 180.0, Color(0.06, 0.08, 0.2, 0.28))
	for star in stars:
		var pulse := 0.75 + 0.25 * sin(visual_time * star["speed"] + star["phase"])
		var c: Color = star["color"]
		c.a *= pulse
		draw_circle(star["pos"], star["size"], c)


func draw_station_node(station: Dictionary, index: int) -> void:
	var pulse := 0.84 + 0.16 * sin(visual_time * 1.4 + float(index))
	var radius := 22.0 + 2.5 * sin(visual_time + float(index))
	var station_pos: Vector2 = Vector2(station["position"])
	draw_circle(station_pos, radius, STATION_COLOR * pulse)

	if index % 2 == 0:
		draw_arc(station_pos, radius + 8.0, 0.0, TAU, 48, Color(0.55, 0.9, 1.0, 0.65), 2.5)
	else:
		draw_arc(station_pos, radius + 9.0, visual_time * 0.2, visual_time * 0.2 + TAU, 24, Color(0.7, 0.9, 1.0, 0.7), 2.4)

	var focus := selected_resource_id if RESOURCES.has(selected_resource_id) else DEFAULT_RESOURCE_ID
	var primary_resource_id: String = get_station_primary_resource_id(station)
	var primary_icon_rect: Rect2 = Rect2(station_pos + Vector2(-90.0, -24.0), Vector2(20.0, 20.0))
	draw_resource_icon(primary_icon_rect, primary_resource_id)

	draw_string(ThemeDB.fallback_font, station_pos + Vector2(-64.0, -34.0), station["name"], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14)
	draw_string(ThemeDB.fallback_font, station_pos + Vector2(-64.0, 46.0),
		"Buy %d / Sell %d" % [get_station_buy_price(station, focus), get_station_sell_price(station, focus)],
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)

	var dock_point := get_dock_point(station)
	draw_line(station_pos, dock_point, Color(0.6, 0.95, 1.0, 0.7), 2.0)
	draw_circle(dock_point, 5.0, Color(0.8, 1.0, 1.0, 0.8))


func draw_npc_markers() -> void:
	for npc_index in range(npcs.size()):
		var npc: Dictionary = npcs[npc_index]
		var marker_pos: Vector2 = Vector2(npc["visual_position"])
		var rotation: float = float(npc.get("visual_rotation", 0.0))
		var cargo_resource_id: String = str(npc.get("cargo_resource_id", ""))
		draw_npc_ship(marker_pos, rotation, cargo_resource_id)
		draw_string(ThemeDB.fallback_font, marker_pos + Vector2(10.0, 4.0), npc["name"], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10)


func draw_ship() -> void:
	var forward := Vector2.RIGHT.rotated(player_rotation)
	var side := forward.rotated(PI * 0.5)
	var nose := player_position + forward * 13.0
	var left := player_position - forward * 8.0 + side * 8.0
	var right := player_position - forward * 8.0 - side * 8.0
	var tail := player_position - forward * 11.0
	draw_line(nose, left, PLAYER_COLOR, 2.0)
	draw_line(left, tail, PLAYER_COLOR, 2.0)
	draw_line(tail, right, PLAYER_COLOR, 2.0)
	draw_line(right, nose, PLAYER_COLOR, 2.0)
	draw_circle(player_position + forward * 1.5, 3.4, Color(0.5, 0.85, 1.0, 0.95))


func draw_own_station() -> void:
	draw_circle(player_position, 14.0, Color(0.78, 0.86, 1.0, 0.95))
	draw_arc(player_position, 22.0, 0.0, TAU, 40, Color(0.88, 0.95, 1.0, 0.9), 2.5)
	draw_string(ThemeDB.fallback_font, player_position + Vector2(16.0, 4.0), "HQ", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)


func draw_trade_interface(station: Dictionary) -> void:
	var size := get_viewport_rect().size
	var panel_height := minf(340.0, size.y - 120.0)
	var panel_top := size.y - panel_height - 20.0

	var left := Rect2(Vector2(18.0, panel_top), Vector2(size.x * 0.34 - 24.0, panel_height))
	var middle := Rect2(Vector2(left.end.x + 10.0, panel_top), Vector2(size.x * 0.31 - 16.0, panel_height))
	var right := Rect2(Vector2(middle.end.x + 10.0, panel_top), Vector2(size.x - (middle.end.x + 28.0), panel_height))

	draw_panel(left, "Spielerschiff")
	draw_panel(middle, "Handel")
	draw_panel(right, "%s · %s" % [station["name"], STATION_TYPES[station["type_id"]]["display_name"]])

	draw_player_panel(left, station)
	draw_trade_panel(middle, station)
	draw_station_panel(right, station)


func draw_panel(rect: Rect2, title: String) -> void:
	draw_rect(rect, PANEL_COLOR, true)
	draw_rect(rect, PANEL_BORDER, false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 24.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16)


func draw_player_panel(rect: Rect2, station: Dictionary) -> void:
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 48.0), "Credits: %d" % int(player_agent["credits"]), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, CREDIT_COLOR)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 68.0), "Cargo: %d / %d" % [get_used_capacity(player_agent["inventory"]), int(player_agent["inventory"]["capacity"])], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 88.0), "Inventarwert: %d cr" % get_inventory_value(player_agent["inventory"], station, false), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 108.0), "Suche: %s" % ("(leer)" if search.is_empty() else search), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

	sort_rect = Rect2(rect.position + Vector2(10.0, 114.0), Vector2(rect.size.x * 0.58, 22.0))
	dir_rect = Rect2(rect.position + Vector2(14.0 + rect.size.x * 0.58, 114.0), Vector2(rect.size.x * 0.34 - 20.0, 22.0))
	register_control_rect("sort", sort_rect)
	register_control_rect("dir", dir_rect)
	draw_rect(sort_rect, get_control_color(CONTROL_BG_COLOR, "sort"), true)
	draw_rect(dir_rect, get_control_color(CONTROL_BG_COLOR, "dir"), true)
	draw_string(ThemeDB.fallback_font, sort_rect.position + Vector2(6.0, 15.0), "Sort: %s" % sort_label(sort_key), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
	draw_string(ThemeDB.fallback_font, dir_rect.position + Vector2(6.0, 15.0), "Dir: %s" % ("Auf" if sort_ascending else "Ab"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

	# Always show all resources so the player can see every cargo slot and
	# select any resource for trading even when carrying nothing.
	var rows: Array = get_all_resource_rows(player_agent["inventory"], station, false)
	var start_y: float = rect.position.y + 146.0

	for i in range(mini(rows.size(), 7)):
		var row_rect: Rect2 = Rect2(Vector2(rect.position.x + 10.0, start_y + float(i) * 28.0), Vector2(rect.size.x - 20.0, 24.0))
		draw_row(rows[i], row_rect, false, station)


func draw_station_panel(rect: Rect2, station: Dictionary) -> void:
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 48.0), "Lager: %d / %d" % [get_used_capacity(station["inventory"]), station["inventory"]["capacity"]], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 68.0), "Ziel: ausgeglichener Warenmix", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)

	# Always show all resources so the player can select and inspect any
	# tradeable good, including those temporarily out of stock.
	var rows: Array = get_all_resource_rows(station["inventory"], station, true)
	var start_y: float = rect.position.y + 92.0

	for i in range(mini(rows.size(), 8)):
		var row_rect: Rect2 = Rect2(Vector2(rect.position.x + 10.0, start_y + i * 28.0), Vector2(rect.size.x - 20.0, 24.0))
		draw_row(rows[i], row_rect, true, station)


func draw_row(row: Dictionary, rect: Rect2, station_row: bool, station: Dictionary) -> void:
	var resource_id: String = str(row["resource_id"])
	var res: Dictionary = RESOURCES[resource_id]
	var selected: bool = selected_resource_id == resource_id
	var control_id: String = "resource:%s" % resource_id
	var is_empty: bool = int(row["amount"]) <= 0
	var bg_color: Color = ROW_SELECTED_BG if selected else ROW_DEFAULT_BG
	if is_control_hovered(control_id):
		bg_color = ROW_HOVER_BG if not selected else ROW_SELECTED_BG.lightened(0.12)
	if is_control_active(control_id):
		bg_color = ROW_PRESS_BG
	# Dim empty slots so they are visually distinguishable but still clickable.
	if is_empty and not selected:
		bg_color = bg_color.darkened(0.35)

	draw_rect(rect, bg_color, true)
	draw_rect(rect, PANEL_BORDER if selected else ROW_DEFAULT_BORDER, false, 1.0)

	var icon_rect: Rect2 = Rect2(rect.position + Vector2(3.0, 2.0), Vector2(20.0, 20.0))
	draw_rect(icon_rect, ICON_BG_COLOR, true)
	draw_rect(icon_rect, TIER_BORDER_COLOR[int(res["tier"])], false, 2.0)
	draw_resource_icon(icon_rect, resource_id)

	var text_color: Color = Color(0.7, 0.7, 0.7) if is_empty else Color.WHITE
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(28.0, 14.0), "%s T%d" % [str(res["display_name"]), int(res["tier"])], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, text_color)
	if is_empty:
		# Show price info even for empty slots so the player can evaluate trades.
		var unit_price: int = int(row["unit_price"])
		var label: String = "Ausverkauft · %d cr/St" % unit_price if station_row else "Kein Bestand · %d cr/St" % unit_price
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(28.0, 23.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, text_color)
	else:
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(28.0, 23.0), "Menge:%d Wert:%d Vol:%d" % [int(row["amount"]), int(row["total_value"]), int(row["total_volume"])], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10)
		if station_row:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - STOCK_STATE_OFFSET, 14.0), get_stock_state(station, resource_id), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, STOCK_STATE_COLOR)

	register_control_rect(control_id, rect)


func draw_trade_panel(rect: Rect2, station: Dictionary) -> void:
	var buy := get_station_buy_price(station, selected_resource_id)
	var sell := get_station_sell_price(station, selected_resource_id)
	var total_buy := buy * quantity
	var total_sell := sell * quantity
	var expected := calc_expected_profit(selected_resource_id, quantity, sell)
	var res: Dictionary = RESOURCES[selected_resource_id]
	var preview_rect := Rect2(rect.position + Vector2(rect.size.x - 42.0, 42.0), Vector2(28.0, 28.0))

	draw_rect(preview_rect, ICON_BG_COLOR, true)
	draw_rect(preview_rect, TIER_BORDER_COLOR[res["tier"]], false, 2.0)
	draw_resource_icon(preview_rect, selected_resource_id)

	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 48.0), "Ressource: %s" % res["display_name"], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 70.0), "Menge: %d" % quantity, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 92.0), "Kaufpreis: %d  Verkauf: %d" % [buy, sell], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 112.0), "Gesamt Kauf/Verkauf: %d / %d" % [total_buy, total_sell], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 132.0), "Gewinn ggü. Ø Einkauf: %d" % expected, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, GOOD_COLOR if expected >= 0 else BAD_COLOR)

	plus_one_rect = Rect2(rect.position + Vector2(12.0, 154.0), Vector2(46.0, 24.0))
	plus_five_rect = Rect2(rect.position + Vector2(64.0, 154.0), Vector2(46.0, 24.0))
	max_rect = Rect2(rect.position + Vector2(116.0, 154.0), Vector2(56.0, 24.0))
	sell_all_rect = Rect2(rect.position + Vector2(178.0, 154.0), Vector2(120.0, 24.0))

	draw_button(plus_one_rect, "+1", "plus_one")
	draw_button(plus_five_rect, "+5", "plus_five")
	draw_button(max_rect, "Max", "max")
	draw_button(sell_all_rect, "Alles verkaufen", "sell_all")

	buy_rect = Rect2(rect.position + Vector2(12.0, 188.0), Vector2(rect.size.x - 24.0, 34.0))
	sell_rect = Rect2(rect.position + Vector2(12.0, 228.0), Vector2(rect.size.x - 24.0, 34.0))

	register_control_rect("buy", buy_rect)
	register_control_rect("sell", sell_rect)
	draw_rect(buy_rect, get_control_color(BUY_BUTTON_COLOR, "buy"), true)
	draw_rect(sell_rect, get_control_color(SELL_BUTTON_COLOR, "sell"), true)
	draw_rect(buy_rect, PANEL_BORDER, false, 1.0)
	draw_rect(sell_rect, PANEL_BORDER, false, 1.0)
	draw_string(ThemeDB.fallback_font, buy_rect.position + Vector2(10.0, 22.0), "Kaufen", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16)
	draw_string(ThemeDB.fallback_font, sell_rect.position + Vector2(10.0, 22.0), "Verkaufen", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16)

	var needed_cargo: int = quantity * int(res["volume_per_unit"])
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 280.0), "Credits: %d" % int(player_agent["credits"]), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, CREDIT_COLOR)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 298.0), "Cargo frei / benötigt: %d / %d" % [get_available_capacity(player_agent["inventory"]), needed_cargo], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12.0, 318.0), "Letzte Trades:", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(90.0, 318.0), recent_trades(), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, TRADE_LOG_COLOR)


func draw_button(rect: Rect2, text: String, control_id: String) -> void:
	register_control_rect(control_id, rect)
	draw_rect(rect, get_control_color(UI_BUTTON_BG, control_id), true)
	draw_rect(rect, PANEL_BORDER, false, 1.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(7.0, 16.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)


func draw_toast() -> void:
	var size := get_viewport_rect().size
	var rect := Rect2(Vector2(size.x * 0.5 - 120.0, 22.0), Vector2(240.0, 30.0))
	draw_rect(rect, TOAST_BG_COLOR, true)
	draw_rect(rect, TOAST_BORDER_COLOR, false, 1.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10.0, 20.0), toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)


func draw_resource_icon(icon_rect: Rect2, resource_id: String) -> void:
	var center: Vector2 = icon_rect.get_center()
	var resource_color: Color = get_resource_color(resource_id)
	var glow_rect: Rect2 = Rect2(icon_rect.position + Vector2(1.0, 1.0), icon_rect.size - Vector2(2.0, 2.0))
	draw_rect(glow_rect, resource_color.darkened(0.72), true)
	draw_rect(glow_rect, resource_color.lightened(0.12), false, 1.0)
	match resource_id:
		"wood":
			var top_plank := Rect2(icon_rect.position + Vector2(3.0, 3.0), Vector2(icon_rect.size.x - 6.0, 4.0))
			var mid_plank := Rect2(icon_rect.position + Vector2(4.0, 8.0), Vector2(icon_rect.size.x - 8.0, 4.0))
			var bottom_plank := Rect2(icon_rect.position + Vector2(3.0, 13.0), Vector2(icon_rect.size.x - 6.0, 4.0))
			draw_rect(top_plank, Color(0.86, 0.6, 0.28), true)
			draw_rect(mid_plank, Color(0.74, 0.48, 0.2), true)
			draw_rect(bottom_plank, Color(0.58, 0.37, 0.16), true)
			draw_line(icon_rect.position + Vector2(7.0, 3.0), icon_rect.position + Vector2(7.0, 17.0), Color(0.97, 0.84, 0.62, 0.9), 1.0)
			draw_line(icon_rect.position + Vector2(13.0, 3.0), icon_rect.position + Vector2(13.0, 17.0), Color(0.97, 0.84, 0.62, 0.85), 1.0)
		"coal":
			draw_circle(center + Vector2(-3.2, 2.4), 4.2, Color(0.31, 0.34, 0.4))
			draw_circle(center + Vector2(2.0, -0.8), 4.4, Color(0.12, 0.15, 0.21))
			draw_circle(center + Vector2(4.4, 4.2), 3.1, Color(0.41, 0.45, 0.52))
			draw_circle(center + Vector2(-0.5, -3.8), 2.3, Color(0.72, 0.78, 0.92, 0.45))
		"copper_plate":
			var plate := Rect2(icon_rect.position + Vector2(3.0, 4.0), Vector2(14.0, 10.0))
			draw_rect(plate, Color(0.9, 0.52, 0.23), true)
			draw_rect(plate, Color(1.0, 0.75, 0.42), false, 1.0)
			draw_line(plate.position + Vector2(0.0, 5.0), plate.position + Vector2(14.0, 5.0), Color(1.0, 0.7, 0.3), 1.0)
			draw_circle(plate.position + Vector2(3.0, 2.0), 0.9, Color(1.0, 0.88, 0.64))
			draw_circle(plate.position + Vector2(11.0, 8.0), 0.9, Color(1.0, 0.88, 0.64))
		"plastic":
			var points := PackedVector2Array([
				center + Vector2(0.0, -6.4),
				center + Vector2(5.8, -3.2),
				center + Vector2(5.8, 3.2),
				center + Vector2(0.0, 6.4),
				center + Vector2(-5.8, 3.2),
				center + Vector2(-5.8, -3.2)
			])
			var outline := PackedVector2Array(points)
			outline.append(points[0])
			draw_colored_polygon(points, Color(0.42, 0.9, 1.0))
			draw_polyline(outline, Color(0.9, 0.98, 1.0), 1.2)
			draw_line(center + Vector2(-2.8, -1.0), center + Vector2(2.8, 1.0), Color(0.96, 1.0, 1.0, 0.9), 1.0)
		_:
			draw_circle(center, 5.8, resource_color)
	draw_string(ThemeDB.fallback_font, icon_rect.position + Vector2(3.0, icon_rect.size.y - 2.5), get_resource_short_label(resource_id), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 7, Color(0.96, 0.98, 1.0))


func draw_npc_ship(marker_pos: Vector2, rotation: float, cargo_resource_id: String) -> void:
	var forward: Vector2 = Vector2.RIGHT.rotated(rotation)
	var side: Vector2 = forward.rotated(PI * 0.5)
	var nose: Vector2 = marker_pos + forward * 7.0
	var left: Vector2 = marker_pos - forward * 4.8 + side * 4.2
	var right: Vector2 = marker_pos - forward * 4.8 - side * 4.2
	var hull: PackedVector2Array = PackedVector2Array([nose, left, marker_pos - forward * 2.2, right])
	var outline: PackedVector2Array = PackedVector2Array([nose, left, marker_pos - forward * 2.2, right, nose])
	draw_colored_polygon(hull, NPC_MARKER_COLOR)
	draw_polyline(outline, Color(0.96, 0.99, 1.0, 0.95), 1.2)
	draw_circle(marker_pos - forward * 1.0, 1.5, Color(0.08, 0.14, 0.22, 0.95))
	if not cargo_resource_id.is_empty():
		var cargo_color: Color = get_resource_color(cargo_resource_id)
		draw_circle(marker_pos + side * 5.0, 2.0, cargo_color)
		draw_circle(marker_pos + side * 5.0, 0.85, Color(0.98, 0.99, 1.0, 0.95))


func get_resource_short_label(resource_id: String) -> String:
	match resource_id:
		"wood":
			return "WD"
		"coal":
			return "CO"
		"copper_plate":
			return "CU"
		"plastic":
			return "PL"
		_:
			return "??"


func get_resource_color(resource_id: String) -> Color:
	match resource_id:
		"wood":
			return Color(0.82, 0.58, 0.27)
		"coal":
			return Color(0.46, 0.5, 0.58)
		"copper_plate":
			return Color(0.96, 0.6, 0.28)
		"plastic":
			return Color(0.38, 0.9, 1.0)
		_:
			return Color(0.78, 0.84, 0.96)


func register_control_rect(control_id: String, rect: Rect2) -> void:
	control_hit_rects.append({"id": control_id, "rect": rect})


func get_control_id_at(pos: Vector2) -> String:
	for i in range(control_hit_rects.size() - 1, -1, -1):
		var hit: Dictionary = control_hit_rects[i]
		var hit_rect: Rect2 = hit["rect"]
		if hit_rect.has_point(pos):
			return str(hit["id"])
	return ""


func update_hovered_control(play_sound: bool) -> void:
	var next_control: String = get_control_id_at(mouse_position)
	if next_control == hovered_control_id:
		return
	hovered_control_id = next_control
	if play_sound and not hovered_control_id.is_empty():
		play_ui_hover()


func trigger_control_feedback(control_id: String) -> void:
	feedback_control_id = control_id
	feedback_timer = INTERACT_FEEDBACK_TIME


func is_control_hovered(control_id: String) -> bool:
	return hovered_control_id == control_id


func is_control_active(control_id: String) -> bool:
	return feedback_timer > 0.0 and feedback_control_id == control_id


func get_control_color(base_color: Color, control_id: String) -> Color:
	if is_control_active(control_id):
		return UI_BUTTON_PRESS_BG if base_color == UI_BUTTON_BG else base_color.lightened(0.2)
	if is_control_hovered(control_id):
		return UI_BUTTON_HOVER_BG if base_color == UI_BUTTON_BG else base_color.lightened(0.1)
	return base_color

# ─── Inventory ────────────────────────────────────────────────────────────────

func get_inventory_amount(inventory: Dictionary, resource_id: String) -> int:
	return inventory["stacks"].get(resource_id, 0)


func set_inventory_amount(inventory: Dictionary, resource_id: String, amount: int) -> void:
	if amount <= 0:
		inventory["stacks"].erase(resource_id)
	else:
		inventory["stacks"][resource_id] = amount


func add_to_inventory(inventory: Dictionary, resource_id: String, requested: int) -> int:
	if requested <= 0:
		return 0
	var vol: int = RESOURCES[resource_id]["volume_per_unit"]
	var max_add := get_available_capacity(inventory) / vol
	var add := mini(requested, max_add)
	if add <= 0:
		return 0
	set_inventory_amount(inventory, resource_id, get_inventory_amount(inventory, resource_id) + add)
	return add


func remove_from_inventory(inventory: Dictionary, resource_id: String, requested: int) -> int:
	if requested <= 0:
		return 0
	var remove := mini(requested, get_inventory_amount(inventory, resource_id))
	set_inventory_amount(inventory, resource_id, get_inventory_amount(inventory, resource_id) - remove)
	return remove


func get_used_capacity(inventory: Dictionary) -> int:
	var used := 0
	for res_id in inventory["stacks"]:
		used += inventory["stacks"][res_id] * RESOURCES[res_id]["volume_per_unit"]
	return used


func get_available_capacity(inventory: Dictionary) -> int:
	return maxi(0, inventory["capacity"] - get_used_capacity(inventory))


func trim_inventory_to_capacity(inventory: Dictionary) -> void:
	var over: int = get_used_capacity(inventory) - int(inventory["capacity"])
	if over <= 0:
		return
	for resource_id in RESOURCE_IDS:
		if over <= 0:
			break
		var amount := get_inventory_amount(inventory, resource_id)
		if amount <= 0:
			continue
		var vol: int = RESOURCES[resource_id]["volume_per_unit"]
		var removable := mini(amount, ceili(float(over) / float(vol)))
		set_inventory_amount(inventory, resource_id, amount - removable)
		over -= removable * vol


func get_inventory_value(inventory: Dictionary, station: Dictionary, buy_prices: bool) -> int:
	var total := 0
	for resource_id in RESOURCE_IDS:
		var amount := get_inventory_amount(inventory, resource_id)
		if amount <= 0:
			continue
		var price := get_station_buy_price(station, resource_id) if buy_prices else get_station_sell_price(station, resource_id)
		total += amount * price
	return total


func calc_max_buy(resource_id: String, station: Dictionary) -> int:
	var price: int = maxi(1, get_station_buy_price(station, resource_id))
	var affordable: int = int(player_agent["credits"]) / price
	var stock: int = get_inventory_amount(station["inventory"], resource_id)
	var vol: int = int(RESOURCES[resource_id]["volume_per_unit"])
	var room: int = get_available_capacity(player_agent["inventory"]) / vol
	return maxi(0, mini(stock, mini(affordable, room)))


func calc_expected_profit(resource_id: String, amount: int, sell_price: int) -> int:
	var avg: float = avg_buy_price.get(resource_id, float(sell_price))
	return roundi((sell_price - avg) * amount)


func update_average_buy(resource_id: String, amount: int, unit_price: int) -> void:
	var new_amount: int = get_inventory_amount(player_agent["inventory"], resource_id)
	var old_amount: int = new_amount - amount
	if new_amount <= 0:
		avg_buy_price.erase(resource_id)
		return
	var old_avg: float = avg_buy_price.get(resource_id, float(unit_price))
	avg_buy_price[resource_id] = (old_avg * old_amount + amount * unit_price) / float(new_amount)

# ─── Trade Log / UI ───────────────────────────────────────────────────────────

func add_trade_log(message: String) -> void:
	trade_log.append(message)
	while trade_log.size() > MAX_TRADE_LOG:
		trade_log.remove_at(0)


func recent_trades() -> String:
	if trade_log.is_empty():
		return "Keine"
	var start := maxi(0, trade_log.size() - 2)
	var entries := []
	for i in range(trade_log.size() - 1, start - 1, -1):
		entries.append(trade_log[i])
	return " | ".join(entries)


func success_trade(text: String) -> void:
	status = text
	toast_text = text
	toast_timer = 2.0
	last_trade_failed = false
	if trade_success_player != null:
		trade_success_player.play()


func fail_trade(text: String) -> void:
	status = text
	toast_text = text
	toast_timer = 2.0
	last_trade_failed = true
	if trade_fail_player != null:
		trade_fail_player.play()

# ─── HUD ──────────────────────────────────────────────────────────────────────

func update_hud() -> void:
	var ref_station = docking_station if docking_station != null else (stations[0] if not stations.is_empty() else null)
	var ship_value: int = get_inventory_value(player_agent["inventory"], ref_station, false) if ref_station != null else 0
	hud_label.text = "Credits: %d   Cargo: %d/%d   Stationen: %d   Schiffswert: %d   Ziel: 2000" % [
		int(player_agent["credits"]), get_used_capacity(player_agent["inventory"]), int(player_agent["inventory"]["capacity"]), stations.size(), ship_value
	]

	var dock_text: String
	if is_docked and docking_station != null:
		dock_text = "Docked at %s" % docking_station["name"]
	elif docking_station != null and Input.is_key_pressed(KEY_C) and docking_progress > 0.0:
		dock_text = "Docking %d%%" % int(round(100.0 * docking_progress / DOCK_HOLD_TIME))
	else:
		dock_text = "Undocked"

	status_label.modulate = BAD_COLOR if last_trade_failed else Color.WHITE
	status_label.text = "%s | %s" % [dock_text, status]

# ─── Milestone ────────────────────────────────────────────────────────────────

func build_player_station() -> void:
	var station := create_station("player_hq", "Player Nexus", player_position + Vector2(90.0, -40.0), "trade_station", 5.0, 0.0)
	for resource_id in RESOURCE_IDS:
		add_to_inventory(station["inventory"], resource_id, 8)
	stations.append(station)

# ─── Sorting / Search ─────────────────────────────────────────────────────────

func get_rows(inventory: Dictionary, station: Dictionary, buy_prices: bool) -> Array:
	var rows := []
	for resource_id in RESOURCE_IDS:
		var amount := get_inventory_amount(inventory, resource_id)
		if amount <= 0:
			continue
		var res: Dictionary = RESOURCES[resource_id]
		if not search.is_empty() and not res["display_name"].to_lower().contains(search.to_lower()):
			continue
		var unit := get_station_buy_price(station, resource_id) if buy_prices else get_station_sell_price(station, resource_id)
		rows.append({
			"resource_id": resource_id,
			"amount": amount,
			"unit_price": unit,
			"total_value": amount * unit,
			"total_volume": amount * res["volume_per_unit"]
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var cmp := _compare_rows(a, b)
		return cmp < 0 if sort_ascending else cmp > 0
	)
	return rows


# Like get_rows but always includes every resource, even those with zero stock/cargo.
# Used by both panels so the player can always select any resource.
func get_all_resource_rows(inventory: Dictionary, station: Dictionary, buy_prices: bool) -> Array:
	var rows: Array = []
	for resource_id in RESOURCE_IDS:
		var amount: int = get_inventory_amount(inventory, resource_id)
		var res: Dictionary = RESOURCES[resource_id]
		if not search.is_empty() and not str(res["display_name"]).to_lower().contains(search.to_lower()):
			continue
		var unit: int = get_station_buy_price(station, resource_id) if buy_prices else get_station_sell_price(station, resource_id)
		var vol: int = int(res["volume_per_unit"])
		rows.append({
			"resource_id": resource_id,
			"amount": amount,
			"unit_price": unit,
			"total_value": amount * unit,
			"total_volume": amount * vol
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var cmp := _compare_rows(a, b)
		return cmp < 0 if sort_ascending else cmp > 0
	)
	return rows


func _compare_rows(a: Dictionary, b: Dictionary) -> int:
	match sort_key:
		"name":
			var na: String = RESOURCES[a["resource_id"]]["display_name"]
			var nb: String = RESOURCES[b["resource_id"]]["display_name"]
			if na < nb: return -1
			if na > nb: return 1
			return 0
		"tier":
			return RESOURCES[a["resource_id"]]["tier"] - RESOURCES[b["resource_id"]]["tier"]
		"amount":
			return a["amount"] - b["amount"]
		"unit_price":
			return a["unit_price"] - b["unit_price"]
		_:
			return a["total_value"] - b["total_value"]


func cycle_sort() -> void:
	var idx := SORT_KEYS.find(sort_key)
	sort_key = SORT_KEYS[(idx + 1) % SORT_KEYS.size()]


func sort_label(key: String) -> String:
	match key:
		"name": return "Name"
		"tier": return "Tier"
		"amount": return "Menge"
		"value": return "Gesamtwert"
		"unit_price": return "Preis/Einheit"
		_: return key


func ensure_resource_selected() -> void:
	if not RESOURCES.has(selected_resource_id):
		selected_resource_id = DEFAULT_RESOURCE_ID

# ─── Starfield ────────────────────────────────────────────────────────────────

func generate_starfield() -> void:
	stars.clear()
	var viewport_size := get_viewport_rect().size
	for _i in range(STARFIELD_COUNT):
		stars.append({
			"pos": Vector2(rng.randf_range(0.0, viewport_size.x), rng.randf_range(0.0, viewport_size.y)),
			"size": rng.randf_range(0.7, 2.2),
			"phase": rng.randf_range(0.0, TAU),
			"speed": rng.randf_range(0.8, 2.2),
			"color": Color(
				0.78 + rng.randf_range(0.0, 0.2),
				0.78 + rng.randf_range(0.0, 0.2),
				0.9 + rng.randf_range(0.0, 0.1),
				0.45 + rng.randf_range(0.0, 0.5)
			)
		})

# ─── Audio ────────────────────────────────────────────────────────────────────

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

	ui_hover_player = AudioStreamPlayer.new()
	ui_hover_player.stream = create_tone_stream(0.04, 780.0, 860.0, 0.12)
	ui_hover_player.volume_db = -18.0
	add_child(ui_hover_player)

	ui_click_player = AudioStreamPlayer.new()
	ui_click_player.stream = create_tone_stream(0.05, 620.0, 520.0, 0.18)
	ui_click_player.volume_db = -13.0
	add_child(ui_click_player)

	trade_success_player = AudioStreamPlayer.new()
	trade_success_player.stream = create_tone_stream(0.12, 520.0, 760.0, 0.2)
	trade_success_player.volume_db = -12.0
	add_child(trade_success_player)

	trade_fail_player = AudioStreamPlayer.new()
	trade_fail_player.stream = create_tone_stream(0.1, 280.0, 190.0, 0.22)
	trade_fail_player.volume_db = -11.0
	add_child(trade_fail_player)

	audio_prime_player = AudioStreamPlayer.new()
	audio_prime_player.stream = create_tone_stream(0.03, 440.0, 440.0, 0.001)
	audio_prime_player.volume_db = -80.0
	add_child(audio_prime_player)


func prime_audio() -> void:
	if audio_primed:
		return
	audio_primed = true
	if audio_prime_player != null:
		audio_prime_player.play()


func play_ui_hover() -> void:
	prime_audio()
	if ui_hover_player != null:
		ui_hover_player.play()


func play_ui_click() -> void:
	prime_audio()
	if ui_click_player != null:
		ui_click_player.play()


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

# ─── Save / Load ──────────────────────────────────────────────────────────────

func save_state() -> void:
	var stations_data := []
	for st in stations:
		stations_data.append({
			"id": st["id"],
			"name": st["name"],
			"type_id": st["type_id"],
			"position": {"x": st["position"].x, "y": st["position"].y},
			"distance": st["distance"],
			"event_mod": st["event_mod"],
			"target_stock": st["target_stock"].duplicate(),
			"inventory": _save_inventory(st["inventory"])
		})
	var npcs_data := []
	for npc in npcs:
		var npc_cap: int = int(npc.get("cargo_capacity", 20))
		npcs_data.append({
			"name": str(npc["name"]),
			"cargo_capacity": npc_cap,
			"efficiency": float(npc["efficiency"]),
			"home_station_id": str(npc.get("home_station_id", "")),
			"credits": int(npc.get("credits", 400)),
			"inventory": _save_inventory(npc.get("inventory", {"capacity": npc_cap, "stacks": {}}))
		})
	var save := {
		"version": SAVE_VERSION,
		"credits": int(player_agent["credits"]),
		"player_position": {"x": player_position.x, "y": player_position.y},
		"player_inventory": _save_inventory(player_agent["inventory"]),
		"avg_buy_price": avg_buy_price.duplicate(),
		"stations": stations_data,
		"npcs": npcs_data,
		"trade_log": trade_log.duplicate(),
		"goal_reached": goal_reached,
		"has_own_station": has_own_station,
		"selected_resource": selected_resource_id,
		"quantity": quantity,
		"search": search,
		"sort_key": sort_key,
		"sort_ascending": sort_ascending
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Save failed: could not open file")
		return
	file.store_string(JSON.stringify(save))
	file.close()


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if not parsed is Dictionary:
		push_warning("Load failed: invalid save data")
		return
	var data: Dictionary = parsed

	player_agent["credits"] = maxi(0, int(data.get("credits", 600)))
	var pp = data.get("player_position", {"x": 130, "y": 120})
	player_position = Vector2(float(pp.get("x", 130)), float(pp.get("y", 120)))
	_restore_inventory(player_agent["inventory"], data.get("player_inventory", {}), CARGO_CAPACITY)

	avg_buy_price.clear()
	var abp = data.get("avg_buy_price", {})
	if abp is Dictionary:
		for k in abp:
			avg_buy_price[k] = float(abp[k])

	var saved_stations = data.get("stations", [])
	if saved_stations is Array and not saved_stations.is_empty():
		stations.clear()
		for st_data in saved_stations:
			var type_id: String = str(st_data.get("type_id", "trade_station"))
			if not STATION_TYPES.has(type_id):
				type_id = "trade_station"
			var sp = st_data.get("position", {"x": 0, "y": 0})
			var station := create_station(
				str(st_data.get("id", "")),
				str(st_data.get("name", st_data.get("id", ""))),
				Vector2(float(sp.get("x", 0)), float(sp.get("y", 0))),
				type_id,
				float(st_data.get("distance", 0)),
				float(st_data.get("event_mod", 0))
			)
			var saved_ts = st_data.get("target_stock", {})
			if saved_ts is Dictionary and not saved_ts.is_empty():
				station["target_stock"].clear()
				for resource_id in RESOURCE_IDS:
					station["target_stock"][resource_id] = maxi(0, int(saved_ts.get(resource_id, STATION_TYPES[type_id]["target_stock"][resource_id])))
			_restore_inventory(station["inventory"], st_data.get("inventory", {}), STATION_TYPES[type_id]["capacity"])
			stations.append(station)

	# Restore NPC credits and inventories; state resets to idle on load
	var saved_npcs = data.get("npcs", [])
	if saved_npcs is Array and not saved_npcs.is_empty():
		for i in range(mini(saved_npcs.size(), npcs.size())):
			var nd = saved_npcs[i]
			if nd is Dictionary:
				var npc: Dictionary = npcs[i]
				npc["credits"] = maxi(0, int(nd.get("credits", 400)))
				var npc_cap: int = int(npc.get("cargo_capacity", 20))
				_restore_inventory(npc["inventory"], nd.get("inventory", {}), npc_cap)
				# In-transit cargo is dropped on reload; NPC resumes trading fresh
				npc["state"] = "idle"
				npc["cargo_amount"] = 0
				npc["destination_station_id"] = ""

	var tl = data.get("trade_log", [])
	trade_log.clear()
	if tl is Array:
		for entry in tl:
			if trade_log.size() >= MAX_TRADE_LOG:
				break
			trade_log.append(str(entry))

	goal_reached = bool(data.get("goal_reached", false))
	has_own_station = bool(data.get("has_own_station", false))
	var sr: String = str(data.get("selected_resource", DEFAULT_RESOURCE_ID))
	selected_resource_id = sr if RESOURCES.has(sr) else DEFAULT_RESOURCE_ID
	quantity = maxi(1, int(data.get("quantity", 1)))
	search = str(data.get("search", ""))
	var sk: String = str(data.get("sort_key", "value"))
	sort_key = sk if SORT_KEYS.has(sk) else "value"
	sort_ascending = bool(data.get("sort_ascending", false))
	sync_npc_visuals()


func _save_inventory(inventory: Dictionary) -> Dictionary:
	return {"capacity": inventory["capacity"], "stacks": inventory["stacks"].duplicate()}


func _restore_inventory(target: Dictionary, source, fallback_capacity: int) -> void:
	target["stacks"].clear()
	if source is Dictionary:
		var saved_cap := int(source.get("capacity", 0))
		target["capacity"] = saved_cap if saved_cap > 0 else fallback_capacity
		var stacks = source.get("stacks", {})
		if stacks is Dictionary:
			for resource_id in RESOURCE_IDS:
				if stacks.has(resource_id):
					var amount := int(stacks[resource_id])
					if amount > 0:
						target["stacks"][resource_id] = amount
	else:
		target["capacity"] = fallback_capacity
