extends Node3D

@export var texture_inactive: Texture2D
@export var texture_active: Texture2D
@export var texture_hit: Texture2D
@export var input_action: String = ""

@onready var sprite: Sprite3D = $Textura
@onready var luz: OmniLight3D = $OmniLight

var is_pressed: bool = false

func _ready() -> void:
	if texture_inactive:
		sprite.texture = texture_inactive
	sprite.modulate = Color(1.5, 1.5, 1.5, 1.0)
	luz.light_energy = 0.0 # Luz apagada por padrão

func _input(event: InputEvent) -> void:
	if input_action == "":
		return
		
	if event.is_action_pressed(input_action):
		is_pressed = true
		set_visual_state(texture_active, 2.5) 
		luz.light_energy = 5.0 # Liga a luz ambiente
	elif event.is_action_released(input_action):
		is_pressed = false
		set_visual_state(texture_inactive, 1.5)
		luz.light_energy = 0.0 # Apaga a luz ambiente
		sprite.scale = Vector3(1.0, 1.0, 1.0) # Força a voltar pro tamanho normal se soltar rápido

var hit_tween: Tween

func set_visual_state(new_texture: Texture2D, glow_intensity: float) -> void:
	if hit_tween: hit_tween.kill()
	if sprite and new_texture:
		sprite.texture = new_texture
		sprite.modulate = Color(1, 1, 1) * glow_intensity

func show_hit_feedback() -> void:
	call_deferred("_apply_hit_feedback")

func _apply_hit_feedback() -> void:
	if is_pressed:
		if hit_tween: hit_tween.kill()
		sprite.texture = texture_hit
		
		# Explosão de Neon instantânea no Sprite E na Luz Ambiente!
		sprite.modulate = Color(1, 1, 1) * 35.0 
		luz.light_energy = 50.0
		
		# O Pulo da Animação (Juiciness)! O botão "estufa" pra 150% do tamanho
		sprite.scale = Vector3(1.5, 1.5, 1.5)
		
		# Cria a animação pra esfriar o neon e encolher
		hit_tween = create_tween()
		hit_tween.set_parallel(true) # Roda todas as animações ao mesmo tempo
		
		# Usa EASE_OUT com TRANS_CUBIC para dar aquele soco forte no começo que suaviza no final
		hit_tween.tween_property(sprite, "modulate", Color(1, 1, 1) * 2.5, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		hit_tween.tween_property(luz, "light_energy", 5.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		hit_tween.tween_property(sprite, "scale", Vector3(1.0, 1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
