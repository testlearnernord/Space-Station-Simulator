extends Node2D

# ─── Constants ────────────────────────────────────────────────────────────────

const SAVE_VERSION := 3
const SAVE_DIRECTORY := "user://"
const SAVE_FILE_NAME := "savegame.json"
const SAVE_PATH := SAVE_DIRECTORY + SAVE_FILE_NAME
const DEFAULT_RESOURCE_ID := "ore"
const CARGO_CAPACITY := 32
const RESET_HOTKEY := KEY_F8
const RESET_HOTKEY_LABEL := "F8"
const DEFAULT_PLAYER_POSITION := Vector2(130, 120)
const DEFAULT_STATUS := "Fly with WASD, hold C near station to dock, hold X near NPC to hail. Press %s to reset." % RESET_HOTKEY_LABEL

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
const NPC_VISUAL_MIN_TRAVEL := 20.0  # travel duration in seconds (5× slower than original 4.0)
const NPC_VISUAL_MAX_TRAVEL := 50.0  # travel duration in seconds (5× slower than original 10.0)
const NPC_IDLE_RADIUS := 4.0
const NPC_ANCHOR_BASE_ANGLE := 0.95
const NPC_ANCHOR_ANGLE_STEP := 1.63
const NPC_IDLE_SPEED := 0.25
const NPC_IDLE_SWAY_RATIO := 1.17
const NPC_HOVER_RADIUS := 12.0
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
const TRANSIT_ZONE := 22.0
const TRANSITION_DURATION := 0.7
const INTERSYSTEM_NPC_TRAVEL_TIME := 9.0

const NPC_INTERACT_RANGE := 80.0
const NPC_HAIL_HOLD_TIME := 1.5

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
const NPC_TOOLTIP_BG := Color(0.06, 0.10, 0.18, 0.94)
const NPC_TOOLTIP_BORDER := Color(0.72, 0.95, 0.45, 0.75)
const NPC_HAIL_COLOR := Color(0.72, 0.95, 0.45, 0.88)
const NPC_MENU_BG := Color(0.06, 0.09, 0.16, 0.96)
const NPC_MENU_BORDER := Color(0.72, 0.95, 0.45, 0.82)
const NPC_MENU_ACCENT := Color(0.72, 0.95, 0.45, 1.0)
const NPC_MENU_SUBHEADING := Color(0.65, 0.88, 1.0, 0.9)

const NPC_SHIP_NAMES := [
	"Wanderer", "Eisenmaultier", "Corvus", "Sonnengleiter", "Blauer Blitz",
	"Hafnium", "Staubläufer", "Nexus Star", "Freigeist", "Silberkante",
	"Polarlicht", "Aschejäger", "Frachter X-7", "Rote Wolke", "Tiefenläufer",
	"Aurora", "Stahlfalke", "Ventura", "Driftläufer", "Kobaltpfeil"
]
const NPC_FACTIONS := [
	"Handelsgilde", "Bergbaukonsortium", "Freie Händler",
	"Nexus Corp", "Kolonistenverband", "Raumwächter", "Fraktionslos"
]
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
const PROCESS_BUTTON_COLOR := Color(0.28, 0.16, 0.44, 0.95)

# T1 raw resources and T2 processed resources
const RESOURCES := {
	"ore": {
		"id": "ore", "display_name": "Erz", "tier": 1, "category": "Rohstoff",
		"icon": "◈", "base_price": 20.0, "volume_per_unit": 1,
		"description": "Rohes Mineral. Grundlage der Metallverarbeitung."
	},
	"raw_gas": {
		"id": "raw_gas", "display_name": "Rohgas", "tier": 1, "category": "Rohstoff",
		"icon": "◉", "base_price": 18.0, "volume_per_unit": 1,
		"description": "Unraffiniertes Gasgemisch aus Nebeln."
	},
	"crystal": {
		"id": "crystal", "display_name": "Kristall", "tier": 1, "category": "Rohstoff",
		"icon": "◇", "base_price": 26.0, "volume_per_unit": 1,
		"description": "Reine Kristallstrukturen. Basis synthetischer Materialien."
	},
	"alloy": {
		"id": "alloy", "display_name": "Legierung", "tier": 2, "category": "Verarbeitetes Material",
		"icon": "▣", "base_price": 55.0, "volume_per_unit": 2,
		"description": "Hochfestes Metall. Aus Erz geschmolzen."
	},
	"fuel": {
		"id": "fuel", "display_name": "Treibstoff", "tier": 2, "category": "Verarbeitetes Material",
		"icon": "⬟", "base_price": 48.0, "volume_per_unit": 2,
		"description": "Raffinierter Reaktionstreibstoff. Aus Rohgas gewonnen."
	},
	"polymer": {
		"id": "polymer", "display_name": "Polymer", "tier": 2, "category": "Verarbeitetes Material",
		"icon": "⬡", "base_price": 62.0, "volume_per_unit": 2,
		"description": "Synthetisches Verbundmaterial. Aus Kristall synthetisiert."
	}
}

const RESOURCE_IDS := ["ore", "raw_gas", "crystal", "alloy", "fuel", "polymer"]
const SORT_KEYS := ["name", "tier", "amount", "value", "unit_price"]

# Processing modules: each converts ratio units of T1 input into 1 unit of T2 output.
# fee: credits charged per output unit produced (goes to station owner).
const PROCESSING_MODULES := {
	"smelter": {
		"id": "smelter", "display_name": "Schmelzofen",
		"input": "ore", "output": "alloy", "ratio": 3, "fee": 14,
		"description": "Schmilzt Erz zu Legierung. 3 Erz → 1 Legierung."
	},
	"refinery": {
		"id": "refinery", "display_name": "Raffinerie",
		"input": "raw_gas", "output": "fuel", "ratio": 3, "fee": 12,
		"description": "Raffiniert Rohgas zu Treibstoff. 3 Rohgas → 1 Treibstoff."
	},
	"synthesizer": {
		"id": "synthesizer", "display_name": "Synthesizer",
		"input": "crystal", "output": "polymer", "ratio": 2, "fee": 16,
		"description": "Synthetisiert Polymer aus Kristall. 2 Kristall → 1 Polymer."
	}
}

# Station type definitions: capacity, target_stock, production, consumption, modules
const STATION_TYPES := {
	"mining_outpost": {
		"id": "mining_outpost", "display_name": "Bergbau-Außenposten", "capacity": 130,
		"target_stock": {"ore": 52, "raw_gas": 10, "crystal": 8, "alloy": 16, "fuel": 8, "polymer": 6},
		"production": {"ore": 5}, "consumption": {"fuel": 1},
		"modules": ["smelter"]
	},
	"gas_platform": {
		"id": "gas_platform", "display_name": "Gasplattform", "capacity": 125,
		"target_stock": {"ore": 10, "raw_gas": 50, "crystal": 8, "alloy": 8, "fuel": 16, "polymer": 6},
		"production": {"raw_gas": 5}, "consumption": {"alloy": 1},
		"modules": ["refinery"]
	},
	"crystal_mine": {
		"id": "crystal_mine", "display_name": "Kristallmine", "capacity": 120,
		"target_stock": {"ore": 8, "raw_gas": 8, "crystal": 42, "alloy": 6, "fuel": 8, "polymer": 16},
		"production": {"crystal": 4}, "consumption": {"fuel": 1},
		"modules": ["synthesizer"]
	},
	"trade_hub": {
		"id": "trade_hub", "display_name": "Handelsstation", "capacity": 175,
		"target_stock": {"ore": 22, "raw_gas": 20, "crystal": 18, "alloy": 24, "fuel": 20, "polymer": 18},
		"production": {}, "consumption": {},
		"modules": []
	},
	"industrial_complex": {
		"id": "industrial_complex", "display_name": "Industriekomplex", "capacity": 160,
		"target_stock": {"ore": 30, "raw_gas": 28, "crystal": 22, "alloy": 28, "fuel": 26, "polymer": 22},
		"production": {"alloy": 1, "fuel": 1, "polymer": 1}, "consumption": {"ore": 3, "raw_gas": 3, "crystal": 2},
		"modules": ["smelter", "refinery", "synthesizer"]
	}
}

# Star system definitions.
# neighbors: direction -> system_id (empty string means map boundary).
# Visual theme: bg_color, two nebula overlay colors, star_r/g/b_base, accent color.
const SYSTEMS := {
	"ymir_prime": {
		"id": "ymir_prime", "display_name": "Ymir-Prime",
		"neighbors": {"north": "aether_nebula", "east": "igneos_sector", "south": "glacies_rift", "west": "verdun_cluster"},
		"bg_color": Color(0.01, 0.02, 0.07),
		"nebula1_pos_ratio": Vector2(0.75, 0.72), "nebula1_radius": 220.0, "nebula1_color": Color(0.08, 0.05, 0.16, 0.38),
		"nebula2_pos_ratio": Vector2(0.2, 0.85),  "nebula2_radius": 180.0, "nebula2_color": Color(0.06, 0.08, 0.20, 0.28),
		"star_r_base": 0.78, "star_g_base": 0.78, "star_b_base": 0.90,
		"accent_color": Color(0.35, 0.75, 1.0, 0.80)
	},
	"aether_nebula": {
		"id": "aether_nebula", "display_name": "Aether-Nebel",
		"neighbors": {"north": "", "east": "", "south": "ymir_prime", "west": ""},
		"bg_color": Color(0.02, 0.01, 0.09),
		"nebula1_pos_ratio": Vector2(0.55, 0.40), "nebula1_radius": 260.0, "nebula1_color": Color(0.20, 0.05, 0.38, 0.44),
		"nebula2_pos_ratio": Vector2(0.25, 0.70), "nebula2_radius": 200.0, "nebula2_color": Color(0.14, 0.04, 0.28, 0.36),
		"star_r_base": 0.72, "star_g_base": 0.65, "star_b_base": 0.98,
		"accent_color": Color(0.72, 0.35, 1.0, 0.80)
	},
	"igneos_sector": {
		"id": "igneos_sector", "display_name": "Igneos-Sektor",
		"neighbors": {"north": "", "east": "", "south": "", "west": "ymir_prime"},
		"bg_color": Color(0.06, 0.01, 0.01),
		"nebula1_pos_ratio": Vector2(0.60, 0.45), "nebula1_radius": 240.0, "nebula1_color": Color(0.30, 0.08, 0.02, 0.42),
		"nebula2_pos_ratio": Vector2(0.30, 0.75), "nebula2_radius": 190.0, "nebula2_color": Color(0.22, 0.06, 0.02, 0.32),
		"star_r_base": 0.98, "star_g_base": 0.72, "star_b_base": 0.52,
		"accent_color": Color(1.0, 0.42, 0.10, 0.80)
	},
	"glacies_rift": {
		"id": "glacies_rift", "display_name": "Glacies-Rift",
		"neighbors": {"north": "ymir_prime", "east": "", "south": "", "west": ""},
		"bg_color": Color(0.01, 0.02, 0.07),
		"nebula1_pos_ratio": Vector2(0.50, 0.35), "nebula1_radius": 250.0, "nebula1_color": Color(0.04, 0.20, 0.38, 0.46),
		"nebula2_pos_ratio": Vector2(0.78, 0.78), "nebula2_radius": 195.0, "nebula2_color": Color(0.02, 0.14, 0.28, 0.36),
		"star_r_base": 0.68, "star_g_base": 0.88, "star_b_base": 1.00,
		"accent_color": Color(0.28, 0.88, 1.0, 0.80)
	},
	"verdun_cluster": {
		"id": "verdun_cluster", "display_name": "Verdun-Cluster",
		"neighbors": {"north": "", "east": "ymir_prime", "south": "", "west": ""},
		"bg_color": Color(0.01, 0.05, 0.03),
		"nebula1_pos_ratio": Vector2(0.45, 0.40), "nebula1_radius": 235.0, "nebula1_color": Color(0.04, 0.20, 0.10, 0.42),
		"nebula2_pos_ratio": Vector2(0.72, 0.72), "nebula2_radius": 185.0, "nebula2_color": Color(0.03, 0.14, 0.08, 0.32),
		"star_r_base": 0.60, "star_g_base": 0.92, "star_b_base": 0.70,
		"accent_color": Color(0.20, 0.92, 0.50, 0.80)
	}
}


# ─── State ────────────────────────────────────────────────────────────────────

var rng := RandomNumberGenerator.new()
var stations: Array = []
var npcs: Array = []
var player_agent: Dictionary = {"credits": 600, "inventory": {"capacity": CARGO_CAPACITY, "stacks": {}}}
var avg_buy_price: Dictionary = {}
var trade_log: Array = []
var all_stars: Dictionary = {}

var current_system_id := "ymir_prime"
var is_transitioning := false
var transition_direction := ""
var transition_dest_system := ""
var transition_progress := 0.0
var transition_switched := false

var player_position := DEFAULT_PLAYER_POSITION
var player_velocity := Vector2.ZERO
var player_rotation := 0.0
var is_docked := false
var docking_station: Dictionary = {}
var docking_progress := 0.0
var was_dock_held := false
var goal_reached := false
var has_own_station := false

var economy_accumulator := 0.0
var npc_accumulator := 0.0
var save_accumulator := 0.0
var visual_time := 0.0

var status := DEFAULT_STATUS
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
var hovered_npc_id := ""
var feedback_control_id := ""
var feedback_timer := 0.0

var npc_hail_progress := 0.0
var npc_hail_target_id := ""
var is_npc_menu_open := false
var npc_menu_npc: Dictionary = {}
var npc_menu_page := "main"
var npc_menu_selected_resource := ""
var npc_menu_qty := 1

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
	generate_all_starfields()
	setup_audio()
	ensure_resource_selected()
	update_hud()


func _exit_tree() -> void:
	save_state()


