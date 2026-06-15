extends CanvasLayer

@onready var combo_label: Label = $ComboLabel

func _ready() -> void:
	# Define o pivot no centro para que a animação de pulo cresça a partir do meio
	combo_label.pivot_offset = combo_label.size / 2

func update_combo(current_combo: int) -> void:
	combo_label.text = "Combo: " + str(current_combo)
	
	var should_jump = false
	if current_combo > 0:
		if current_combo < 50:
			if current_combo % 10 == 0:
				should_jump = true
		else:
			if current_combo % 50 == 0:
				should_jump = true
				
	if should_jump:
		var tween = create_tween()
		combo_label.scale = Vector2(1.4, 1.4)
		tween.tween_property(combo_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SPRING)

var color_tween: Tween

func reset_combo() -> void:
	combo_label.text = "Combo: 0"
	
	if color_tween and color_tween.is_valid():
		color_tween.kill()
		
	color_tween = create_tween()
	combo_label.modulate = Color(1, 0, 0)
	color_tween.tween_property(combo_label, "modulate", Color(1, 1, 1), 0.3)
