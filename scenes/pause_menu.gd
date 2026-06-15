extends CanvasLayer

func _ready() -> void:
	$Panel/VBoxContainer/BtnContinuar.pressed.connect(_on_continuar)
	$Panel/VBoxContainer/BtnSair.pressed.connect(_on_sair)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P or event.keycode == KEY_ESCAPE:
			_on_continuar()
			get_viewport().set_input_as_handled()

func _on_continuar() -> void:
	# O sistema de chart vai escutar tree_exited e despausar
	queue_free()

func _on_sair() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_fases.tscn")