func _process(delta: float) -> void:
	visual_time += delta
	engine_sound_cooldown = maxf(0.0, engine_sound_cooldown - delta)

	update_system_transition(delta)

	if is_transitioning:
		queue_redraw()
		return

	if is_docked:
		player_velocity = Vector2.ZERO
		if not docking_station.is_empty():
			player_position = get_dock_point(docking_station)
			player_rotation = (docking_station["position"] - player_position).angle()
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or \
				Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
			is_docked = false
			docking_station = {}
			status = "Undocked. Hold C near a station to dock again."
	elif is_npc_menu_open:
		player_velocity = Vector2.ZERO
	else:
		handle_movement(delta)
		update_docking(delta)
		update_npc_hail(delta)

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
		status = "Ziel erreicht! Optimiere weiter deine Handelsrouten."

	if int(player_agent["credits"]) >= 2600 and not has_own_station:
		has_own_station = true
		build_player_station()
		status = "Eigene Industriestation errichtet. Du erhältst nun Verarbeitungsgebühren."

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
		var keycode: int = int(event.keycode)
		if keycode == RESET_HOTKEY:
			reset_run()
			return
		prime_audio()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_left_click(event.position)
		return

	# NPC menu keyboard handling (ESC and quantity controls for trade page)
	if is_npc_menu_open:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				close_npc_menu()
				queue_redraw()
				return
			if npc_menu_page == "trade":
				if event.keycode == KEY_KP_ADD or event.keycode == KEY_EQUAL:
					npc_menu_qty = mini(999, npc_menu_qty + 1)
					queue_redraw()
				elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
					npc_menu_qty = maxi(1, npc_menu_qty - 1)
					queue_redraw()
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
		var is_movement_key: bool = InputMap.event_is_action(event, "move_left") or \
				InputMap.event_is_action(event, "move_right") or \
				InputMap.event_is_action(event, "move_up") or \
				InputMap.event_is_action(event, "move_down")
		if not is_movement_key:
			search += char(event.unicode).to_lower()


func _draw() -> void:
	draw_background()
	var draw_idx: int = 0
	for station in stations:
		if str(station["system_id"]) == current_system_id:
			draw_station_node(station, draw_idx)
			draw_idx += 1
	draw_npc_markers()

	if has_own_station:
		draw_own_station()
	else:
		draw_ship()

	control_hit_rects.clear()
	if is_docked and not docking_station.is_empty():
		draw_trade_interface(docking_station)
	elif is_npc_menu_open and not npc_menu_npc.is_empty():
		draw_npc_menu()

	if not toast_text.is_empty():
		draw_toast()

	if is_transitioning:
		draw_transition_overlay()


# ─── Setup ────────────────────────────────────────────────────────────────────

func setup_defaults() -> void:
	rng.seed = DEFAULT_RNG_SEED
	stations = []
	npcs = []
	player_position = DEFAULT_PLAYER_POSITION
	player_velocity = Vector2.ZERO
	player_rotation = 0.0
	is_docked = false
	docking_station = {}
	docking_progress = 0.0
	was_dock_held = false
	goal_reached = false
	has_own_station = false
	current_system_id = "ymir_prime"
	is_transitioning = false
	transition_progress = 0.0
	trade_log = []
	avg_buy_price = {}
	economy_accumulator = 0.0
	npc_accumulator = 0.0
	save_accumulator = 0.0
	npc_hail_progress = 0.0
	npc_hail_target_id = ""
	is_npc_menu_open = false
	npc_menu_npc = {}
	npc_menu_page = "main"
	npc_menu_selected_resource = ""
	npc_menu_qty = 1
	player_agent = {"credits": 600, "inventory": {"capacity": CARGO_CAPACITY, "stacks": {}}}
	spawn_all_systems()


func spawn_all_systems() -> void:
	# Ymir-Prime (center – original system, blue)
	create_station("Bergbauzentrum Alpha",  "mining_outpost",  Vector2(195, 165), 42, "ymir_prime")
	create_station("Gasplattform Ymir-1",   "gas_platform",    Vector2(945, 158), 42, "ymir_prime")
	create_station("Handelsstation Kern",   "trade_hub",       Vector2(205, 512), 42, "ymir_prime")
	create_station("Industriekomplex Y-3",  "industrial_complex", Vector2(938, 500), 42, "ymir_prime")

	# Aether-Nebel (north – purple)
	create_station("Nebel-Mine Aether-1",   "crystal_mine",    Vector2(188, 158), 47, "aether_nebula")
	create_station("Handelsknoten Aether",  "trade_hub",       Vector2(942, 162), 47, "aether_nebula")
	create_station("Synthese-Labor A-7",    "industrial_complex", Vector2(580, 345), 47, "aether_nebula")
	create_station("Gas-Plattform Aether",  "gas_platform",    Vector2(200, 510), 47, "aether_nebula")

	# Igneos-Sektor (east – red/orange)
	create_station("Schmelzwerk Igneos-1",  "mining_outpost",  Vector2(192, 162), 53, "igneos_sector")
	create_station("Raffinerie Igneos-2",   "gas_platform",    Vector2(940, 162), 53, "igneos_sector")
	create_station("Kristallhöhle Igneos",  "crystal_mine",    Vector2(200, 505), 53, "igneos_sector")
	create_station("Handelsposten Igneos",  "trade_hub",       Vector2(938, 502), 53, "igneos_sector")

	# Glacies-Rift (south – ice blue)
	create_station("Eismine Glacies-1",     "crystal_mine",    Vector2(192, 158), 61, "glacies_rift")
	create_station("Gasfeld Glacies-2",     "gas_platform",    Vector2(945, 162), 61, "glacies_rift")
	create_station("Kältezentrum Glacies",  "trade_hub",       Vector2(200, 508), 61, "glacies_rift")
	create_station("Industrie-Depot G-4",   "industrial_complex", Vector2(940, 505), 61, "glacies_rift")

	# Verdun-Cluster (west – green/teal)
	create_station("Erzlager Verdun-1",     "mining_outpost",  Vector2(190, 162), 67, "verdun_cluster")
	create_station("Kristallfarm Verdun-2", "crystal_mine",    Vector2(942, 158), 67, "verdun_cluster")
	create_station("Raffineriehof Verdun",  "gas_platform",    Vector2(200, 508), 67, "verdun_cluster")
	create_station("Handelszentrum Verdun", "trade_hub",       Vector2(938, 502), 67, "verdun_cluster")

	# Spawn NPCs for each station
	for station in stations:
		var station_id: String = str(station["id"])
		var sys_id: String = str(station["system_id"])
		create_npc(station_id, sys_id)
		if rng.randf() < 0.35:
			create_npc(station_id, sys_id)


func create_station(display_name: String, type_id: String, position: Vector2, seed_offset: int, system_id: String) -> void:
	var stype: Dictionary = STATION_TYPES[type_id]
	var station_rng := RandomNumberGenerator.new()
	station_rng.seed = DEFAULT_RNG_SEED + seed_offset
	var inventory: Dictionary = {"capacity": int(stype["capacity"]), "stacks": {}}
	var target_stock: Dictionary = stype["target_stock"]
	for rid in RESOURCE_IDS:
		if target_stock.has(rid):
			var tgt: int = int(target_stock[rid])
			var bonus: int = station_rng.randi_range(0, MAX_INITIAL_STOCK_BONUS)
			inventory["stacks"][rid] = mini(tgt + bonus, int(stype["capacity"]))
	var station_id: String = type_id + "_" + str(stations.size())
	var modules_copy: Array = []
	for m in stype["modules"]:
		modules_copy.append(m)
	stations.append({
		"id": station_id, "display_name": display_name, "type_id": type_id,
		"position": position, "inventory": inventory,
		"trade_log": [], "is_player_owned": false,
		"system_id": system_id,
		"modules": modules_copy,
		"processing_income": 0
	})


func create_npc(anchor_station_id: String, system_id: String) -> void:
	var anchor_station: Dictionary = get_station_by_id(anchor_station_id)
	if anchor_station.is_empty():
		return
	var angle: float = float(npcs.size()) * NPC_ANCHOR_ANGLE_STEP + NPC_ANCHOR_BASE_ANGLE
	var offset_dist: float = NPC_IDLE_RADIUS + float(npcs.size() % 6) * 2.2
	var pos: Vector2 = anchor_station["position"] + Vector2(cos(angle) * offset_dist, sin(angle) * offset_dist)
	var ship_name: String = str(NPC_SHIP_NAMES[rng.randi() % NPC_SHIP_NAMES.size()])
	var faction: String = str(NPC_FACTIONS[rng.randi() % NPC_FACTIONS.size()])
	npcs.append({
		"id": "npc_" + str(npcs.size()),
		"ship_name": ship_name,
		"faction": faction,
		"anchor_station_id": anchor_station_id,
		"system_id": system_id,
		"dest_station_id": "", "dest_system_id": "",
		"state": "idle",
		"position": pos, "visual_position": pos, "target_position": pos,
		"travel_progress": 0.0, "travel_duration": 1.0,
		"inventory": {"capacity": 24, "stacks": {}},
		"credits": float(200 + rng.randi_range(0, 180)),
		"intersystem_travel_timer": 0.0
	})


func build_player_station() -> void:
	var station_id: String = "industrial_complex_player_hq"
	var pos := Vector2(580.0, 340.0)
	var stype: Dictionary = STATION_TYPES["industrial_complex"]
	var inventory: Dictionary = {"capacity": int(stype["capacity"]), "stacks": {}}
	var target_stock: Dictionary = stype["target_stock"]
	for rid in RESOURCE_IDS:
		if target_stock.has(rid):
			inventory["stacks"][rid] = int(target_stock[rid])
	stations.append({
		"id": station_id, "display_name": "Deine Industriestation", "type_id": "industrial_complex",
		"position": pos, "inventory": inventory,
		"trade_log": [], "is_player_owned": true,
		"system_id": current_system_id,
		"modules": ["smelter", "refinery", "synthesizer"],
		"processing_income": 0
	})
	show_toast("Eigene Station in " + str(SYSTEMS[current_system_id]["display_name"]) + " gebaut!", 3.5)


func get_station_by_id(station_id: String) -> Dictionary:
	for station in stations:
		if str(station["id"]) == station_id:
			return station
	return {}


func get_dock_point(station: Dictionary) -> Vector2:
	var pos: Vector2 = station["position"]
	return pos + Vector2(0.0, -26.0)


# ─── Starfield generation ─────────────────────────────────────────────────────

func generate_all_starfields() -> void:
	for sys_id in SYSTEMS.keys():
		generate_starfield_for_system(sys_id)


func generate_starfield_for_system(sys_id: String) -> void:
	var sys: Dictionary = SYSTEMS[sys_id]
	var sfx_rng := RandomNumberGenerator.new()
	sfx_rng.seed = DEFAULT_RNG_SEED + hash(sys_id)
	var vp: Vector2 = get_viewport_rect().size
	var r_base: float = float(sys["star_r_base"])
	var g_base: float = float(sys["star_g_base"])
	var b_base: float = float(sys["star_b_base"])
	var star_list: Array = []
	for i in range(STARFIELD_COUNT):
		var sr: float = clampf(r_base + sfx_rng.randf_range(-0.22, 0.22), 0.0, 1.0)
		var sg: float = clampf(g_base + sfx_rng.randf_range(-0.22, 0.22), 0.0, 1.0)
		var sb: float = clampf(b_base + sfx_rng.randf_range(-0.22, 0.22), 0.0, 1.0)
		var sa: float = sfx_rng.randf_range(0.28, 0.92)
		var star_size: float = sfx_rng.randf_range(0.8, 2.5)
		var twinkle_speed: float = sfx_rng.randf_range(0.6, 2.8)
		var twinkle_offset: float = sfx_rng.randf_range(0.0, TAU)
		star_list.append({
			"pos": Vector2(sfx_rng.randf_range(0.0, vp.x), sfx_rng.randf_range(0.0, vp.y)),
			"color": Color(sr, sg, sb, sa),
			"size": star_size,
			"twinkle_speed": twinkle_speed,
			"twinkle_offset": twinkle_offset
		})
	all_stars[sys_id] = star_list


# ─── Player Movement & System Transition ──────────────────────────────────────

func handle_movement(delta: float) -> void:
	var vp: Rect2 = get_viewport_rect()
	var input_vec := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vec.x += 1.0
	if Input.is_action_pressed("move_left"):
		input_vec.x -= 1.0
	if Input.is_action_pressed("move_down"):
		input_vec.y += 1.0
	if Input.is_action_pressed("move_up"):
		input_vec.y -= 1.0

	var boosting: bool = Input.is_action_pressed("boost")
	var max_speed: float = BASE_MAX_SPEED * (BOOST_MULTIPLIER if boosting else 1.0)

	if input_vec.length_squared() > 0.0:
		input_vec = input_vec.normalized()
		player_velocity += input_vec * ACCELERATION * delta
		if player_velocity.length() > max_speed:
			player_velocity = player_velocity.normalized() * max_speed
		player_rotation = lerp_angle(player_rotation, atan2(input_vec.y, input_vec.x), 12.0 * delta)
	else:
		player_velocity = player_velocity.move_toward(Vector2.ZERO, DRAG * delta)

	player_position += player_velocity * delta

	# Check for map edge transitions
	var sys: Dictionary = SYSTEMS[current_system_id]
	var neighbors: Dictionary = sys["neighbors"]
	var margin: float = TRANSIT_ZONE

	if player_position.y < margin and str(neighbors["north"]) != "":
		_start_system_transition("north", str(neighbors["north"]))
		return
	if player_position.x > vp.size.x - margin and str(neighbors["east"]) != "":
		_start_system_transition("east", str(neighbors["east"]))
		return
	if player_position.y > vp.size.y - margin and str(neighbors["south"]) != "":
		_start_system_transition("south", str(neighbors["south"]))
		return
	if player_position.x < margin and str(neighbors["west"]) != "":
		_start_system_transition("west", str(neighbors["west"]))
		return

	# Clamp to viewport (no neighbor in that direction)
	player_position.x = clampf(player_position.x, 4.0, vp.size.x - 4.0)
	player_position.y = clampf(player_position.y, 4.0, vp.size.y - 4.0)


