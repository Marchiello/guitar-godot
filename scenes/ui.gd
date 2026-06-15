extends CanvasLayer

@onready var combo_label: Label = $ComboLabel
@onready var album_rect: TextureRect = $AlbumRect
@onready var hits_label: Label = $MetricsContainer/HitsLabel
@onready var wrongs_label: Label = $MetricsContainer/WrongsLabel
@onready var misses_label: Label = $MetricsContainer/MissesLabel

func _ready() -> void:
	# Define o pivot no centro para que a animação de pulo cresça a partir do meio
	combo_label.pivot_offset = combo_label.size / 2

func update_combo(current_combo: int, is_record: bool = false) -> void:
	combo_label.text = "Combo: " + str(current_combo)
	
	if is_record:
		combo_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	else:
		combo_label.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))
	
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

func set_album_cover(texture_path: String) -> void:
	if album_rect and texture_path != "":
		var tex = load(texture_path)
		if tex:
			album_rect.texture = tex

func update_metrics(hits: int, wrongs: int, misses: int) -> void:
	if hits_label: hits_label.text = "Acertos: " + str(hits)
	if wrongs_label: wrongs_label.text = "Erros: " + str(wrongs)
	if misses_label: misses_label.text = "Perdidas: " + str(misses)

var tutorial_label: Label = null

func show_tutorial_text(text: String) -> void:
	if not tutorial_label:
		tutorial_label = Label.new()
		tutorial_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
		tutorial_label.position = Vector2(0, 400)
		tutorial_label.add_theme_font_size_override("font_size", 20)
		tutorial_label.add_theme_color_override("font_color", Color(1, 1, 1))
		tutorial_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		tutorial_label.add_theme_constant_override("outline_size", 8)
		tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(tutorial_label)
		
	tutorial_label.text = text
	tutorial_label.visible = text != ""
	
	# Centralizar manualmente após setar texto
	var vp = get_viewport()
	if vp:
		tutorial_label.position.x = (vp.get_visible_rect().size.x - tutorial_label.size.x) / 2
