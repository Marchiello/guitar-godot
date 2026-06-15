extends Control

@onready var btn_fase2: Button = $BotoesContainer/VBoxFase2/BtnFase2
@onready var btn_fase3: Button = $BotoesContainer/VBoxFase3/BtnFase3

@onready var lbl_recorde1: Label = $BotoesContainer/VBoxFase1/LblRecorde1
@onready var lbl_recorde2: Label = $BotoesContainer/VBoxFase2/LblRecorde2
@onready var lbl_recorde3: Label = $BotoesContainer/VBoxFase3/LblRecorde3

@onready var painel_zeramento: ColorRect = $PainelZeramento

var som_zeramento: AudioStreamPlayer = null

var click_count_fase3: int = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if btn_fase3 and btn_fase3.get_global_rect().has_point(event.global_position):
			click_count_fase3 += 1
			if click_count_fase3 >= 20:
				if ProgressoJogo and ProgressoJogo.fase_maxima_liberada < 3:
					ProgressoJogo.fase_maxima_liberada = 4 # Libera tudo (Fase 1, 2, 3)
					get_tree().reload_current_scene() # Atualiza os cadeados visuais

var hover_tweens = {}

func _ready() -> void:
	# Despausa o jogo
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var btn1 = $BotoesContainer/VBoxFase1/BtnFase1
	btn1.mouse_entered.connect(_on_btn_hover.bind(btn1, true))
	btn1.mouse_exited.connect(_on_btn_hover.bind(btn1, false))
	btn_fase2.mouse_entered.connect(_on_btn_hover.bind(btn_fase2, true))
	btn_fase2.mouse_exited.connect(_on_btn_hover.bind(btn_fase2, false))
	btn_fase3.mouse_entered.connect(_on_btn_hover.bind(btn_fase3, true))
	btn_fase3.mouse_exited.connect(_on_btn_hover.bind(btn_fase3, false))
	
	var max_fase = 1
	if ProgressoJogo:
		max_fase = ProgressoJogo.fase_maxima_liberada
		
		# Atualiza as labels de recorde
		lbl_recorde1.text = "Max Combo: " + str(ProgressoJogo.recordes_combo[1])
		lbl_recorde2.text = "Max Combo: " + str(ProgressoJogo.recordes_combo[2])
		lbl_recorde3.text = "Max Combo: " + str(ProgressoJogo.recordes_combo[3])
		
		# Verifica se zerou o jogo
		if max_fase > 3 and not ProgressoJogo.jogo_zerado_visto:
			ProgressoJogo.jogo_zerado_visto = true
			painel_zeramento.show()
			
			som_zeramento = AudioStreamPlayer.new()
			som_zeramento.stream = preload("res://assets/victorysong.mp3")
			add_child(som_zeramento)
			som_zeramento.play()
	
	if max_fase < 2:
		btn_fase2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn_fase2.modulate = Color(0.5, 0.5, 0.5, 1.0)
	
	if max_fase < 3:
		btn_fase3.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn_fase3.modulate = Color(0.5, 0.5, 0.5, 1.0)

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

func _on_btn_fechar_zeramento_pressed() -> void:
	painel_zeramento.hide()
	if som_zeramento:
		som_zeramento.stop()
		som_zeramento.queue_free()
		som_zeramento = null

func _on_btn_hover(btn: Button, is_hovered: bool) -> void:
	if btn.mouse_filter == Control.MOUSE_FILTER_IGNORE: return
	
	if hover_tweens.has(btn) and hover_tweens[btn]:
		hover_tweens[btn].kill()
		
	var tween = create_tween()
	hover_tweens[btn] = tween
	
	var solid_back = btn.get_node("SolidBack")
	
	if is_hovered:
		tween.set_parallel(true)
		tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(solid_back, "color", Color(0.2, 0.4, 0.6, 1.0), 0.1)
	else:
		tween.set_parallel(true)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(solid_back, "color", Color(0.2, 0.2, 0.25, 1.0), 0.1)