func _start_system_transition(direction: String, dest_system: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	transition_direction = direction
	transition_dest_system = dest_system
	transition_progress = 0.0
	transition_switched = false
	player_velocity = Vector2.ZERO


func update_system_transition(delta: float) -> void:
	if not is_transitioning:
		return

	transition_progress += delta / TRANSITION_DURATION

	if transition_progress >= 0.5 and not transition_switched:
		transition_switched = true
		current_system_id = transition_dest_system
		var vp: Rect2 = get_viewport_rect()
		match transition_direction:
			"north":
				player_position = Vector2(player_position.x, vp.size.y - TRANSIT_ZONE - 10.0)
			"south":
				player_position = Vector2(player_position.x, TRANSIT_ZONE + 10.0)
			"east":
				player_position = Vector2(TRANSIT_ZONE + 10.0, player_position.y)
			"west":
				player_position = Vector2(vp.size.x - TRANSIT_ZONE - 10.0, player_position.y)

	if transition_progress >= 1.0:
		is_transitioning = false
		transition_progress = 0.0
		transition_direction = ""
		var sys_name: String = str(SYSTEMS[current_system_id]["display_name"])
		status = "Willkommen im Sternensystem " + sys_name + "!"
		show_toast("Eingeflogen: " + sys_name, 2.5)
		generate_starfield_for_system(current_system_id)


func draw_transition_overlay() -> void:
	var vp: Rect2 = get_viewport_rect()
	var p: float = clampf(transition_progress, 0.0, 1.0)
	var alpha: float = 0.0
	if p < 0.5:
		alpha = p * 2.0
	else:
		alpha = (1.0 - p) * 2.0
	draw_rect(vp, Color(0.0, 0.0, 0.0, alpha))


# ─── Docking ──────────────────────────────────────────────────────────────────

func update_docking(delta: float) -> void:
	var dock_held: bool = Input.is_action_pressed("dock")
	var nearest: Dictionary = find_nearest_station_in_system()
	if nearest.is_empty():
		docking_progress = 0.0
		was_dock_held = false
		return

	var dist: float = player_position.distance_to(nearest["position"])
	if dist > DOCK_RANGE:
		docking_progress = 0.0
		was_dock_held = false
		return

	if dock_held:
		docking_progress += delta
		if not was_dock_held:
			status = "Halte C gedrückt um anzudocken..."
		if docking_progress >= DOCK_HOLD_TIME:
			complete_docking(nearest)
	else:
		docking_progress = 0.0
		was_dock_held = false

	was_dock_held = dock_held


func complete_docking(station: Dictionary) -> void:
	is_docked = true
	docking_station = station
	docking_progress = 0.0
	was_dock_held = false
	ensure_resource_selected()
	var sname: String = str(station["display_name"])
	var stype: String = str(STATION_TYPES[str(station["type_id"])]["display_name"])
	status = "Angedockt: " + sname + " (" + stype + ")"
	show_toast("Angedockt: " + sname, 1.8)


func find_nearest_station_in_system() -> Dictionary:
	var best: Dictionary = {}
	var best_dist := INF
	for station in stations:
		if str(station["system_id"]) != current_system_id:
			continue
		var d: float = player_position.distance_to(station["position"])
		if d < best_dist:
			best_dist = d
			best = station
	return best


# ─── Economy tick ─────────────────────────────────────────────────────────────

func tick_economy() -> void:
	for station in stations:
		var stype: Dictionary = STATION_TYPES[str(station["type_id"])]
		var inv: Dictionary = station["inventory"]
		var stacks: Dictionary = inv["stacks"]
		var cap: int = int(inv["capacity"])

		# Production
		var prod: Dictionary = stype["production"]
		for rid in prod.keys():
			var amt: int = int(prod[rid])
			stacks[rid] = mini(stacks.get(rid, 0) + amt, cap)

		# Consumption
		var cons: Dictionary = stype["consumption"]
		for rid in cons.keys():
			var amt: int = int(cons[rid])
			var have: int = stacks.get(rid, 0)
			stacks[rid] = maxi(0, have - amt)

		# Gentle mean-reversion to target stock
		var target_stock: Dictionary = stype["target_stock"]
		for rid in RESOURCE_IDS:
			if target_stock.has(rid):
				var tgt: int = int(target_stock[rid])
				var cur: int = stacks.get(rid, 0)
				if cur < tgt and cur < cap:
					stacks[rid] = cur + 1
				elif cur > tgt + 12:
					stacks[rid] = cur - 1


func compute_price(station: Dictionary, resource_id: String, is_buy: bool) -> float:
	var res: Dictionary = RESOURCES[resource_id]
	var stype: Dictionary = STATION_TYPES[str(station["type_id"])]
	var base: float = float(res["base_price"])
	var inv: Dictionary = station["inventory"]
	var stacks: Dictionary = inv["stacks"]
	var cur: int = stacks.get(resource_id, 0)
	var target_stock: Dictionary = stype["target_stock"]
	var tgt: int = int(target_stock.get(resource_id, 10))
	var cap: int = int(inv["capacity"])

	var pressure := 0.0
	if tgt > 0:
		pressure = (float(tgt) - float(cur)) / float(tgt)
	pressure = clampf(pressure, PRESSURE_CLAMP_MIN, PRESSURE_CLAMP_MAX)

	var anchor_pos: Vector2 = Vector2(576.0, 324.0)
	var dist: float = station["position"].distance_to(anchor_pos)
	var dist_factor: float = dist * DISTANCE_PRICE_FACTOR

	var multiplier: float = 1.0 + pressure * PRESSURE_PRICE_FACTOR + dist_factor * 0.1
	multiplier = clampf(multiplier, MIN_PRICE_MULTIPLIER, MAX_PRICE_MULTIPLIER)

	var price: float = base * multiplier
	if is_buy:
		price *= BUY_MARKUP
	else:
		price *= SELL_MARKDOWN
	return maxf(1.0, price)


func compute_buy_price(station: Dictionary, resource_id: String) -> float:
	return compute_price(station, resource_id, true)


func compute_sell_price(station: Dictionary, resource_id: String) -> float:
	return compute_price(station, resource_id, false)


func get_stock_state_label(station: Dictionary, resource_id: String) -> String:
	var stype: Dictionary = STATION_TYPES[str(station["type_id"])]
	var inv: Dictionary = station["inventory"]
	var stacks: Dictionary = inv["stacks"]
	var cur: int = stacks.get(resource_id, 0)
	var target_stock: Dictionary = stype["target_stock"]
	var tgt: int = int(target_stock.get(resource_id, 10))
	var cap: int = int(inv["capacity"])
	if tgt <= 0:
		return ""
	var ratio: float = float(cur) / float(tgt)
	if cur == 0:
		return "Leer"
	elif ratio < VERY_HIGH_DEMAND_RATIO:
		return "Sehr hoch"
	elif ratio < LOW_STOCK_RATIO:
		return "Hoch"
	elif ratio > OVERSTOCK_RATIO:
		return "Überbestand"
	return ""


func get_stock_state_color(label: String) -> Color:
	match label:
		"Leer", "Sehr hoch":
			return BAD_COLOR
		"Hoch":
			return Color(1.0, 0.78, 0.2)
		"Überbestand":
			return GOOD_COLOR
		_:
			return Color(1.0, 1.0, 1.0, 0.0)


# ─── NPC Trading + Inter-system travel ────────────────────────────────────────

func run_npc_trades() -> void:
	for npc in npcs:
		var state: String = str(npc["state"])

		# Inter-system travel timer
		if state == "traveling_intersystem":
			var timer: float = float(npc["intersystem_travel_timer"])
			timer -= NPC_TICK
			if timer <= 0.0:
				npc["state"] = "idle"
				npc["intersystem_travel_timer"] = 0.0
				npc["system_id"] = str(npc["dest_system_id"])
				npc["anchor_station_id"] = get_random_station_in_system(str(npc["system_id"]))
				npc["dest_system_id"] = ""
			else:
				npc["intersystem_travel_timer"] = timer
			continue

		# Skip NPCs not in current system (not visible; they still tick via intersystem logic)
		var npc_sys: String = str(npc["system_id"])

		if state == "idle":
			# Small chance to travel to neighboring system
			if rng.randf() < 0.02:
				var dest_sys: String = get_random_neighbor(npc_sys)
				if dest_sys != "":
					npc["state"] = "traveling_intersystem"
					npc["dest_system_id"] = dest_sys
					npc["intersystem_travel_timer"] = INTERSYSTEM_NPC_TRAVEL_TIME
					continue

			# Look for a processing route first (T1 -> T2 chain)
			var proc_route: Dictionary = find_npc_processing_route(npc_sys)
			if not proc_route.is_empty():
				var buy_id: String = str(proc_route["buy_station_id"])
				var buy_station: Dictionary = get_station_by_id(buy_id)
				if not buy_station.is_empty():
					npc["state"] = "traveling_to_buy"
					npc["dest_station_id"] = buy_id
					npc["_proc_route"] = proc_route
					set_npc_visual_target(npc, buy_station["position"])
					continue

			# Standard buy-sell trade
			var route: Dictionary = find_npc_trade_route(npc_sys)
			if route.is_empty():
				continue
			var buy_id: String = str(route["buy_station_id"])
			var buy_station: Dictionary = get_station_by_id(buy_id)
			if buy_station.is_empty():
				continue
			npc["state"] = "traveling_to_buy"
			npc["dest_station_id"] = buy_id
			npc.erase("_proc_route")
			set_npc_visual_target(npc, buy_station["position"])

		elif state == "buying":
			if npc.has("_proc_route"):
				_npc_execute_buy_for_process(npc)
			else:
				_npc_execute_buy(npc)

		elif state == "traveling_to_process":
			var proc_sid: String = str(npc["_proc_station_id"])
			var proc_station: Dictionary = get_station_by_id(proc_sid)
			if not proc_station.is_empty():
				npc["state"] = "processing"
			else:
				npc["state"] = "idle"

		elif state == "processing":
			_npc_execute_process(npc)

		elif state == "selling":
			_npc_execute_sell(npc)


func _npc_execute_buy(npc: Dictionary) -> void:
	var route: Dictionary = find_npc_trade_route(str(npc["system_id"]))
	if route.is_empty():
		npc["state"] = "idle"
		return
	var buy_station: Dictionary = get_station_by_id(str(route["buy_station_id"]))
	var sell_station: Dictionary = get_station_by_id(str(route["sell_station_id"]))
	var rid: String = str(route["resource_id"])
	if buy_station.is_empty() or sell_station.is_empty():
		npc["state"] = "idle"
		return
	var buy_price: float = compute_buy_price(buy_station, rid)
	var npc_creds: float = float(npc["credits"])
	var npc_inv: Dictionary = npc["inventory"]
	var npc_stacks: Dictionary = npc_inv["stacks"]
	var npc_cap: int = int(npc_inv["capacity"])
	var have: int = npc_stacks.values().reduce(func(a, b): return a + b, 0)
	var avail: int = npc_cap - have
	var affords: int = int(npc_creds / maxf(buy_price, 0.01))
	var station_stock: int = buy_station["inventory"]["stacks"].get(rid, 0)
	var trade_ratio: float = rng.randf_range(NPC_MIN_TRADE_RATIO, NPC_MAX_TRADE_RATIO)
	var qty: int = maxi(1, mini(int(float(station_stock) * trade_ratio), mini(avail, affords)))
	if qty <= 0 or station_stock <= 0:
		npc["state"] = "idle"
		return
	var total_cost: float = float(qty) * buy_price
	buy_station["inventory"]["stacks"][rid] = station_stock - qty
	npc_stacks[rid] = npc_stacks.get(rid, 0) + qty
	npc["credits"] = npc_creds - total_cost
	npc["dest_station_id"] = str(route["sell_station_id"])
	npc["state"] = "traveling_to_sell"
	set_npc_visual_target(npc, sell_station["position"])


func _npc_execute_buy_for_process(npc: Dictionary) -> void:
	var proc_route: Dictionary = npc["_proc_route"]
	var buy_id: String = str(proc_route["buy_station_id"])
	var proc_sid: String = str(proc_route["proc_station_id"])
	var mod_id: String = str(proc_route["module_id"])
	var rid: String = str(PROCESSING_MODULES[mod_id]["input"])
	var buy_station: Dictionary = get_station_by_id(buy_id)
	var proc_station: Dictionary = get_station_by_id(proc_sid)
	if buy_station.is_empty() or proc_station.is_empty():
		npc["state"] = "idle"
		npc.erase("_proc_route")
		return
	var buy_price: float = compute_buy_price(buy_station, rid)
	var npc_creds: float = float(npc["credits"])
	var npc_inv: Dictionary = npc["inventory"]
	var npc_stacks: Dictionary = npc_inv["stacks"]
	var npc_cap: int = int(npc_inv["capacity"])
	var have: int = npc_stacks.values().reduce(func(a, b): return a + b, 0)
	var avail: int = npc_cap - have
	var affords: int = int(npc_creds / maxf(buy_price, 0.01))
	var ratio: int = int(PROCESSING_MODULES[mod_id]["ratio"])
	var batches: int = maxi(1, mini(avail / ratio, affords / ratio))
	var qty: int = batches * ratio
	var station_stock: int = buy_station["inventory"]["stacks"].get(rid, 0)
	if qty <= 0 or station_stock < ratio:
		npc["state"] = "idle"
		npc.erase("_proc_route")
		return
	qty = mini(qty, station_stock)
	batches = qty / ratio
	if batches <= 0:
		npc["state"] = "idle"
		npc.erase("_proc_route")
		return
	var total_cost: float = float(qty) * buy_price
	buy_station["inventory"]["stacks"][rid] = station_stock - qty
	npc_stacks[rid] = npc_stacks.get(rid, 0) + qty
	npc["credits"] = npc_creds - total_cost
	npc["_proc_station_id"] = proc_sid
	npc["state"] = "traveling_to_process"
	set_npc_visual_target(npc, proc_station["position"])


func _npc_execute_process(npc: Dictionary) -> void:
	var proc_route: Dictionary = npc["_proc_route"]
	var mod_id: String = str(proc_route["module_id"])
	var sell_id: String = str(proc_route["sell_station_id"])
	var proc_sid: String = str(npc["_proc_station_id"])
	var proc_station: Dictionary = get_station_by_id(proc_sid)
	var pmod: Dictionary = PROCESSING_MODULES[mod_id]
	var input_rid: String = str(pmod["input"])
	var output_rid: String = str(pmod["output"])
	var ratio: int = int(pmod["ratio"])
	var fee: int = int(pmod["fee"])
	var npc_stacks: Dictionary = npc["inventory"]["stacks"]
	var have: int = npc_stacks.get(input_rid, 0)
	var batches: int = have / ratio
	if batches <= 0:
		npc["state"] = "idle"
		npc.erase("_proc_route")
		npc.erase("_proc_station_id")
		return
	var total_fee: float = float(batches) * float(fee)
	npc_stacks[input_rid] = have - batches * ratio
	npc_stacks[output_rid] = npc_stacks.get(output_rid, 0) + batches
	npc["credits"] = float(npc["credits"]) - total_fee
	if not proc_station.is_empty():
		proc_station["processing_income"] = int(proc_station["processing_income"]) + int(total_fee)
	npc.erase("_proc_route")
	npc.erase("_proc_station_id")
	npc["dest_station_id"] = sell_id
	var sell_station: Dictionary = get_station_by_id(sell_id)
	if not sell_station.is_empty():
		npc["state"] = "traveling_to_sell"
		set_npc_visual_target(npc, sell_station["position"])
	else:
		npc["state"] = "idle"


func _npc_execute_sell(npc: Dictionary) -> void:
	var npc_stacks: Dictionary = npc["inventory"]["stacks"]
	var sell_station: Dictionary = get_station_by_id(str(npc["dest_station_id"]))
	if sell_station.is_empty():
		npc["state"] = "idle"
		return
	var station_stacks: Dictionary = sell_station["inventory"]["stacks"]
	var station_cap: int = int(sell_station["inventory"]["capacity"])
	var sold_any := false
	for rid in npc_stacks.keys():
		var qty: int = int(npc_stacks[rid])
		if qty <= 0:
			continue
		var have_station: int = station_stacks.get(rid, 0)
		if have_station >= station_cap:
			continue
		var sell_price: float = compute_sell_price(sell_station, rid)
		var room: int = station_cap - have_station
		var sell_qty: int = mini(qty, room)
		station_stacks[rid] = have_station + sell_qty
		npc_stacks[rid] = qty - sell_qty
		npc["credits"] = float(npc["credits"]) + float(sell_qty) * sell_price
		sold_any = true
	npc["state"] = "idle"
	npc["dest_station_id"] = ""
	if not sold_any:
		return
	npc["anchor_station_id"] = str(sell_station["id"])


func find_npc_trade_route(sys_id: String) -> Dictionary:
	var best: Dictionary = {}
	var best_profit := -INF
	var local_stations: Array = []
	for s in stations:
		if str(s["system_id"]) == sys_id:
			local_stations.append(s)
	for buy_s in local_stations:
		for sell_s in local_stations:
			if str(buy_s["id"]) == str(sell_s["id"]):
				continue
			for rid in RESOURCE_IDS:
				var buy_stock: int = buy_s["inventory"]["stacks"].get(rid, 0)
				if buy_stock < 2:
					continue
				var buy_p: float = compute_buy_price(buy_s, rid)
				var sell_p: float = compute_sell_price(sell_s, rid)
				var profit: float = sell_p - buy_p
				if profit > best_profit:
					best_profit = profit
					best = {"buy_station_id": str(buy_s["id"]), "sell_station_id": str(sell_s["id"]), "resource_id": rid}
	return best


func find_npc_processing_route(sys_id: String) -> Dictionary:
	var best: Dictionary = {}
	var best_profit := -INF
	var local_stations: Array = []
	for s in stations:
		if str(s["system_id"]) == sys_id:
			local_stations.append(s)
	for buy_s in local_stations:
		for proc_s in local_stations:
			var proc_modules: Array = proc_s["modules"]
			for mod_id in proc_modules:
				var pmod: Dictionary = PROCESSING_MODULES[mod_id]
				var input_rid: String = str(pmod["input"])
				var output_rid: String = str(pmod["output"])
				var ratio: int = int(pmod["ratio"])
				var fee: float = float(pmod["fee"])
				var buy_stock: int = buy_s["inventory"]["stacks"].get(input_rid, 0)
				if buy_stock < ratio:
					continue
				var buy_p: float = compute_buy_price(buy_s, input_rid) * float(ratio)
				var out_base: float = float(RESOURCES[output_rid]["base_price"])
				var profit: float = out_base - buy_p - fee
				if profit > best_profit:
					for sell_s in local_stations:
						if str(sell_s["id"]) == str(proc_s["id"]):
							continue
						var sell_p: float = compute_sell_price(sell_s, output_rid)
						var route_profit: float = sell_p - buy_p - fee
						if route_profit > best_profit:
							best_profit = route_profit
							best = {
								"buy_station_id": str(buy_s["id"]),
								"proc_station_id": str(proc_s["id"]),
								"sell_station_id": str(sell_s["id"]),
								"module_id": mod_id
							}
	return best


func get_random_neighbor(sys_id: String) -> String:
	if not SYSTEMS.has(sys_id):
		return ""
	var nbrs: Dictionary = SYSTEMS[sys_id]["neighbors"]
	var valid_dirs: Array = []
	for dir in nbrs.keys():
		if str(nbrs[dir]) != "":
			valid_dirs.append(dir)
	if valid_dirs.is_empty():
		return ""
	var chosen_dir: String = str(valid_dirs[rng.randi() % valid_dirs.size()])
	return str(nbrs[chosen_dir])


func get_random_station_in_system(sys_id: String) -> String:
	var ids: Array = []
	for s in stations:
		if str(s["system_id"]) == sys_id:
			ids.append(str(s["id"]))
	if ids.is_empty():
		return ""
	return str(ids[rng.randi() % ids.size()])


# NPC visual movement
func set_npc_visual_target(npc: Dictionary, target: Vector2) -> void:
	npc["target_position"] = target
	npc["travel_progress"] = 0.0
	var dur: float = rng.randf_range(NPC_VISUAL_MIN_TRAVEL, NPC_VISUAL_MAX_TRAVEL)
	npc["travel_duration"] = dur


func update_npc_visuals(delta: float) -> void:
	for npc in npcs:
		var state: String = str(npc["state"])
		if state == "traveling_intersystem":
			continue
		if state in ["traveling_to_buy", "traveling_to_sell", "traveling_to_process"]:
			var prog: float = float(npc["travel_progress"])
			var dur: float = float(npc["travel_duration"])
			prog = minf(prog + delta / maxf(dur, 0.01), 1.0)
			npc["travel_progress"] = prog
			var start_pos: Vector2 = npc["visual_position"]
			var target_pos: Vector2 = npc["target_position"]
			npc["visual_position"] = start_pos.lerp(target_pos, prog)
			if prog >= 1.0:
				npc["visual_position"] = target_pos
				match state:
					"traveling_to_buy":
						npc["state"] = "buying"
					"traveling_to_sell":
						npc["state"] = "selling"
					"traveling_to_process":
						npc["state"] = "processing"
		else:
			var anchor_id: String = str(npc["anchor_station_id"])
			var anchor_st: Dictionary = get_station_by_id(anchor_id)
			if anchor_st.is_empty():
				continue
			var t: float = visual_time * NPC_IDLE_SPEED + float(npc["id"].hash()) * 0.37
			var idle_r: float = NPC_IDLE_RADIUS + sin(t * NPC_IDLE_SWAY_RATIO) * 2.0
			var angle: float = t
			npc["visual_position"] = anchor_st["position"] + Vector2(cos(angle) * idle_r, sin(angle) * idle_r)


# ─── Player Trade + Processing ────────────────────────────────────────────────

func attempt_buy(resource_id: String, qty: int) -> void:
	if not is_docked or docking_station.is_empty():
		return
	var station: Dictionary = docking_station
	var stacks: Dictionary = station["inventory"]["stacks"]
	var stock: int = stacks.get(resource_id, 0)
	if stock <= 0:
		show_toast("Kein Bestand in dieser Station.", 2.0)
		last_trade_failed = true
		return
	var actual_qty: int = mini(qty, stock)
	var inv: Dictionary = player_agent["inventory"]
	var pstacks: Dictionary = inv["stacks"]
	var used: int = pstacks.values().reduce(func(a, b): return a + b, 0)
	var room: int = int(inv["capacity"]) - used
	actual_qty = mini(actual_qty, room)
	if actual_qty <= 0:
		show_toast("Frachtraum voll!", 2.0)
		last_trade_failed = true
		return
	var price: float = compute_buy_price(station, resource_id) * float(actual_qty)
	if float(player_agent["credits"]) < price:
		show_toast("Nicht genug Credits!", 2.0)
		last_trade_failed = true
		return
	stacks[resource_id] = stock - actual_qty
	pstacks[resource_id] = pstacks.get(resource_id, 0) + actual_qty
	player_agent["credits"] = float(player_agent["credits"]) - price
	avg_buy_price[resource_id] = price / float(actual_qty)
	var log_entry: String = "Gekauft: " + str(actual_qty) + "× " + str(RESOURCES[resource_id]["display_name"]) + " für " + str(int(price)) + " Cr"
	add_trade_log(log_entry)
	show_toast(log_entry, 1.6)
	last_trade_failed = false


func attempt_sell(resource_id: String, qty: int) -> void:
	if not is_docked or docking_station.is_empty():
		return
	var inv: Dictionary = player_agent["inventory"]
	var pstacks: Dictionary = inv["stacks"]
	var have: int = pstacks.get(resource_id, 0)
	if have <= 0:
		show_toast("Nicht im Inventar.", 2.0)
		last_trade_failed = true
		return
	var station: Dictionary = docking_station
	var sname: String = str(station["display_name"])
	var actual_qty: int = mini(qty, have)
	var station_stacks: Dictionary = station["inventory"]["stacks"]
	var station_cap: int = int(station["inventory"]["capacity"])
	var station_have: int = station_stacks.get(resource_id, 0)
	if station_have >= station_cap:
		show_toast("Station voll! Kann nicht kaufen.", 2.0)
		last_trade_failed = true
		return
	var room: int = station_cap - station_have
	actual_qty = mini(actual_qty, room)
	if actual_qty <= 0:
		show_toast("Station kann nicht mehr aufnehmen.", 2.0)
		last_trade_failed = true
		return
	var price: float = compute_sell_price(station, resource_id) * float(actual_qty)
	pstacks[resource_id] = have - actual_qty
	station_stacks[resource_id] = station_have + actual_qty
	player_agent["credits"] = float(player_agent["credits"]) + price
	var log_entry: String = "Verkauft: " + str(actual_qty) + "× " + str(RESOURCES[resource_id]["display_name"]) + " für " + str(int(price)) + " Cr"
	add_trade_log(log_entry)
	show_toast(log_entry, 1.6)
	last_trade_failed = false


func attempt_sell_all() -> void:
	if not is_docked or docking_station.is_empty():
		return
	var pstacks: Dictionary = player_agent["inventory"]["stacks"]
	var any_sold := false
	for rid in RESOURCE_IDS:
		var have: int = pstacks.get(rid, 0)
		if have > 0:
			attempt_sell(rid, have)
			any_sold = true
	if not any_sold:
		show_toast("Kein Inventar zu verkaufen.", 2.0)


func attempt_process(mod_id: String) -> void:
	if not is_docked or docking_station.is_empty():
		return
	var station: Dictionary = docking_station
	var station_modules: Array = station["modules"]
	if not (mod_id in station_modules):
		show_toast("Modul nicht verfügbar.", 2.0)
		return
	var pmod: Dictionary = PROCESSING_MODULES[mod_id]
	var input_rid: String = str(pmod["input"])
	var output_rid: String = str(pmod["output"])
	var ratio: int = int(pmod["ratio"])
	var fee: float = float(pmod["fee"])
	var pstacks: Dictionary = player_agent["inventory"]["stacks"]
	var have: int = pstacks.get(input_rid, 0)
	var batches: int = have / ratio
	if batches <= 0:
		show_toast("Nicht genug " + str(RESOURCES[input_rid]["display_name"]) + " für Verarbeitung.", 2.2)
		return
	var total_fee: float = float(batches) * fee
	var is_own: bool = bool(station["is_player_owned"])
	if not is_own and float(player_agent["credits"]) < total_fee:
		show_toast("Nicht genug Credits für Gebühr (" + str(int(total_fee)) + " Cr).", 2.2)
		return
	var inv: Dictionary = player_agent["inventory"]
	var pst2: Dictionary = inv["stacks"]
	var used: int = pst2.values().reduce(func(a, b): return a + b, 0)
	var room: int = int(inv["capacity"]) - used + have - (batches * ratio)
	if room < batches:
		show_toast("Frachtraum zu voll für Ausgabe.", 2.2)
		return
	pst2[input_rid] = have - batches * ratio
	pst2[output_rid] = pst2.get(output_rid, 0) + batches
	player_agent["credits"] = float(player_agent["credits"]) - total_fee
	if not is_own:
		station["processing_income"] = int(station["processing_income"]) + int(total_fee)
	var log_msg: String = "Verarbeitet: " + str(batches * ratio) + "× " + str(RESOURCES[input_rid]["display_name"]) + " → " + str(batches) + "× " + str(RESOURCES[output_rid]["display_name"]) + " (Gebühr: " + str(int(total_fee)) + " Cr)"
	add_trade_log(log_msg)
	show_toast(log_msg, 2.5)


# ─── Sorted inventory for trade panel ─────────────────────────────────────────

func get_sorted_rows(station: Dictionary) -> Array:
	var rows: Array = []
	var pstacks: Dictionary = player_agent["inventory"]["stacks"]
	var station_stacks: Dictionary = station["inventory"]["stacks"]
	for rid in RESOURCE_IDS:
		var res: Dictionary = RESOURCES[rid]
		var display_name: String = str(res["display_name"])
		if search.length() > 0 and not display_name.to_lower().contains(search):
			continue
		var player_amt: int = pstacks.get(rid, 0)
		var station_amt: int = station_stacks.get(rid, 0)
		var buy_p: float = compute_buy_price(station, rid)
		var sell_p: float = compute_sell_price(station, rid)
		var val: float = float(player_amt) * sell_p
		var tier: int = int(res["tier"])
		rows.append({
			"id": rid, "name": display_name, "tier": tier,
			"amount": player_amt, "station_amount": station_amt,
			"buy_price": buy_p, "sell_price": sell_p,
			"value": val, "unit_price": sell_p
		})
	rows.sort_custom(func(a, b):
		var a_value = a[sort_key]
		var b_value = b[sort_key]
		if typeof(a_value) == TYPE_STRING:
			return (a_value < b_value) if sort_ascending else (a_value > b_value)
		return (float(a_value) < float(b_value)) if sort_ascending else (float(a_value) > float(b_value))
	)
	return rows


# ─── HUD + Toast ──────────────────────────────────────────────────────────────

func update_hud() -> void:
	var inv: Dictionary = player_agent["inventory"]
	var pstacks: Dictionary = inv["stacks"]
	var used: int = pstacks.values().reduce(func(a, b): return a + b, 0)
	var cap: int = int(inv["capacity"])
	var creds: int = int(player_agent["credits"])
	var sys_name: String = str(SYSTEMS[current_system_id]["display_name"])
	hud_label.text = "Credits: %d Cr   Fracht: %d/%d   System: %s" % [creds, used, cap, sys_name]
	status_label.text = status


func add_trade_log(entry: String) -> void:
	trade_log.append(entry)
	if trade_log.size() > MAX_TRADE_LOG:
		trade_log.pop_front()


func show_toast(text: String, duration: float) -> void:
	toast_text = text
	toast_timer = duration


func draw_toast() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var font: Font = ThemeDB.fallback_font
	var fsize := 16
	var w: float = font.get_string_size(toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x + 28.0
	var h := 32.0
	var tx: float = (vp.x - w) * 0.5
	var ty: float = vp.y * 0.82
	var bg_rect := Rect2(tx - 4.0, ty - 4.0, w + 8.0, h + 8.0)
	draw_rect(bg_rect, TOAST_BG_COLOR)
	draw_rect(bg_rect, TOAST_BORDER_COLOR, false, 1.3)
	draw_string(font, Vector2(tx, ty + float(fsize)), toast_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color.WHITE)


func reset_run() -> void:
	rng.seed = DEFAULT_RNG_SEED
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string("{}")
		file.close()
	setup_defaults()
	all_stars.clear()
	generate_all_starfields()
	status = DEFAULT_STATUS
	show_toast("Run zurückgesetzt!", 2.5)


func ensure_resource_selected() -> void:
	if not RESOURCES.has(selected_resource_id):
		selected_resource_id = RESOURCE_IDS[0]


func cycle_sort() -> void:
	var idx: int = SORT_KEYS.find(sort_key)
	idx = (idx + 1) % SORT_KEYS.size()
	sort_key = str(SORT_KEYS[idx])


# ─── Drawing ──────────────────────────────────────────────────────────────────

func draw_background() -> void:
	var vp: Rect2 = get_viewport_rect()
	var sys: Dictionary = SYSTEMS[current_system_id]
	var bg: Color = sys["bg_color"]
	draw_rect(vp, bg)

	# Draw nebula clouds
	var neb1_ratio: Vector2 = sys["nebula1_pos_ratio"]
	var neb1_pos: Vector2 = Vector2(vp.size.x * float(neb1_ratio.x), vp.size.y * float(neb1_ratio.y))
	var neb1_r: float = float(sys["nebula1_radius"])
	var neb1_col: Color = sys["nebula1_color"]
	draw_circle(neb1_pos, neb1_r, neb1_col)

	var neb2_ratio: Vector2 = sys["nebula2_pos_ratio"]
	var neb2_pos: Vector2 = Vector2(vp.size.x * float(neb2_ratio.x), vp.size.y * float(neb2_ratio.y))
	var neb2_r: float = float(sys["nebula2_radius"])
	var neb2_col: Color = sys["nebula2_color"]
	draw_circle(neb2_pos, neb2_r, neb2_col)

	# Draw starfield
	if all_stars.has(current_system_id):
		var star_list: Array = all_stars[current_system_id]
		for star in star_list:
			var twinkle: float = sin(visual_time * float(star["twinkle_speed"]) + float(star["twinkle_offset"])) * 0.18
			var col: Color = star["color"]
			col.a = clampf(col.a + twinkle, 0.1, 1.0)
			draw_circle(star["pos"], float(star["size"]), col)

	# Draw transit zone arrows
	draw_transit_arrows(vp)


func draw_transit_arrows(vp: Rect2) -> void:
	var sys: Dictionary = SYSTEMS[current_system_id]
	var nbrs: Dictionary = sys["neighbors"]
	var accent: Color = sys["accent_color"]
	var font: Font = ThemeDB.fallback_font
	var fsize := 11

	# North arrow
	if str(nbrs["north"]) != "":
		var dest_name: String = str(SYSTEMS[str(nbrs["north"])]["display_name"])
		var arrow_pts: PackedVector2Array = PackedVector2Array([
			Vector2(vp.size.x * 0.5 - 7.0, 16.0),
			Vector2(vp.size.x * 0.5 + 7.0, 16.0),
			Vector2(vp.size.x * 0.5, 5.0)
		])
		draw_colored_polygon(arrow_pts, accent)
		draw_string(font, Vector2(vp.size.x * 0.5 - 40.0, 30.0), dest_name, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, accent)

	# East arrow
	if str(nbrs["east"]) != "":
		var dest_name: String = str(SYSTEMS[str(nbrs["east"])]["display_name"])
		var arrow_pts: PackedVector2Array = PackedVector2Array([
			Vector2(vp.size.x - 16.0, vp.size.y * 0.5 - 7.0),
			Vector2(vp.size.x - 16.0, vp.size.y * 0.5 + 7.0),
			Vector2(vp.size.x - 5.0, vp.size.y * 0.5)
		])
		draw_colored_polygon(arrow_pts, accent)
		draw_string(font, Vector2(vp.size.x - 110.0, vp.size.y * 0.5 - 10.0), dest_name, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, accent)

	# South arrow
	if str(nbrs["south"]) != "":
		var dest_name: String = str(SYSTEMS[str(nbrs["south"])]["display_name"])
		var arrow_pts: PackedVector2Array = PackedVector2Array([
			Vector2(vp.size.x * 0.5 - 7.0, vp.size.y - 16.0),
			Vector2(vp.size.x * 0.5 + 7.0, vp.size.y - 16.0),
			Vector2(vp.size.x * 0.5, vp.size.y - 5.0)
		])
		draw_colored_polygon(arrow_pts, accent)
		draw_string(font, Vector2(vp.size.x * 0.5 - 40.0, vp.size.y - 32.0), dest_name, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, accent)

	# West arrow
	if str(nbrs["west"]) != "":
		var dest_name: String = str(SYSTEMS[str(nbrs["west"])]["display_name"])
		var arrow_pts: PackedVector2Array = PackedVector2Array([
			Vector2(16.0, vp.size.y * 0.5 - 7.0),
			Vector2(16.0, vp.size.y * 0.5 + 7.0),
			Vector2(5.0, vp.size.y * 0.5)
		])
		draw_colored_polygon(arrow_pts, accent)
		draw_string(font, Vector2(22.0, vp.size.y * 0.5 + 6.0), dest_name, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, accent)


func draw_station_node(station: Dictionary, idx: int) -> void:
	var pos: Vector2 = station["position"]
	var col: Color = STATION_COLOR
	if bool(station["is_player_owned"]):
		col = Color(0.45, 1.0, 0.55)
	var near: bool = player_position.distance_to(pos) < DOCK_RANGE
	if near:
		draw_circle(pos, 28.0, Color(col.r, col.g, col.b, 0.12))
		draw_circle(pos, 28.0, Color(col.r, col.g, col.b, 0.5), false, 1.5)

	# Station body
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		var a: float = float(i) / 6.0 * TAU - PI / 6.0
		pts.append(pos + Vector2(cos(a) * 14.0, sin(a) * 14.0))
	draw_colored_polygon(pts, Color(col.r * 0.4, col.g * 0.4, col.b * 0.4))
	draw_polyline(pts + PackedVector2Array([pts[0]]), col, 1.6)

	# Dock indicator
	if near and not is_docked:
		var prog: float = docking_progress / DOCK_HOLD_TIME
		draw_arc(pos, 20.0, -PI * 0.5, -PI * 0.5 + prog * TAU, 24, Color(0.35, 1.0, 0.55, 0.82), 2.5)

	var font: Font = ThemeDB.fallback_font
	var fsize := 12
	var sname: String = str(station["display_name"])
	var stype_name: String = str(STATION_TYPES[str(station["type_id"])]["display_name"])
	draw_string(font, pos + Vector2(-40.0, 26.0), sname, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, col)
	draw_string(font, pos + Vector2(-40.0, 40.0), stype_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(col.r, col.g, col.b, 0.72))

	# Module badges
	var station_modules: Array = station["modules"]
	for mi in range(station_modules.size()):
		var mid: String = str(station_modules[mi])
		var pmod: Dictionary = PROCESSING_MODULES[mid]
		var badge_text: String = str(pmod["display_name"])[0]
		var badge_pos: Vector2 = pos + Vector2(-14.0 + float(mi) * 18.0, 52.0)
		draw_circle(badge_pos, 7.0, PROCESS_BUTTON_COLOR)
		draw_string(font, badge_pos + Vector2(-3.5, 5.0), badge_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)

	# Processing income indicator for player-owned station
	if bool(station["is_player_owned"]):
		var income: int = int(station["processing_income"])
		if income > 0:
			draw_string(font, pos + Vector2(-20.0, 66.0), "Geb: " + str(income) + " Cr", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CREDIT_COLOR)


func draw_npc_markers() -> void:
	var font: Font = ThemeDB.fallback_font
	for npc in npcs:
		if str(npc["system_id"]) != current_system_id:
			continue
		if str(npc["state"]) == "traveling_intersystem":
			continue
		var vpos: Vector2 = npc["visual_position"]
		var npc_id: String = str(npc["id"])
		var is_hovered: bool = npc_id == hovered_npc_id
		var is_hailing: bool = npc_id == npc_hail_target_id and npc_hail_progress > 0.0
		var dot_color: Color = Color(1.0, 1.0, 0.55, 1.0) if is_hovered else NPC_MARKER_COLOR
		draw_circle(vpos, 3.2, dot_color)

		# Hailing progress arc
		if is_hailing:
			var hail_prog: float = npc_hail_progress / NPC_HAIL_HOLD_TIME
			draw_arc(vpos, 12.0, -PI * 0.5, -PI * 0.5 + hail_prog * TAU, 24, NPC_HAIL_COLOR, 2.5)

		# "X halten" hint when player is near and not already hailing or in menu
		if not is_npc_menu_open and not is_hailing:
			var dist: float = player_position.distance_to(vpos)
			if dist < NPC_INTERACT_RANGE:
				draw_string(font, vpos + Vector2(-18.0, -10.0), "X halten", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.72, 0.95, 0.45, 0.7))

	if hovered_npc_id == "":
		return
	var tooltip_npc: Dictionary = {}
	for npc in npcs:
		if str(npc["id"]) == hovered_npc_id:
			tooltip_npc = npc
			break
	if tooltip_npc.is_empty():
		return
	_draw_npc_tooltip(tooltip_npc)


func _draw_npc_tooltip(npc: Dictionary) -> void:
	var font: Font = ThemeDB.fallback_font
	var vp: Vector2 = get_viewport_rect().size
	var vpos: Vector2 = npc["visual_position"]

	var ship_name: String = str(npc.get("ship_name", "Unbekannt"))
	var faction: String = str(npc.get("faction", "Fraktionslos"))

	# Build cargo lines
	var cargo_lines: Array = []
	var npc_inv: Dictionary = npc["inventory"]
	var stacks: Dictionary = npc_inv["stacks"]
	if stacks.is_empty():
		cargo_lines.append("Leer")
	else:
		for rid in stacks.keys():
			var amt: int = int(stacks[rid])
			if amt > 0:
				var res_name: String = str(RESOURCES[rid]["display_name"])
				cargo_lines.append(res_name + ": " + str(amt))

	# Tooltip dimensions
	var line_h := 15
	var pad := 8
	var total_lines: int = 3 + cargo_lines.size()  # name + faction + "Fracht:" + cargo lines
	var tooltip_w := 160
	var tooltip_h: int = pad * 2 + total_lines * line_h

	# Position tooltip near NPC, staying within viewport
	var tx: float = vpos.x + 12.0
	var ty: float = vpos.y - float(tooltip_h) * 0.5
	if tx + float(tooltip_w) > vp.x - 4.0:
		tx = vpos.x - float(tooltip_w) - 12.0
	if ty < 4.0:
		ty = 4.0
	if ty + float(tooltip_h) > vp.y - 4.0:
		ty = vp.y - float(tooltip_h) - 4.0

	var bg_rect := Rect2(tx, ty, float(tooltip_w), float(tooltip_h))
	draw_rect(bg_rect, NPC_TOOLTIP_BG)
	draw_rect(bg_rect, NPC_TOOLTIP_BORDER, false, 1.2)

	var ly: float = ty + float(pad) + float(line_h) - 3.0
	draw_string(font, Vector2(tx + float(pad), ly), ship_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 1.0, 0.6, 1.0))
	ly += float(line_h)
	draw_string(font, Vector2(tx + float(pad), ly), faction, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.72, 0.95, 0.45, 0.9))
	ly += float(line_h)
	draw_string(font, Vector2(tx + float(pad), ly), "Fracht:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.65, 0.88, 1.0, 0.85))
	ly += float(line_h)
	for line in cargo_lines:
		var cargo_line: String = str(line)
		draw_string(font, Vector2(tx + float(pad) + 6.0, ly), cargo_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.9, 0.9, 0.85))
		ly += float(line_h)


