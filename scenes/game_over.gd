extends CanvasLayer

func _ready() -> void:
	# Pausa toda a árvore do jogo para a música e esteira pararem
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Cria o player de áudio dinamicamente para o Game Over
	var bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = preload("res://assets/ErrorSongs/MuitoFei.ogg")
	# Fundamental: PROCESS_MODE_ALWAYS faz ele tocar mesmo com o jogo pausado!
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(bgm_player)
	bgm_player.play()

func _on_btn_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_fases.tscn")
