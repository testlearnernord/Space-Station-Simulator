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


const STATION_COLOR := Color(0.35, 0.75, 1.0)
const PLAYER_COLOR := Color(1.0, 0.86, 0.25)
const CARGO_CAPACITY := 30
const SELL_PRICE_RATIO := 0.92
const SELL_DISTANCE_OFFSET := 2.0

const ACCELERATION := 520.0
const DRAG := 360.0
const BASE_MAX_SPEED := 250.0
const BOOST_MULTIPLIER := 1.75
const DOCK_RANGE := 150.0
const DOCK_HOLD_TIME := 1.2

const HUMAN_FIRST := ["Nova", "Aurora", "Helios", "Kepler", "Atlas", "Vanguard", "Orion", "Argent", "Sol", "Pioneer"]
const HUMAN_LAST := ["Bastion", "Reach", "Harbor", "Ring", "Terminal", "Spire", "Yard", "Dock", "Station", "Port"]
const ALIEN_SYL_A := ["Xel", "Vra", "Qin", "Zho", "Taa", "Myr", "Kri", "Uul", "Ssa", "Nek"]
const ALIEN_SYL_B := ["'ra", "uun", "eth", "ix", "oq", "iri", "aal", "zen", "tor", "aak"]

var stations: Array[Station] = [
    Station.new("", Vector2(260, 160), 34.0, 50, 32, 4.0, 0.02),
    Station.new("", Vector2(610, 220), 39.0, 28, 55, 11.0, 0.08),
    Station.new("", Vector2(430, 460), 31.0, 65, 24, 7.0, -0.03),
    Station.new("", Vector2(760, 420), 45.0, 20, 60, 15.0, 0.12)
]

var rng := RandomNumberGenerator.new()
var player_position := Vector2(130, 120)
var player_velocity := Vector2.ZERO
var player_rotation := 0.0
var economy_accumulator := 0.0
var visual_time := 0.0

var credits := 600
var cargo := 0
var has_own_station := false
var is_docked := false
var docking_station: Station = null
var docking_progress := 0.0
var engine_sound_cooldown := 0.0
var was_dock_held := false
var goal_reached_announced := false
var status := "Fly with WASD, hold C near station to dock, click to trade while docked."

var stars: Array[Dictionary] = []

var engine_player: AudioStreamPlayer
var boost_player: AudioStreamPlayer
var dock_start_player: AudioStreamPlayer
var dock_complete_player: AudioStreamPlayer

@onready var hud_label: Label = $CanvasLayer/HudLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
    rng.set_seed(424242)
    generate_station_names()
    generate_starfield()
    setup_audio()
    update_hud()


func _process(delta: float) -> void:
    visual_time += delta
    engine_sound_cooldown = maxf(0.0, engine_sound_cooldown - delta)
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
            status = "Docked at %s. Left click to trade. Move to undock." % docking_station.name
    else:
        handle_movement(delta, boost_active)
        update_docking(delta)

    economy_accumulator += delta
    if economy_accumulator >= 1.0:
        economy_accumulator = 0.0
        tick_economy()

    if credits >= 2000 and not has_own_station and not goal_reached_announced:
        goal_reached_announced = true
        status = "Goal reached! Keep trading, or build your own station at 2600 credits."

    if credits >= 2600 and not has_own_station:
        has_own_station = true
        status = "You founded your own station network!"

    update_hud()
    queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        try_trade()


func _draw() -> void:
    draw_space_background()

    for i in range(stations.size()):
        draw_station(stations[i], i)

    if has_own_station:
        draw_own_station_emblem()
    else:
        draw_ship(player_position, player_rotation)


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


func draw_station(station: Station, index: int) -> void:
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

    draw_string(ThemeDB.fallback_font, station.position + Vector2(-64.0, -34.0), station.name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14)
    draw_string(ThemeDB.fallback_font, station.position + Vector2(-64.0, 46.0), "Buy %d / Sell %d" % [int(round(get_buy_price(station))), int(round(get_sell_price(station)))], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)


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
    player_position = player_position.clamp(Vector2(24, 24), viewport_size - Vector2(24, 24))


func update_docking(delta: float) -> void:
    var dock_pressed := Input.is_key_pressed(KEY_C)
    var candidate := find_closest_station(DOCK_RANGE)
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

    if not was_dock_held:
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
        dock_complete_player.play()

    was_dock_held = dock_pressed


func try_trade() -> void:
    if not is_docked or docking_station == null:
        status = "Trade is only possible while docked. Hold C near a station first."
        return

    var target := docking_station

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


func find_closest_station(max_distance: float) -> Station:
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

    return closest_station if best_distance <= max_distance else null


func get_dock_point(station: Station) -> Vector2:
    return station.position + Vector2(34.0, 0.0)


func tick_economy() -> void:
    for station in stations:
        station.supply = clampi(station.supply + rng.randi_range(-4, 4), 8, 90)
        station.demand = clampi(station.demand + rng.randi_range(-4, 4), 8, 90)
        station.event_mod = clampf(station.event_mod + rng.randf_range(-0.01, 0.01), -0.25, 0.25)


func generate_station_names() -> void:
    var used := {}
    for station in stations:
        var generated := ""
        while generated == "" or used.has(generated):
            generated = generate_random_station_name()
        station.name = generated
        used[generated] = true


func generate_random_station_name() -> String:
    if rng.randf() < 0.5:
        return "%s %s" % [HUMAN_FIRST[rng.randi_range(0, HUMAN_FIRST.size() - 1)], HUMAN_LAST[rng.randi_range(0, HUMAN_LAST.size() - 1)]]
    return "%s%s Enclave" % [ALIEN_SYL_A[rng.randi_range(0, ALIEN_SYL_A.size() - 1)], ALIEN_SYL_B[rng.randi_range(0, ALIEN_SYL_B.size() - 1)]]


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
    var sample_count := maxi(1, int(duration * sample_rate))
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
    var reference := market_price(station.base_price, station.supply, station.demand, station.distance + SELL_DISTANCE_OFFSET, 0.0, station.event_mod)
    return maxf(1.0, round(reference * SELL_PRICE_RATIO))


func update_hud() -> void:
    var dock_text := "Docked" if is_docked else "Undocked"
    if docking_station != null and not is_docked and docking_progress > 0.0 and Input.is_key_pressed(KEY_C):
        dock_text = "Docking %d%%" % int(round(100.0 * docking_progress / DOCK_HOLD_TIME))
    hud_label.text = "Credits: %d   Cargo: %d/%d   %s   Boost: Shift" % [credits, cargo, CARGO_CAPACITY, dock_text]
    status_label.text = status