func draw_ship() -> void:
	var angle: float = player_rotation
	var forward := Vector2(cos(angle), sin(angle))
	var right := Vector2(-forward.y, forward.x)
	var p0: Vector2 = player_position + forward * 10.0
	var p1: Vector2 = player_position - forward * 7.0 + right * 5.5
	var p2: Vector2 = player_position - forward * 7.0 - right * 5.5
	var pts: PackedVector2Array = PackedVector2Array([p0, p1, p2])
	draw_colored_polygon(pts, PLAYER_COLOR)

	# Docking progress arc around player
	if not is_docked and docking_progress > 0.0:
		var prog: float = docking_progress / DOCK_HOLD_TIME
		draw_arc(player_position, 16.0, -PI * 0.5, -PI * 0.5 + prog * TAU, 24, Color(0.35, 1.0, 0.55, 0.7), 2.0)


func draw_own_station() -> void:
	draw_ship()
	for station in stations:
		if bool(station["is_player_owned"]) and str(station["system_id"]) == current_system_id:
			var pos: Vector2 = station["position"]
			var col := Color(0.45, 1.0, 0.55)
			for j in range(4):
				var a: float = float(j) / 4.0 * TAU
				var spoke_end: Vector2 = pos + Vector2(cos(a) * 22.0, sin(a) * 22.0)
				draw_line(pos, spoke_end, Color(col.r, col.g, col.b, 0.55), 1.2)
			draw_circle(pos, 10.0, Color(0.25, 0.6, 0.35))
			draw_circle(pos, 10.0, col, false, 1.5)
			var font: Font = ThemeDB.fallback_font
			draw_string(font, pos + Vector2(-30.0, 22.0), "Deine Station", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col)


