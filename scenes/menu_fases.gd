extends Control

@onready var btn_fase2: Button = $BotoesContainer/BtnFase2
@onready var btn_fase3: Button = $BotoesContainer/BtnFase3

func _ready() -> void:
	# Despausa o jogo
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var max_fase = 1
	if ProgressoJogo:
		max_fase = ProgressoJogo.fase_maxima_liberada
	
	if max_fase < 2:
		btn_fase2.disabled = true
		btn_fase2.modulate = Color(0.3, 0.3, 0.3)
	
	if max_fase < 3:
		btn_fase3.disabled = true
		btn_fase3.modulate = Color(0.3, 0.3, 0.3)

func _on_btn_tutorial_pressed() -> void:
	if ProgressoJogo: ProgressoJogo.carregar_fase(0)

func _on_btn_fase1_pressed() -> void:
	if ProgressoJogo: ProgressoJogo.carregar_fase(1)

func _on_btn_fase2_pressed() -> void:
	if ProgressoJogo: ProgressoJogo.carregar_fase(2)

func _on_btn_fase3_pressed() -> void:
	if ProgressoJogo: ProgressoJogo.carregar_fase(3)

func _on_btn_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tela_inicial.tscn")
