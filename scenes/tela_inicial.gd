extends Control

func _ready() -> void:
	# Garante que o jogo não está pausado caso o usuário volte de um jogo abortado
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_fases.tscn")

func _on_btn_sair_pressed() -> void:
	get_tree().quit()
