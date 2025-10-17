extends Camera2D

# ---------------- CONFIG ----------------
# D'après ta hiérarchie: Camera2D est sous CharacterBody2D et l'obstacle est "Area2D" au même niveau que le joueur.
var obstacle_path = "../../Area2D"   # mets à jour si tu renommes/déplaces l'Area2D

var zoom_closed = 0.8                # < 1.0 = plus proche
var zoom_open = 1.0                  # zoom normal
var zoom_duration = 0.35             # secondes pour atteindre la cible (approx)

# Camera shake
var shake_enabled = true
var shake_duration_on_enter = 0.25   # s
var shake_amplitude_on_enter = 12.0  # px
# ---------------------------------------

# Internes
var player = null          # la caméra est enfant du joueur → parent direct
var obstacle = null
var _fixed_pos = Vector2()

# Interpolation de zoom (sans Tween)
var _zoom_target = 1.0

# Shake (sans yield)
var _shaking = false
var _shake_time = 0.0
var _shake_duration = 0.0
var _shake_amplitude = 0.0
var _orig_offset = Vector2()

# RNG pour le shake
var rng = null  # RandomNumberGenerator

func _ready():
	# Active cette caméra
	make_current()

	# Caméra fixée où tu l'as posée
	_fixed_pos = global_position
	zoom = Vector2(zoom_open, zoom_open)
	_zoom_target = zoom_open

	# RNG pour le shake
	rng = RandomNumberGenerator.new()
	rng.randomize()

	# Le joueur = parent direct (Camera2D est enfant de CharacterBody2D)
	player = get_parent()

	# Récupère et connecte l'Area2D
	if has_node(obstacle_path):
		obstacle = get_node(obstacle_path)
		if obstacle is Area2D:
			if not obstacle.is_connected("body_entered", self, "_on_obstacle_body_entered"):
				obstacle.connect("body_entered", self, "_on_obstacle_body_entered")
			if not obstacle.is_connected("body_exited", self, "_on_obstacle_body_exited"):
				obstacle.connect("body_exited", self, "_on_obstacle_body_exited")
		else:
			push_warning("Le noeud à '%s' n'est pas un Area2D." % obstacle_path)
	else:
		push_warning("Chemin obstacle introuvable: %s" % obstacle_path)

func _process(delta):
	# 1) Caméra toujours fixe
	if global_position != _fixed_pos:
		global_position = _fixed_pos

	# 2) Zoom lissé vers la cible (sans Tween)
	# facteur basé sur la durée souhaitée (plus delta est grand, plus on avance)
	var alpha = 0.0
	if zoom_duration > 0.0:
		alpha = min(1.0, delta / zoom_duration)
	# Interpole le scalaire de zoom
	var current = zoom.x
	var next = lerp(current, _zoom_target, alpha)
	zoom = Vector2(next, next)

	# 3) Shake (sans yield)
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

func _on_obstacle_body_entered(body):
	# On zoome & shake seulement si c'est le joueur (parent direct)
	if body == player:
		_set_zoom_target(zoom_closed)
		if shake_enabled:
			_start_shake(shake_duration_on_enter, shake_amplitude_on_enter)

func _on_obstacle_body_exited(body):
	if body == player:
		_set_zoom_target(zoom_open)

# --- helpers ---
func _set_zoom_target(target):
	_zoom_target = target

func _start_shake(duration, amplitude):
	_shaking = true
	_shake_time = 0.0
	_shake_duration = duration
	_shake_amplitude = amplitude
	_orig_offset = offset
