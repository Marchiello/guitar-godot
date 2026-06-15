extends CanvasLayer

var stats_hits: int = 0
var stats_wrongs: int = 0
var stats_misses: int = 0
var stats_combo: int = 0

func setup_metrics(h: int, w: int, m: int, mc: int) -> void:
	stats_hits = h
	stats_wrongs = w
	stats_misses = m
	stats_combo = mc

func _ready() -> void:
	# Atualiza o texto dos status
	var label = get_node_or_null("Panel/VBoxContainer/MetricsLabel")
	if label:
		label.text = "Acertos: %d   |   Erros: %d   |   Perdidas: %d\nMaior Combo: %d" % [stats_hits, stats_wrongs, stats_misses, stats_combo]
		
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
