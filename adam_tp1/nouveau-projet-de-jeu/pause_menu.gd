extends CanvasLayer

func _ready() -> void:
	# Assure-toi que le menu reçoit l'input en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	# Connecte les boutons (adapte les chemins si besoin)
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_continue() -> void:
	get_tree().paused = false
	visible = false

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://node_2d.tscn")
