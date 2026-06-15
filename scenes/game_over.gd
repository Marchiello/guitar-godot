extends CanvasLayer

func _ready() -> void:
	# Pausa toda a árvore do jogo para a música e esteira pararem
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_fases.tscn")
