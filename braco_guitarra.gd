extends MeshInstance3D

@export var velocidade_esteira : float = 2.0
@export var audio_player: AudioStreamPlayer

var fretboard_material: StandardMaterial3D

# ==========================================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if material_override is StandardMaterial3D:
		#fretboard_material = material_override as StandardMaterial3D
	#else:
		#push_error("Erro: Certifique-se de que o material da pista é um StandardMaterial3D aplicado no 'Material Override'.")
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
	pass
	
# ==========================================================
	
func _process(delta):
	if not audio_player or not audio_player.playing:
		return
		
	# 1. Pega o tempo exato em segundos do áudio atual
	var current_time = audio_player.get_playback_position()
	
	# 2. Se a sua lógica de notas usar o tempo corrigido com a latência do áudio, use ele aqui:
	# var current_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

	# 3. Calcula o novo deslocamento no eixo Y da textura
	# O operador fmod(valor, 1.0) impede que o número cresça infinitamente, mantendo-o entre 0.0 e 1.0
	var offset_y = fmod(current_time * velocidade_esteira, 1.0)
	
	# 4. Aplica o deslocamento diretamente na propriedade UV1 do material
	if fretboard_material:
		fretboard_material.uv1_offset.y = offset_y
