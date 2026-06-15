extends Node3D

@export var texture_inactive: Texture2D
@export var texture_active: Texture2D
@export var texture_hit: Texture2D
@export var input_action: String = ""

@onready var sprite: Sprite3D = $Textura

var is_pressed: bool = false

func _ready() -> void:
	if texture_inactive:
		sprite.texture = texture_inactive
	sprite.modulate = Color(1, 1, 1, 1)

func _input(event: InputEvent) -> void:
	if input_action == "":
		return
		
	if event.is_action_pressed(input_action):
		is_pressed = true
		# Aplica a textura ativa e injeta um multiplicador de 2.0 na cor (Glow ativo!)
		set_visual_state(texture_active, 2.5) 
	elif event.is_action_released(input_action):
		is_pressed = false
		# Volta para a textura inativa com cor normal (sem glow)
		set_visual_state(texture_inactive, 1.0)

func set_visual_state(new_texture: Texture2D, glow_intensity: float) -> void:
	if sprite and new_texture:
		sprite.texture = new_texture
		# O truque mágico: multiplicando a cor branca pura (1,1,1) pela intensidade,
		# nós passamos do limite do HDR e o WorldEnvironment faz o sprite BRILHAR.
		sprite.modulate = Color(1, 1, 1) * glow_intensity

func show_hit_feedback() -> void:
	# Usar call_deferred evita a condição de corrida onde o _input deste botão 
	# poderia sobrescrever a textura voltando para texture_active na mesma frame!
	call_deferred("_apply_hit_feedback")

func _apply_hit_feedback() -> void:
	if is_pressed:
		set_visual_state(texture_hit, 3.0)
