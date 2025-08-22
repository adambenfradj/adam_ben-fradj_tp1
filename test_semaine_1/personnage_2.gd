extends Node2D

func _ready() -> void:
	print("jeu commencé")

#func _process(delta: float) -> void:
#	print("nouveau frame")

func _input(event: InputEvent) -> void:
	 if event is InputEventMouseButton and event.is_pressed():
		print("bouton pressé") 
		#modulate = Color.RED
		$move.animation = "handRaise"
