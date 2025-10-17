extends Area2D

var velocity = Vector2()
var gravity_force = 800.0       # force de gravité (px/s²)
var max_fall_speed = 1200.0     # vitesse max de chute
var kill_y = 1200.0             # seuil en Y où on détruit la boule (hors écran)

func _process(delta):
	# applique la "gravité"
	velocity.y += gravity_force * delta
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

	# déplace l’Area2D
	position += velocity * delta

	# supprime si trop bas
	if global_position.y > kill_y:
		queue_free()
