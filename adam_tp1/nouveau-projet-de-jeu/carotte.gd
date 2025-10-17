extends Area2D

var taken = false
func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

	if taken:
		return
	if body is CharacterBody2D:
		taken=true
		$AnimationPlayer.play("taken")
		$"../AudioStreamPlayer2D3".play()
