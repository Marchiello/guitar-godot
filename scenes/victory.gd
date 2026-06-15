extends CanvasLayer

func _ready() -> void:
	# Pausa o jogo (esteira para de rodar, etc)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = preload("res://assets/victorysong.mp3")
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(bgm_player)
	bgm_player.play()

func _on_btn_proxima_fase_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_fases.tscn")

func _on_btn_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/tela_inicial.tscn")
