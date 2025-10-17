extends Node2D

@onready var pause_menu: CanvasLayer = $PauseMenu  # ton CanvasLayer

func _ready() -> void:
	if pause_menu:
		# En Godot 4, l'UI doit être en WHEN_PAUSED pour recevoir input en pause
		pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		pause_menu.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):   # action "pause" mappée sur Échap
		var now_paused := not get_tree().paused
		get_tree().paused = now_paused
		if pause_menu:
			pause_menu.visible = now_paused
