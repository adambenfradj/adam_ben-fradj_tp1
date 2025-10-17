extends CharacterBody2D

enum Etat { MARCHE, REPOS, SAUT, MORT }
var etat_courant := Etat.REPOS

var speed := 350
var jump_velocity := -650
var has_died := false
var physics_active := true

@onready var player_sprite = $Essai
@onready var animation_player = $AnimationPlayer
@export var push_force := 1000.0

var restart_delay := 1.0

func _physics_process(delta):
	# IMPORTANT : si le perso est mort, on ne touche plus aux états/animations
	if not physics_active:
		return

	var direction := Input.get_axis("marcher_2", "marcher")

	# -------- Etats sol/air (pas en mort) --------
	if not is_on_floor():
		etat_courant = Etat.SAUT
	elif direction == 0:
		etat_courant = Etat.REPOS
	else:
		etat_courant = Etat.MARCHE

	# -------- Gravité --------
	if not is_on_floor():
		velocity.y += 1150 * delta

	# -------- Saut --------
	if Input.is_action_just_pressed("sauter") and is_on_floor():
		velocity.y = jump_velocity
		$"../AudioStreamPlayer2D2".play()
		animation_player.play("sauter")

	# -------- Déplacement + flip --------
	if direction != 0:
		velocity.x = direction * speed
		if direction > 0:
			animation_player.play("marche")
			player_sprite.scale.x = abs(player_sprite.scale.x)   # droite
		else:
			animation_player.play("marche")
			player_sprite.scale.x = -abs(player_sprite.scale.x)  # gauche
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_on_floor():
			animation_player.stop()

	# -------- FSM (animations de confort) --------
	match etat_courant:
		Etat.SAUT:
			animation_player.play("sauter")
		Etat.REPOS:
			animation_player.play("RESET")
			velocity.x = 0
		Etat.MARCHE:
			animation_player.play("marche")
			velocity.x = direction * speed
		_:
			pass  # Etat.MORT ne fait rien ici

	move_and_slide()

	# -------- Poussée sur RigidBody2D --------
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var rigid_body = collision.get_collider()
			var push_direction = -collision.get_normal()
			rigid_body.apply_central_impulse(push_direction * push_force)
			velocity.y = -jump_velocity * 1

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://startgame_2d.tscn")

# === MORT & RESTART ===

func _on_area_2d_body_entered(body: Node2D) -> void:
	_die()

func _die() -> void:
	if has_died:
		return
	has_died = true
	physics_active = false          # <--- bloque toute la logique dans _physics_process
	velocity = Vector2.ZERO
	etat_courant = Etat.MORT

	# Effet visuel + son immédiats (au cas où l'anim n'a pas la piste)
	player_sprite.modulate = Color(1, 0, 0)  # rouge
	if $"../AudioStreamPlayer2D4":
		$"../AudioStreamPlayer2D4".play()

	# Joue l'anim "die" si elle existe, puis restart après
	if animation_player and animation_player.has_animation("die"):
		if not animation_player.animation_finished.is_connected(_on_anim_finished):
			animation_player.animation_finished.connect(_on_anim_finished)
		animation_player.play("die")
	else:
		_start_restart_timer()

func _on_anim_finished(anim_name) -> void:
	if str(anim_name) == "die":
		_start_restart_timer()

func _start_restart_timer() -> void:
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = restart_delay
	add_child(t)
	t.timeout.connect(_restart_scene)
	t.start()

func _restart_scene() -> void:
	get_tree().reload_current_scene()
