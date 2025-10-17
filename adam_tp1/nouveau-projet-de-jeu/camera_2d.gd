extends Camera2D

# --- CONFIG ---
var zoom_closed: float = 0.8
var zoom_open: float = 1.0
var zoom_duration: float = 0.35

var shake_enabled: bool = true
var shake_duration_on_enter: float = 0.25
var shake_amplitude_on_enter: float = 12.0

# --- Internes ---
var player: Node = null
var _fixed_pos: Vector2 = Vector2.ZERO
var _zoom_target: float = 1.0

# Shake
var _shaking: bool = false
var _shake_time: float = 0.0
var _shake_duration: float = 0.0
var _shake_amplitude: float = 0.0
var _orig_offset: Vector2 = Vector2.ZERO

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	enabled = true

	# Caméra fixée
	_fixed_pos = global_position
	zoom = Vector2(zoom_open, zoom_open)
	_zoom_target = zoom_open

	rng.randomize()
	player = get_parent()

	# Récupère TOUS les Area2D dans le groupe "obstacles"
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	for area in obstacles:
		if area is Area2D:
			# Connecte leurs signaux
			if area.body_entered.is_connected(_on_obstacle_body_entered):
				area.body_entered.disconnect(_on_obstacle_body_entered)
			if area.body_exited.is_connected(_on_obstacle_body_exited):
				area.body_exited.disconnect(_on_obstacle_body_exited)
			area.body_entered.connect(_on_obstacle_body_entered)
			area.body_exited.connect(_on_obstacle_body_exited)

func _process(delta: float) -> void:
	# 1) Caméra fixe
	if global_position != _fixed_pos:
		global_position = _fixed_pos

	# 2) Zoom lissé
	var alpha: float = 0.0
	if zoom_duration > 0.0:
		alpha = min(1.0, delta / zoom_duration)
	var cur_zoom: float = zoom.x
	var next: float = lerp(cur_zoom, _zoom_target, alpha)
	zoom = Vector2(next, next)

	# 3) Shake
	if _shaking:
		_shake_time += delta
		if _shake_time < _shake_duration:
			offset = _orig_offset + Vector2(
				rng.randf_range(-_shake_amplitude, _shake_amplitude),
				rng.randf_range(-_shake_amplitude, _shake_amplitude)
			)
		else:
			offset = _orig_offset
			_shaking = false

func _on_obstacle_body_entered(body: Node) -> void:
	if body == player:
		_zoom_target = zoom_closed
		if shake_enabled:
			_start_shake(shake_duration_on_enter, shake_amplitude_on_enter)

func _on_obstacle_body_exited(body: Node) -> void:
	if body == player:
		_zoom_target = zoom_open

# --- Helpers ---
func _start_shake(duration: float, amplitude: float) -> void:
	_shaking = true
	_shake_time = 0.0
	_shake_duration = duration
	_shake_amplitude = amplitude
	_orig_offset = offset
