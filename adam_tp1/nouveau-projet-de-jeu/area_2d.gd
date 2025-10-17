extends Area2D
 
var gravity_force = 500 # pixels par seconde^2
var velocity = Vector2()
 
func _physics_process(delta):
	velocity.y += gravity_force * delta
	position += velocity * delta