# ─── Trade interface ──────────────────────────────────────────────────────────

func draw_trade_interface(station: Dictionary) -> void:
	var vp: Vector2 = get_viewport_rect().size
	var font: Font = ThemeDB.fallback_font

	# Station info panel (top-left)
	var info_rect := Rect2(10.0, 10.0, 230.0, 105.0)
	draw_rect(info_rect, PANEL_COLOR)
	draw_rect(info_rect, PANEL_BORDER, false, 1.2)
	var sname: String = str(station["display_name"])
	var stype_id: String = str(station["type_id"])
	var stype_name: String = str(STATION_TYPES[stype_id]["display_name"])
	var sys_name: String = str(SYSTEMS[current_system_id]["display_name"])
	draw_string(font, Vector2(18.0, 28.0), sname, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(font, Vector2(18.0, 46.0), stype_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, STATION_COLOR)
	draw_string(font, Vector2(18.0, 61.0), sys_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.72, 0.72, 0.9))
	var inv: Dictionary = station["inventory"]
	var station_stacks: Dictionary = inv["stacks"]
	var station_used: int = station_stacks.values().reduce(func(a, b): return a + b, 0)
	var station_cap: int = int(inv["capacity"])
	var income: int = int(station["processing_income"])
	draw_string(font, Vector2(18.0, 77.0), "Lager: %d/%d" % [station_used, station_cap], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.75, 0.75, 0.75))
	if income > 0:
		draw_string(font, Vector2(18.0, 93.0), "Verarbeitungseinnahmen: %d Cr" % income, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, CREDIT_COLOR)

	# Determine panel height based on module count
	var station_modules: Array = station["modules"]
	var extra_height: int = station_modules.size() * 44
	draw_trade_panel(station, vp, font, extra_height)
	draw_trade_log_panel(vp, font)


