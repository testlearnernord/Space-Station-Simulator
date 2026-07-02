extends Node2D

class Station:
	var name: String
	var position: Vector2
	var base_price: float
	var distance: float
	var supply: int
	var demand: int
	var event_mod: float

	func _init(station_name: String, station_position: Vector2, station_base_price: float, station_supply: int, station_demand: int, station_distance: float, station_event_mod: float) -> void:
		name = station_name
		position = station_position
		base_price = station_base_price
		supply = station_supply
		demand = station_demand
		distance = station_distance
		event_mod = station_event_mod


const STATION_COLOR := Color(0.3, 0.7, 1.0)
const PLAYER_COLOR := Color(1.0, 0.85, 0.2)
const CARGO_CAPACITY := 30
const SELL_PRICE_RATIO := 0.92

var stations: Array[Station] = [
	Station.new("Atlas Hub", Vector2(260, 160), 34.0, 50, 32, 4.0, 0.02),
	Station.new("Kepler Dock", Vector2(610, 220), 39.0, 28, 55, 11.0, 0.08),
	Station.new("Helios Yard", Vector2(430, 460), 31.0, 65, 24, 7.0, -0.03),
	Station.new("Nova Ring", Vector2(760, 420), 45.0, 20, 60, 15.0, 0.12)
]

var rng := RandomNumberGenerator.new()
var player_position := Vector2(130, 120)
var economy_accumulator := 0.0

var credits := 600
var cargo := 0
var status := "Move with WASD. Click near a station to buy/sell alloys."

@onready var hud_label: Label = $CanvasLayer/HudLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
	rng.seed = 424242
	update_hud()


func _process(delta: float) -> void:
	handle_movement(delta)

	economy_accumulator += delta
	if economy_accumulator >= 1.0:
		economy_accumulator = 0.0
		tick_economy()

	if credits >= 2000:
		status = "You win! Keep trading or share this page with friends."

	update_hud()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_trade_at_nearest_station()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.03, 0.04, 0.08), true)

	for station in stations:
		draw_circle(station.position, 20.0, STATION_COLOR)
		draw_string(ThemeDB.fallback_font, station.position + Vector2(-45.0, -30.0), station.name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14)
		draw_string(ThemeDB.fallback_font, station.position + Vector2(-45.0, 42.0), "Buy %d / Sell %d" % [int(round(get_buy_price(station))), int(round(get_sell_price(station)))], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)

	draw_circle(player_position, 10.0, PLAYER_COLOR)
	draw_string(ThemeDB.fallback_font, player_position + Vector2(14.0, 4.0), "YOU", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)


func handle_movement(delta: float) -> void:
	var movement := Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		movement.x -= 1.0
	if Input.is_action_pressed("move_right"):
		movement.x += 1.0
	if Input.is_action_pressed("move_up"):
		movement.y -= 1.0
	if Input.is_action_pressed("move_down"):
		movement.y += 1.0

	if movement == Vector2.ZERO:
		return

	var speed := 240.0
	var viewport_size := get_viewport_rect().size
	player_position += movement.normalized() * speed * delta
	player_position = player_position.clamp(Vector2(24, 24), viewport_size - Vector2(24, 24))


func tick_economy() -> void:
	for station in stations:
		station.supply = clampi(station.supply + rng.randi_range(-4, 4), 8, 90)
		station.demand = clampi(station.demand + rng.randi_range(-4, 4), 8, 90)
		station.event_mod = clampf(station.event_mod + rng.randf_range(-0.01, 0.01), -0.25, 0.25)


func try_trade_at_nearest_station() -> void:
	if stations.is_empty():
		status = "No stations are available in this scenario."
		return

	var target := find_closest_station()
	if target == null:
		status = "No station nearby. Move closer before trading."
		return

	if cargo == 0:
		var buy_price := int(ceil(get_buy_price(target)))
		var affordable := 0 if buy_price <= 0 else int(credits / buy_price)
		var units_to_buy := mini(mini(5, affordable), mini(CARGO_CAPACITY - cargo, target.supply))

		if units_to_buy <= 0:
			status = "Not enough credits or supply to buy cargo."
			return

		credits -= units_to_buy * buy_price
		cargo += units_to_buy
		target.supply -= units_to_buy
		target.demand += units_to_buy
		status = "Bought %d alloys at %d cr each from %s." % [units_to_buy, buy_price, target.name]
		return

	var sell_price := int(floor(get_sell_price(target)))
	var units_to_sell := mini(5, mini(cargo, target.demand))

	if units_to_sell <= 0:
		status = "%s has no demand right now. Try another station." % target.name
		return

	credits += units_to_sell * maxi(1, sell_price)
	cargo -= units_to_sell
	target.demand -= units_to_sell
	target.supply += units_to_sell
	status = "Sold %d alloys at %d cr each to %s." % [units_to_sell, sell_price, target.name]


func find_closest_station() -> Station:
	if stations.is_empty():
		return null

	var closest_station := stations[0]
	var best_distance := player_position.distance_to(closest_station.position)

	for i in range(1, stations.size()):
		var station := stations[i]
		var distance := player_position.distance_to(station.position)
		if distance < best_distance:
			best_distance = distance
			closest_station = station

	return closest_station if best_distance <= 85.0 else null


func market_price(base_price: float, supply: int, demand: int, distance: float, faction_tax: float, event_mod: float) -> float:
	var sd := float(supply + 1) / float(demand + 1)
	var scarcity := maxf(0.2, 1.0 / sd)
	var dist_factor := 1.0 + distance * 0.01
	var raw := base_price * scarcity * dist_factor * (1.0 + faction_tax) * (1.0 + event_mod)
	var min_price := maxf(0.01, base_price * 0.1)
	var clamped_price := maxf(min_price, raw)
	return round(clamped_price * 100.0) / 100.0


func get_buy_price(station: Station) -> float:
	return market_price(station.base_price, station.supply, station.demand, station.distance, 0.05, station.event_mod)


func get_sell_price(station: Station) -> float:
	var reference := market_price(station.base_price, station.supply, station.demand, station.distance + 2.0, 0.0, station.event_mod)
	return maxf(1.0, round(reference * SELL_PRICE_RATIO))


func update_hud() -> void:
	hud_label.text = "Credits: %d   Cargo: %d/%d   Goal: 2000" % [credits, cargo, CARGO_CAPACITY]
	status_label.text = status