func draw_trade_panel(station: Dictionary, vp: Vector2, font: Font, extra_height: int) -> void:
	var rows: Array = get_sorted_rows(station)
	var panel_w := 530.0
	var base_h := 342.0
	var panel_h: float = base_h + float(extra_height)
	var px: float = (vp.x - panel_w) * 0.5
	var py: float = (vp.y - panel_h) * 0.5
	var panel_rect := Rect2(px, py, panel_w, panel_h)
	draw_rect(panel_rect, PANEL_COLOR)
	draw_rect(panel_rect, PANEL_BORDER, false, 1.4)

	# Header
	var creds: int = int(player_agent["credits"])
	draw_string(font, Vector2(px + 12.0, py + 22.0), "HANDELSMENÜ — %d Cr" % creds, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CREDIT_COLOR)

	# Sort bar
	var sort_x: float = px + 12.0
	var sort_y: float = py + 36.0
	sort_rect = Rect2(sort_x, sort_y, 100.0, 18.0)
	dir_rect = Rect2(sort_x + 104.0, sort_y, 36.0, 18.0)
	_draw_ui_button(sort_rect, "Sortierung: " + sort_key, false, font, 10)
	_draw_ui_button(dir_rect, "↑" if sort_ascending else "↓", false, font, 10)

	# Column headers
	var header_y: float = py + 60.0
	draw_string(font, Vector2(px + 12.0, header_y), "Ressource", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.65, 0.65))
	draw_string(font, Vector2(px + 195.0, header_y), "Station", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.65, 0.65))
	draw_string(font, Vector2(px + 255.0, header_y), "Inv", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.65, 0.65))
	draw_string(font, Vector2(px + 295.0, header_y), "Kaufen", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.65, 0.65))
	draw_string(font, Vector2(px + 370.0, header_y), "Verkaufen", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.65, 0.65))

	# Resource rows
	var row_y: float = py + 72.0
	var row_h := 32.0
	for row in rows:
		var rid: String = str(row["id"])
		var is_selected: bool = rid == selected_resource_id
		var row_rect := Rect2(px + 6.0, row_y, panel_w - 12.0, row_h)
		var row_bg: Color = ROW_SELECTED_BG if is_selected else ROW_DEFAULT_BG
		if not is_selected and hovered_control_id == "row:" + rid:
			row_bg = ROW_HOVER_BG
		draw_rect(row_rect, row_bg)

		var tier: int = int(row["tier"])
		var tier_col: Color = TIER_BORDER_COLOR.get(tier, Color.WHITE)
		draw_rect(row_rect, tier_col, false, 0.8)
		draw_rect(Rect2(px + 6.0, row_y, 3.0, row_h), tier_col)

		# Icon + name
		var res: Dictionary = RESOURCES[rid]
		var icon: String = str(res["icon"])
		draw_rect(Rect2(px + 12.0, row_y + 6.0, 20.0, 20.0), ICON_BG_COLOR)
		draw_string(font, Vector2(px + 13.0, row_y + 22.0), icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, tier_col)
		var rname: String = str(row["name"])
		var tier_label: String = "T" + str(tier)
		draw_string(font, Vector2(px + 36.0, row_y + 16.0), rname, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		draw_string(font, Vector2(px + 36.0, row_y + 28.0), tier_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, tier_col)

		# Stock
		var station_amt: int = int(row["station_amount"])
		draw_string(font, Vector2(px + 195.0, row_y + 20.0), str(station_amt), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		var stock_lbl: String = get_stock_state_label(station, rid)
		if stock_lbl != "":
			draw_string(font, Vector2(px + 195.0 + STOCK_STATE_OFFSET * 0.4, row_y + 20.0), stock_lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, get_stock_state_color(stock_lbl))

		# Player inventory
		var player_amt: int = int(row["amount"])
		draw_string(font, Vector2(px + 255.0, row_y + 20.0), str(player_amt), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

		# Buy button
		var buy_p: float = float(row["buy_price"])
		var buy_b := Rect2(px + 285.0, row_y + 5.0, 68.0, 22.0)
		var buy_hover: bool = hovered_control_id == "buy:" + rid
		var buy_bg: Color = UI_BUTTON_HOVER_BG if buy_hover else BUY_BUTTON_COLOR
		draw_rect(buy_b, buy_bg)
		draw_rect(buy_b, PANEL_BORDER, false, 0.7)
		draw_string(font, Vector2(px + 290.0, row_y + 20.0), "%d Cr" % int(buy_p), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, GOOD_COLOR)
		register_control("buy:" + rid, buy_b)

		# Sell button
		var sell_p: float = float(row["sell_price"])
		var sell_b := Rect2(px + 360.0, row_y + 5.0, 68.0, 22.0)
		var sell_hover: bool = hovered_control_id == "sell:" + rid
		var sell_bg: Color = UI_BUTTON_HOVER_BG if sell_hover else SELL_BUTTON_COLOR
		draw_rect(sell_b, sell_bg)
		draw_rect(sell_b, PANEL_BORDER, false, 0.7)
		draw_string(font, Vector2(px + 365.0, row_y + 20.0), "%d Cr" % int(sell_p), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, BAD_COLOR)
		register_control("sell:" + rid, sell_b)

		register_control("row:" + rid, row_rect)
		row_y += row_h + 2.0

	# Quantity controls
	var ctrl_y: float = row_y + 6.0
	plus_one_rect = Rect2(px + 12.0, ctrl_y, 38.0, 22.0)
	plus_five_rect = Rect2(px + 54.0, ctrl_y, 38.0, 22.0)
	max_rect = Rect2(px + 96.0, ctrl_y, 48.0, 22.0)
	sell_all_rect = Rect2(px + 148.0, ctrl_y, 60.0, 22.0)
	_draw_ui_button(plus_one_rect, "+1", false, font, 11)
	_draw_ui_button(plus_five_rect, "+5", false, font, 11)
	_draw_ui_button(max_rect, "Max", false, font, 11)
	_draw_ui_button(sell_all_rect, "Alles verk.", false, font, 10)
	draw_string(font, Vector2(px + 220.0, ctrl_y + 16.0), "Menge: %d" % quantity, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

	buy_rect = Rect2(px + 330.0, ctrl_y, 80.0, 22.0)
	sell_rect = Rect2(px + 416.0, ctrl_y, 80.0, 22.0)
	_draw_ui_button(buy_rect, "Kaufen", false, font, 11)
	_draw_ui_button(sell_rect, "Verkaufen", false, font, 11)

	# Processing module section
	if not station["modules"].is_empty():
		var proc_y: float = ctrl_y + 34.0
		draw_string(font, Vector2(px + 12.0, proc_y + 12.0), "── Verarbeitungsmodule ──", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.82, 0.6, 1.0))
		proc_y += 18.0
		var station_modules: Array = station["modules"]
		for mod_id in station_modules:
			var pmod: Dictionary = PROCESSING_MODULES[str(mod_id)]
			var mod_name: String = str(pmod["display_name"])
			var in_name: String = str(RESOURCES[str(pmod["input"])]["display_name"])
			var out_name: String = str(RESOURCES[str(pmod["output"])]["display_name"])
			var ratio: int = int(pmod["ratio"])
			var fee: int = int(pmod["fee"])
			var proc_info: String = mod_name + ": " + str(ratio) + "× " + in_name + " → 1× " + out_name + "  (Gebühr: " + str(fee) + " Cr)"
			draw_string(font, Vector2(px + 12.0, proc_y + 14.0), proc_info, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.82, 0.6, 1.0))
			var proc_btn := Rect2(px + 420.0, proc_y, 88.0, 22.0)
			var proc_hover: bool = hovered_control_id == "process:" + str(mod_id)
			var proc_bg: Color = UI_BUTTON_HOVER_BG if proc_hover else PROCESS_BUTTON_COLOR
			draw_rect(proc_btn, proc_bg)
			draw_rect(proc_btn, PANEL_BORDER, false, 0.7)
			draw_string(font, Vector2(px + 426.0, proc_y + 15.0), "Verarbeiten", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
			register_control("process:" + str(mod_id), proc_btn)
			proc_y += 44.0


func draw_trade_log_panel(vp: Vector2, font: Font) -> void:
	var log_w := 240.0
	var log_h := 190.0
	var lx: float = vp.x - log_w - 10.0
	var ly: float = vp.y - log_h - 10.0
	var log_rect := Rect2(lx, ly, log_w, log_h)
	draw_rect(log_rect, PANEL_COLOR)
	draw_rect(log_rect, PANEL_BORDER, false, 1.1)
	draw_string(font, Vector2(lx + 8.0, ly + 16.0), "Handelsverlauf", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, CREDIT_COLOR)
	var entry_y: float = ly + 30.0
	var recent_entries: Array = trade_log.slice(maxi(0, trade_log.size() - 9))
	for entry in recent_entries:
		draw_string(font, Vector2(lx + 8.0, entry_y), str(entry), HORIZONTAL_ALIGNMENT_LEFT, log_w - 16.0, 9, TRADE_LOG_COLOR)
		entry_y += 16.0


func _draw_ui_button(rect: Rect2, label: String, pressed: bool, font: Font, fsize: int) -> void:
	var is_feedback: bool = feedback_control_id != "" and feedback_control_id == label
	var is_hovered: bool = rect.has_point(mouse_position)
	var bg: Color = UI_BUTTON_PRESS_BG if (pressed or is_feedback) else (UI_BUTTON_HOVER_BG if is_hovered else UI_BUTTON_BG)
	draw_rect(rect, bg)
	draw_rect(rect, PANEL_BORDER, false, 0.8)
	draw_string(font, Vector2(rect.position.x + 5.0, rect.position.y + float(fsize) + 2.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color.WHITE)


# ─── Control hit-testing ──────────────────────────────────────────────────────

func register_control(id: String, rect: Rect2) -> void:
	control_hit_rects.append({"id": id, "rect": rect})


func update_hovered_control(redraw: bool) -> void:
	var prev_control := hovered_control_id
	var prev_npc := hovered_npc_id
	hovered_control_id = ""
	for entry in control_hit_rects:
		if entry["rect"].has_point(mouse_position):
			hovered_control_id = str(entry["id"])
			break
	hovered_npc_id = ""
	if not is_docked:
		for npc in npcs:
			if str(npc["system_id"]) != current_system_id:
				continue
			if str(npc["state"]) == "traveling_intersystem":
				continue
			var vpos: Vector2 = npc["visual_position"]
			if mouse_position.distance_to(vpos) <= NPC_HOVER_RADIUS:
				hovered_npc_id = str(npc["id"])
				break
	if redraw and (hovered_control_id != prev_control or hovered_npc_id != prev_npc):
		queue_redraw()


func handle_left_click(pos: Vector2) -> void:
	mouse_position = pos
	update_hovered_control(false)

	# NPC menu takes priority when open
	if is_npc_menu_open:
		_handle_npc_menu_click(pos)
		return

	if sort_rect.has_point(pos):
		cycle_sort(); queue_redraw(); return
	if dir_rect.has_point(pos):
		sort_ascending = not sort_ascending; queue_redraw(); return
	if plus_one_rect.has_point(pos):
		quantity = mini(999, quantity + 1); queue_redraw(); return
	if plus_five_rect.has_point(pos):
		quantity = mini(999, quantity + 5); queue_redraw(); return
	if max_rect.has_point(pos):
		quantity = int(player_agent["inventory"]["capacity"]); queue_redraw(); return
	if sell_all_rect.has_point(pos):
		attempt_sell_all(); queue_redraw(); return
	if buy_rect.has_point(pos):
		attempt_buy(selected_resource_id, quantity); queue_redraw(); return
	if sell_rect.has_point(pos):
		attempt_sell(selected_resource_id, quantity); queue_redraw(); return

	for entry in control_hit_rects:
		var cid: String = str(entry["id"])
		var crect: Rect2 = entry["rect"]
		if crect.has_point(pos):
			if cid.begins_with("row:"):
				selected_resource_id = cid.substr(4)
				queue_redraw()
				return
			elif cid.begins_with("buy:"):
				var rid: String = cid.substr(4)
				attempt_buy(rid, quantity)
				queue_redraw()
				return
			elif cid.begins_with("sell:"):
				var rid: String = cid.substr(5)
				attempt_sell(rid, quantity)
				queue_redraw()
				return
			elif cid.begins_with("process:"):
				var mid: String = cid.substr(8)
				attempt_process(mid)
				queue_redraw()
				return


# ─── NPC Hailing & Interaction ────────────────────────────────────────────────

func find_nearest_npc_in_interact_range() -> Dictionary:
	var best: Dictionary = {}
	var best_dist := INF
	for npc in npcs:
		if str(npc["system_id"]) != current_system_id:
			continue
		if str(npc["state"]) == "traveling_intersystem":
			continue
		var vpos: Vector2 = npc["visual_position"]
		var d: float = player_position.distance_to(vpos)
		if d < NPC_INTERACT_RANGE and d < best_dist:
			best_dist = d
			best = npc
	return best


func update_npc_hail(delta: float) -> void:
	var hail_held: bool = Input.is_action_pressed("hail")
	if not hail_held:
		if npc_hail_progress > 0.0:
			npc_hail_progress = 0.0
			npc_hail_target_id = ""
			queue_redraw()
		return

	var nearest: Dictionary = find_nearest_npc_in_interact_range()
	if nearest.is_empty():
		npc_hail_progress = 0.0
		npc_hail_target_id = ""
		return

	var nid: String = str(nearest["id"])
	if npc_hail_target_id != nid:
		npc_hail_progress = 0.0
		npc_hail_target_id = nid

	npc_hail_progress = minf(npc_hail_progress + delta, NPC_HAIL_HOLD_TIME)
	var ship_name: String = str(nearest.get("ship_name", "NPC"))
	status = "Halte X — anfunken: " + ship_name + " ..."

	if npc_hail_progress >= NPC_HAIL_HOLD_TIME:
		npc_hail_progress = 0.0
		npc_hail_target_id = ""
		open_npc_menu(nearest)


func open_npc_menu(npc: Dictionary) -> void:
	is_npc_menu_open = true
	npc_menu_npc = npc
	npc_menu_page = "main"
	npc_menu_selected_resource = ""
	npc_menu_qty = 1
	var ship_name: String = str(npc.get("ship_name", "NPC"))
	show_toast("Verbindung hergestellt: " + ship_name, 1.8)
	status = "NPC-Menü offen — ESC oder Schließen zum Verlassen."
	queue_redraw()


func close_npc_menu() -> void:
	is_npc_menu_open = false
	npc_menu_npc = {}
	npc_menu_page = "main"
	npc_menu_selected_resource = ""
	npc_menu_qty = 1
	status = DEFAULT_STATUS


func _handle_npc_menu_click(pos: Vector2) -> void:
	var npc: Dictionary = npc_menu_npc
	for entry in control_hit_rects:
		var cid: String = str(entry["id"])
		var crect: Rect2 = entry["rect"]
		if not crect.has_point(pos):
			continue
		if cid == "npc_menu:trade":
			npc_menu_page = "trade"
			npc_menu_selected_resource = ""
			queue_redraw()
			return
		elif cid == "npc_menu:mission":
			npc_menu_page = "mission"
			queue_redraw()
			return
		elif cid == "npc_menu:close":
			close_npc_menu()
			queue_redraw()
			return
		elif cid == "npc_trade:back" or cid == "npc_mission:back":
			npc_menu_page = "main"
			queue_redraw()
			return
		elif cid == "npc_trade:plus_one":
			npc_menu_qty = mini(999, npc_menu_qty + 1)
			queue_redraw()
			return
		elif cid == "npc_trade:plus_five":
			npc_menu_qty = mini(999, npc_menu_qty + 5)
			queue_redraw()
			return
		elif cid == "npc_trade:max":
			npc_menu_qty = int(player_agent["inventory"]["capacity"])
			queue_redraw()
			return
		elif cid.begins_with("npc_trade:row:"):
			npc_menu_selected_resource = cid.substr(14)
			queue_redraw()
			return
		elif cid.begins_with("npc_trade:buy:"):
			var rid: String = cid.substr(14)
			attempt_npc_buy(npc, rid, npc_menu_qty)
			queue_redraw()
			return
		elif cid.begins_with("npc_trade:sell:"):
			var rid: String = cid.substr(15)
			attempt_npc_sell(npc, rid, npc_menu_qty)
			queue_redraw()
			return


func attempt_npc_buy(npc: Dictionary, resource_id: String, qty: int) -> void:
	var npc_stacks: Dictionary = npc["inventory"]["stacks"]
	var npc_have: int = npc_stacks.get(resource_id, 0)
	if npc_have <= 0:
		var res_name: String = str(RESOURCES[resource_id]["display_name"])
		show_toast("NPC hat " + res_name + " nicht vorrätig.", 2.0)
		return
	var actual_qty: int = mini(qty, npc_have)
	var inv: Dictionary = player_agent["inventory"]
	var pstacks: Dictionary = inv["stacks"]
	var used: int = pstacks.values().reduce(func(a, b): return a + b, 0)
	var room: int = int(inv["capacity"]) - used
	actual_qty = mini(actual_qty, room)
	if actual_qty <= 0:
		show_toast("Frachtraum voll!", 2.0)
		return
	var unit_price: float = float(RESOURCES[resource_id]["base_price"]) * 1.1
	var total_price: float = float(actual_qty) * unit_price
	if float(player_agent["credits"]) < total_price:
		show_toast("Nicht genug Credits! (" + str(int(total_price)) + " Cr benötigt)", 2.0)
		return
	npc_stacks[resource_id] = npc_have - actual_qty
	pstacks[resource_id] = pstacks.get(resource_id, 0) + actual_qty
	player_agent["credits"] = float(player_agent["credits"]) - total_price
	npc["credits"] = float(npc["credits"]) + total_price
	var res_name: String = str(RESOURCES[resource_id]["display_name"])
	var log_entry: String = "NPC-Kauf: " + str(actual_qty) + "× " + res_name + " für " + str(int(total_price)) + " Cr"
	add_trade_log(log_entry)
	show_toast(log_entry, 1.8)


func attempt_npc_sell(npc: Dictionary, resource_id: String, qty: int) -> void:
	var pstacks: Dictionary = player_agent["inventory"]["stacks"]
	var player_have: int = pstacks.get(resource_id, 0)
	if player_have <= 0:
		show_toast("Nicht im Inventar.", 2.0)
		return
	var npc_inv: Dictionary = npc["inventory"]
	var npc_stacks: Dictionary = npc_inv["stacks"]
	var npc_used: int = npc_stacks.values().reduce(func(a, b): return a + b, 0)
	var npc_cap: int = int(npc_inv["capacity"])
	var npc_room: int = npc_cap - npc_used
	if npc_room <= 0:
		show_toast("NPC-Laderaum ist voll!", 2.0)
		return
	var unit_price: float = float(RESOURCES[resource_id]["base_price"]) * 0.88
	var npc_credits: float = float(npc["credits"])
	var max_by_credits: int = int(npc_credits / maxf(unit_price, 0.01))
	var actual_qty: int = mini(mini(mini(qty, player_have), npc_room), max_by_credits)
	if actual_qty <= 0:
		show_toast("NPC hat keine Credits mehr!", 2.0)
		return
	var total_price: float = float(actual_qty) * unit_price
	pstacks[resource_id] = player_have - actual_qty
	npc_stacks[resource_id] = npc_stacks.get(resource_id, 0) + actual_qty
	player_agent["credits"] = float(player_agent["credits"]) + total_price
	npc["credits"] = npc_credits - total_price
	var res_name: String = str(RESOURCES[resource_id]["display_name"])
	var log_entry: String = "NPC-Verkauf: " + str(actual_qty) + "× " + res_name + " für " + str(int(total_price)) + " Cr"
	add_trade_log(log_entry)
	show_toast(log_entry, 1.8)


func get_npc_mission_text(npc: Dictionary) -> Array:
	var lines: Array = []
	var state: String = str(npc["state"])
	match state:
		"idle":
			lines.append("Sucht nach Handelsmöglichkeiten")
		"traveling_to_buy":
			var dest_id: String = str(npc["dest_station_id"])
			var dest: Dictionary = get_station_by_id(dest_id)
			var dest_name: String = str(dest["display_name"]) if not dest.is_empty() else "eine Station"
			lines.append("Fliegt zu " + dest_name)
			lines.append("  um Waren einzukaufen")
		"buying":
			var dest_id: String = str(npc["dest_station_id"])
			var dest: Dictionary = get_station_by_id(dest_id)
			var dest_name: String = str(dest["display_name"]) if not dest.is_empty() else "einer Station"
			lines.append("Kauft Waren bei " + dest_name)
		"traveling_to_sell":
			var dest_id: String = str(npc["dest_station_id"])
			var dest: Dictionary = get_station_by_id(dest_id)
			var dest_name: String = str(dest["display_name"]) if not dest.is_empty() else "eine Station"
			lines.append("Fliegt zu " + dest_name)
			lines.append("  um Waren zu verkaufen")
			var npc_stacks: Dictionary = npc["inventory"]["stacks"]
			for rid in npc_stacks.keys():
				var amt: int = int(npc_stacks[rid])
				if amt > 0:
					var rname: String = str(RESOURCES[rid]["display_name"])
					lines.append("  Lader: " + rname + " ×" + str(amt))
		"selling":
			var dest_id: String = str(npc["dest_station_id"])
			var dest: Dictionary = get_station_by_id(dest_id)
			var dest_name: String = str(dest["display_name"]) if not dest.is_empty() else "einer Station"
			lines.append("Verkauft Waren bei " + dest_name)
		"traveling_to_process":
			lines.append("Fliegt zur Verarbeitungsstation")
		"processing":
			lines.append("Verarbeitet Güter an einer Station")
		"traveling_intersystem":
			lines.append("Reist in ein anderes Sternensystem")
		_:
			lines.append("Status unbekannt")
	return lines


func get_trade_tip_for_npc(npc: Dictionary) -> Array:
	var tip_lines: Array = []
	var sys_id: String = str(npc["system_id"])
	var route: Dictionary = find_npc_trade_route(sys_id)
	if route.is_empty():
		tip_lines.append("Keine profitablen Routen im System.")
		return tip_lines
	var buy_id: String = str(route["buy_station_id"])
	var sell_id: String = str(route["sell_station_id"])
	var rid: String = str(route["resource_id"])
	var buy_st: Dictionary = get_station_by_id(buy_id)
	var sell_st: Dictionary = get_station_by_id(sell_id)
	if buy_st.is_empty() or sell_st.is_empty():
		tip_lines.append("Keine Route gefunden.")
		return tip_lines
	var buy_p: float = compute_buy_price(buy_st, rid)
	var sell_p: float = compute_sell_price(sell_st, rid)
	var profit: float = sell_p - buy_p
	var res_name: String = str(RESOURCES[rid]["display_name"])
	var buy_name: String = str(buy_st["display_name"])
	var sell_name: String = str(sell_st["display_name"])
	tip_lines.append(res_name + " kaufen bei:")
	tip_lines.append("  " + buy_name)
	tip_lines.append("  (" + str(int(buy_p)) + " Cr/Einheit)")
	tip_lines.append("Verkaufen bei:")
	tip_lines.append("  " + sell_name)
	tip_lines.append("  (" + str(int(sell_p)) + " Cr/Einheit)")
	tip_lines.append("Profit: +" + str(int(profit)) + " Cr/Einheit")
	return tip_lines


# ─── NPC Menu Drawing ─────────────────────────────────────────────────────────

func draw_npc_menu() -> void:
	var npc: Dictionary = npc_menu_npc
	var page: String = npc_menu_page
	match page:
		"main":
			_draw_npc_menu_main(npc)
		"trade":
			_draw_npc_menu_trade(npc)
		"mission":
			_draw_npc_menu_mission(npc)


func _draw_npc_menu_main(npc: Dictionary) -> void:
	var font: Font = ThemeDB.fallback_font
	var vp: Vector2 = get_viewport_rect().size
	var ship_name: String = str(npc.get("ship_name", "Unbekannt"))
	var faction: String = str(npc.get("faction", "Fraktionslos"))
	var npc_creds: int = int(npc["credits"])
	var npc_inv: Dictionary = npc["inventory"]
	var npc_stacks: Dictionary = npc_inv["stacks"]
	var npc_used: int = npc_stacks.values().reduce(func(a, b): return a + b, 0)
	var npc_cap: int = int(npc_inv["capacity"])

	var w := 300.0
	var h := 185.0
	var px: float = (vp.x - w) * 0.5
	var py: float = (vp.y - h) * 0.5

	draw_rect(Rect2(px, py, w, h), NPC_MENU_BG)
	draw_rect(Rect2(px, py, w, h), NPC_MENU_BORDER, false, 1.5)

	draw_string(font, Vector2(px + 12.0, py + 22.0), ship_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, NPC_MENU_ACCENT)
	draw_string(font, Vector2(px + 12.0, py + 38.0), faction, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, NPC_MARKER_COLOR)
	draw_string(font, Vector2(px + 12.0, py + 54.0), "Laderaum: %d/%d   Credits: %d Cr" % [npc_used, npc_cap, npc_creds], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.75, 0.75, 0.75))

	var btn_w: float = w - 40.0
	var btn_h := 26.0
	var bx: float = px + 20.0

	var trade_btn := Rect2(bx, py + 70.0, btn_w, btn_h)
	var mission_btn := Rect2(bx, py + 102.0, btn_w, btn_h)
	var close_btn := Rect2(bx, py + 146.0, btn_w, btn_h)

	_draw_ui_button(trade_btn, "1. Handeln", false, font, 12)
	_draw_ui_button(mission_btn, "2. Was ist deine Mission?", false, font, 12)
	_draw_ui_button(close_btn, "Schließen  [ESC]", false, font, 12)

	register_control("npc_menu:trade", trade_btn)
	register_control("npc_menu:mission", mission_btn)
	register_control("npc_menu:close", close_btn)


func _draw_npc_menu_trade(npc: Dictionary) -> void:
	var font: Font = ThemeDB.fallback_font
	var vp: Vector2 = get_viewport_rect().size
	var ship_name: String = str(npc.get("ship_name", "Unbekannt"))
	var npc_inv: Dictionary = npc["inventory"]
	var npc_stacks: Dictionary = npc_inv["stacks"]
	var npc_cap: int = int(npc_inv["capacity"])
	var npc_used: int = npc_stacks.values().reduce(func(a, b): return a + b, 0)
	var npc_creds: int = int(npc["credits"])
	var pstacks: Dictionary = player_agent["inventory"]["stacks"]

	var panel_w := 520.0
	var row_h := 30.0
	var header_h := 100.0
	var ctrl_h := 40.0
	var panel_h: float = header_h + float(RESOURCE_IDS.size()) * (row_h + 2.0) + ctrl_h
	var px: float = (vp.x - panel_w) * 0.5
	var py: float = (vp.y - panel_h) * 0.5

	draw_rect(Rect2(px, py, panel_w, panel_h), NPC_MENU_BG)
	draw_rect(Rect2(px, py, panel_w, panel_h), NPC_MENU_BORDER, false, 1.5)

	draw_string(font, Vector2(px + 12.0, py + 22.0), "Handel mit " + ship_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, NPC_MENU_ACCENT)
	draw_string(font, Vector2(px + 12.0, py + 38.0), "Laderaum: %d/%d   Credits: %d Cr" % [npc_used, npc_cap, npc_creds], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.75, 0.75, 0.75))
	draw_string(font, Vector2(px + 12.0, py + 54.0), "Kaufen v. NPC: Basispreis ×1.1   |   Verkaufen an NPC: Basispreis ×0.88", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.65, 0.65, 0.65))

	var header_y: float = py + 70.0
	draw_string(font, Vector2(px + 12.0, header_y), "Ressource", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.6, 0.6, 0.6))
	draw_string(font, Vector2(px + 200.0, header_y), "NPC", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.6, 0.6, 0.6))
	draw_string(font, Vector2(px + 250.0, header_y), "Inv", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.6, 0.6, 0.6))
	draw_string(font, Vector2(px + 288.0, header_y), "Kaufen", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.6, 0.6, 0.6))
	draw_string(font, Vector2(px + 378.0, header_y), "Verkaufen", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.6, 0.6, 0.6))

	var row_y: float = py + header_h - 16.0
	for rid in RESOURCE_IDS:
		var res: Dictionary = RESOURCES[rid]
		var npc_amt: int = npc_stacks.get(rid, 0)
		var player_amt: int = pstacks.get(rid, 0)
		var base: float = float(res["base_price"])
		var npc_sell_price: float = base * 1.1
		var npc_buy_price: float = base * 0.88

		var is_selected: bool = rid == npc_menu_selected_resource
		var row_rect := Rect2(px + 6.0, row_y, panel_w - 12.0, row_h)
		var row_bg: Color = ROW_SELECTED_BG if is_selected else ROW_DEFAULT_BG
		if not is_selected and hovered_control_id == "npc_trade:row:" + rid:
			row_bg = ROW_HOVER_BG
		draw_rect(row_rect, row_bg)

		var tier: int = int(res["tier"])
		var tier_col: Color = TIER_BORDER_COLOR.get(tier, Color.WHITE)
		draw_rect(row_rect, tier_col, false, 0.8)
		draw_rect(Rect2(px + 6.0, row_y, 3.0, row_h), tier_col)

		var icon: String = str(res["icon"])
		draw_rect(Rect2(px + 12.0, row_y + 5.0, 20.0, 20.0), ICON_BG_COLOR)
		draw_string(font, Vector2(px + 13.0, row_y + 20.0), icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, tier_col)
		var rname: String = str(res["display_name"])
		draw_string(font, Vector2(px + 36.0, row_y + 17.0), rname, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

		draw_string(font, Vector2(px + 200.0, row_y + 19.0), str(npc_amt), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		draw_string(font, Vector2(px + 250.0, row_y + 19.0), str(player_amt), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

		if npc_amt > 0:
			var buy_b := Rect2(px + 278.0, row_y + 4.0, 84.0, 22.0)
			var buy_hover: bool = hovered_control_id == "npc_trade:buy:" + rid
			var buy_bg: Color = UI_BUTTON_HOVER_BG if buy_hover else BUY_BUTTON_COLOR
			draw_rect(buy_b, buy_bg)
			draw_rect(buy_b, PANEL_BORDER, false, 0.7)
			draw_string(font, Vector2(px + 283.0, row_y + 18.0), "%d Cr" % int(npc_sell_price), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, GOOD_COLOR)
			register_control("npc_trade:buy:" + rid, buy_b)

		if player_amt > 0:
			var sell_b := Rect2(px + 368.0, row_y + 4.0, 84.0, 22.0)
			var sell_hover: bool = hovered_control_id == "npc_trade:sell:" + rid
			var sell_bg: Color = UI_BUTTON_HOVER_BG if sell_hover else SELL_BUTTON_COLOR
			draw_rect(sell_b, sell_bg)
			draw_rect(sell_b, PANEL_BORDER, false, 0.7)
			draw_string(font, Vector2(px + 373.0, row_y + 18.0), "%d Cr" % int(npc_buy_price), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, BAD_COLOR)
			register_control("npc_trade:sell:" + rid, sell_b)

		register_control("npc_trade:row:" + rid, row_rect)
		row_y += row_h + 2.0

	var ctrl_y: float = row_y + 4.0
	var tp1 := Rect2(px + 12.0, ctrl_y, 38.0, 22.0)
	var tp5 := Rect2(px + 54.0, ctrl_y, 38.0, 22.0)
	var tpm := Rect2(px + 96.0, ctrl_y, 48.0, 22.0)
	_draw_ui_button(tp1, "+1", false, font, 11)
	_draw_ui_button(tp5, "+5", false, font, 11)
	_draw_ui_button(tpm, "Max", false, font, 11)
	draw_string(font, Vector2(px + 160.0, ctrl_y + 16.0), "Menge: %d" % npc_menu_qty, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	register_control("npc_trade:plus_one", tp1)
	register_control("npc_trade:plus_five", tp5)
	register_control("npc_trade:max", tpm)

	var back_btn := Rect2(px + panel_w - 140.0, ctrl_y, 120.0, 22.0)
	_draw_ui_button(back_btn, "◀ Zurück", false, font, 11)
	register_control("npc_trade:back", back_btn)


func _draw_npc_menu_mission(npc: Dictionary) -> void:
	var font: Font = ThemeDB.fallback_font
	var vp: Vector2 = get_viewport_rect().size
	var ship_name: String = str(npc.get("ship_name", "Unbekannt"))

	var mission_lines: Array = get_npc_mission_text(npc)
	var tip_lines: Array = get_trade_tip_for_npc(npc)

	var line_h := 16
	var total_lines: int = mission_lines.size() + tip_lines.size() + 4
	var panel_w := 340.0
	var panel_h: float = 80.0 + float(total_lines * line_h) + 34.0
	var px: float = (vp.x - panel_w) * 0.5
	var py: float = (vp.y - panel_h) * 0.5

	draw_rect(Rect2(px, py, panel_w, panel_h), NPC_MENU_BG)
	draw_rect(Rect2(px, py, panel_w, panel_h), NPC_MENU_BORDER, false, 1.5)

	draw_string(font, Vector2(px + 12.0, py + 22.0), "Mission: " + ship_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, NPC_MENU_ACCENT)

	var ly: float = py + 44.0
	draw_string(font, Vector2(px + 12.0, ly), "── Aktueller Auftrag ──", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, NPC_MARKER_COLOR)
	ly += float(line_h)
	for line in mission_lines:
		draw_string(font, Vector2(px + 16.0, ly), str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		ly += float(line_h)

	ly += 6.0
	draw_string(font, Vector2(px + 12.0, ly), "── Handelstipp (aktuelles System) ──", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, CREDIT_COLOR)
	ly += float(line_h)
	for line in tip_lines:
		draw_string(font, Vector2(px + 16.0, ly), str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.82, 0.92, 0.72))
		ly += float(line_h)

	ly += 8.0
	var back_btn := Rect2(px + (panel_w - 120.0) * 0.5, ly, 120.0, 22.0)
	_draw_ui_button(back_btn, "◀ Zurück", false, font, 11)
	register_control("npc_mission:back", back_btn)


# ─── Audio ────────────────────────────────────────────────────────────────────

func setup_audio() -> void:
	engine_player = AudioStreamPlayer.new()
	add_child(engine_player)
	boost_player = AudioStreamPlayer.new()
	add_child(boost_player)
	dock_start_player = AudioStreamPlayer.new()
	add_child(dock_start_player)
	dock_complete_player = AudioStreamPlayer.new()
	add_child(dock_complete_player)
	ui_hover_player = AudioStreamPlayer.new()
	add_child(ui_hover_player)
	ui_click_player = AudioStreamPlayer.new()
	add_child(ui_click_player)
	trade_success_player = AudioStreamPlayer.new()
	add_child(trade_success_player)
	trade_fail_player = AudioStreamPlayer.new()
	add_child(trade_fail_player)
	audio_prime_player = AudioStreamPlayer.new()
	add_child(audio_prime_player)


func prime_audio() -> void:
	if not audio_primed:
		audio_primed = true


# ─── Save / Load ──────────────────────────────────────────────────────────────

func save_state() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	var save_data: Dictionary = {
		"version": SAVE_VERSION,
		"player_credits": float(player_agent["credits"]),
		"player_inventory": player_agent["inventory"]["stacks"].duplicate(),
		"player_position_x": float(player_position.x),
		"player_position_y": float(player_position.y),
		"current_system_id": current_system_id,
		"goal_reached": goal_reached,
		"has_own_station": has_own_station,
		"trade_log": trade_log.duplicate(),
		"avg_buy_price": avg_buy_price.duplicate(),
		"sort_key": sort_key,
		"sort_ascending": sort_ascending,
		"stations": [],
		"npcs": []
	}
	for station in stations:
		var st_data: Dictionary = {
			"id": str(station["id"]),
			"display_name": str(station["display_name"]),
			"type_id": str(station["type_id"]),
			"position_x": float(station["position"].x),
			"position_y": float(station["position"].y),
			"system_id": str(station["system_id"]),
			"is_player_owned": bool(station["is_player_owned"]),
			"modules": station["modules"].duplicate(),
			"processing_income": int(station["processing_income"]),
			"inventory_stacks": station["inventory"]["stacks"].duplicate()
		}
		save_data["stations"].append(st_data)
	for npc in npcs:
		var npc_data: Dictionary = {
			"id": str(npc["id"]),
			"ship_name": str(npc.get("ship_name", "")),
			"faction": str(npc.get("faction", "")),
			"anchor_station_id": str(npc["anchor_station_id"]),
			"system_id": str(npc["system_id"]),
			"dest_station_id": str(npc["dest_station_id"]),
			"state": str(npc["state"]),
			"position_x": float(npc["visual_position"].x),
			"position_y": float(npc["visual_position"].y),
			"credits": float(npc["credits"]),
			"inventory_stacks": npc["inventory"]["stacks"].duplicate()
		}
		save_data["npcs"].append(npc_data)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var raw: String = file.get_as_text()
	file.close()
	if raw.strip_edges().is_empty():
		return

	var parsed = JSON.parse_string(raw)
	if parsed == null or not (parsed is Dictionary):
		return
	var save_data: Dictionary = parsed
	var version: int = int(save_data.get("version", 0))
	if version < SAVE_VERSION:
		return

	player_agent["credits"] = float(save_data.get("player_credits", 600))
	var saved_inv = save_data.get("player_inventory", {})
	if saved_inv is Dictionary:
		player_agent["inventory"]["stacks"].clear()
		for k in saved_inv.keys():
			player_agent["inventory"]["stacks"][str(k)] = int(saved_inv[k])
	player_position = Vector2(
		float(save_data.get("player_position_x", DEFAULT_PLAYER_POSITION.x)),
		float(save_data.get("player_position_y", DEFAULT_PLAYER_POSITION.y))
	)
	current_system_id = str(save_data.get("current_system_id", "ymir_prime"))
	if not SYSTEMS.has(current_system_id):
		current_system_id = "ymir_prime"
	goal_reached = bool(save_data.get("goal_reached", false))
	has_own_station = bool(save_data.get("has_own_station", false))
	var saved_log = save_data.get("trade_log", [])
	if saved_log is Array:
		trade_log = []
		for e in saved_log:
			trade_log.append(str(e))
	var saved_abp = save_data.get("avg_buy_price", {})
	if saved_abp is Dictionary:
		avg_buy_price.clear()
		for k in saved_abp.keys():
			avg_buy_price[str(k)] = float(saved_abp[k])
	sort_key = str(save_data.get("sort_key", "value"))
	sort_ascending = bool(save_data.get("sort_ascending", false))

	var saved_stations = save_data.get("stations", [])
	if saved_stations is Array and saved_stations.size() > 0:
		stations.clear()
		for st_data in saved_stations:
			if not (st_data is Dictionary):
				continue
			var stype_id: String = str(st_data.get("type_id", "trade_hub"))
			if not STATION_TYPES.has(stype_id):
				continue
			var stype: Dictionary = STATION_TYPES[stype_id]
			var pos := Vector2(float(st_data.get("position_x", 300)), float(st_data.get("position_y", 300)))
			var sys_id: String = str(st_data.get("system_id", "ymir_prime"))
			if not SYSTEMS.has(sys_id):
				sys_id = "ymir_prime"
			var inventory: Dictionary = {"capacity": int(stype["capacity"]), "stacks": {}}
			var saved_stacks = st_data.get("inventory_stacks", {})
			if saved_stacks is Dictionary:
				for k in saved_stacks.keys():
					var rid: String = str(k)
					if RESOURCES.has(rid):
						inventory["stacks"][rid] = int(saved_stacks[k])
			var modules_saved = st_data.get("modules", [])
			var modules_copy: Array = []
			if modules_saved is Array:
				for m in modules_saved:
					if PROCESSING_MODULES.has(str(m)):
						modules_copy.append(str(m))
			stations.append({
				"id": str(st_data.get("id", "station_" + str(stations.size()))),
				"display_name": str(st_data.get("display_name", "Station")),
				"type_id": stype_id,
				"position": pos,
				"inventory": inventory,
				"trade_log": [],
				"is_player_owned": bool(st_data.get("is_player_owned", false)),
				"system_id": sys_id,
				"modules": modules_copy,
				"processing_income": int(st_data.get("processing_income", 0))
			})

	var saved_npcs = save_data.get("npcs", [])
	if saved_npcs is Array and saved_npcs.size() > 0:
		npcs.clear()
		for npc_data in saved_npcs:
			if not (npc_data is Dictionary):
				continue
			var npc_sys: String = str(npc_data.get("system_id", "ymir_prime"))
			if not SYSTEMS.has(npc_sys):
				npc_sys = "ymir_prime"
			var npc_pos := Vector2(float(npc_data.get("position_x", 300)), float(npc_data.get("position_y", 300)))
			var npc_stacks_saved = npc_data.get("inventory_stacks", {})
			var npc_stacks: Dictionary = {}
			if npc_stacks_saved is Dictionary:
				for k in npc_stacks_saved.keys():
					var rid: String = str(k)
					if RESOURCES.has(rid):
						npc_stacks[rid] = int(npc_stacks_saved[k])
			var saved_ship_name: String = str(npc_data.get("ship_name", ""))
			if saved_ship_name.is_empty():
				saved_ship_name = str(NPC_SHIP_NAMES[rng.randi() % NPC_SHIP_NAMES.size()])
			var saved_faction: String = str(npc_data.get("faction", ""))
			if saved_faction.is_empty():
				saved_faction = str(NPC_FACTIONS[rng.randi() % NPC_FACTIONS.size()])
			npcs.append({
				"id": str(npc_data.get("id", "npc_" + str(npcs.size()))),
				"ship_name": saved_ship_name,
				"faction": saved_faction,
				"anchor_station_id": str(npc_data.get("anchor_station_id", "")),
				"system_id": npc_sys,
				"dest_station_id": str(npc_data.get("dest_station_id", "")),
				"dest_system_id": "",
				"state": str(npc_data.get("state", "idle")),
				"position": npc_pos,
				"visual_position": npc_pos,
				"target_position": npc_pos,
				"travel_progress": 0.0,
				"travel_duration": 1.0,
				"inventory": {"capacity": 24, "stacks": npc_stacks},
				"credits": float(npc_data.get("credits", 200)),
				"intersystem_travel_timer": 0.0
			})

