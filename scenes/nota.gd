extends Node3D

@export var textures: Array[Texture2D] = []

var start_position: Vector3
var end_position: Vector3
var target_time: float
var travel_time: float
var spawn_time: float
var lane: int = 0
var sustain_duration: float = 0.0

var active: bool = true
var is_hit: bool = false
var is_released: bool = false

var sprite: Sprite3D
var sustain_mesh: MeshInstance3D

# ==========================================================

func setup(start_pos: Vector3, end_pos: Vector3, hit_time: float, current_travel_time: float, lane_index: int, sustain_time: float) -> void:
	start_position = start_pos
	end_position = end_pos
	target_time = hit_time
	travel_time = current_travel_time
	lane = lane_index
	sustain_duration = sustain_time
	
	spawn_time = target_time - travel_time
	global_position = start_position
	
	sprite = get_node("Textura") as Sprite3D
	if sprite and lane >= 0 and lane < textures.size():
		sprite.texture = textures[lane]
		
	sustain_mesh = get_node_or_null("PivotSustain/MeshSustain") as MeshInstance3D
	if sustain_mesh:
		# 🎯 MARGEM DE SEGURANÇA: Só liga se a duração for maior que 0.01 segundos (10ms)
		if sustain_duration > 0.01:
			sustain_mesh.visible = true
			
			var total_distance = start_position.distance_to(end_position)
			var speed = total_distance / travel_time
			var physical_length = sustain_duration * speed
			
			# 📐 ESCALA PURA:
			sustain_mesh.scale.x = 0.25
			sustain_mesh.scale.y = 0.02
			sustain_mesh.scale.z = physical_length
			
			# 📍 POSIÇÃO PURA:
			sustain_mesh.position.x = 0.0
			sustain_mesh.position.y = 0.0
			sustain_mesh.position.z = physical_length / 2.0
		else:
			# Se for uma nota simples, a malha FICA DESLIGADA!
			sustain_mesh.visible = false

# ==========================================================

func update_position(current_time: float) -> void:
	if not active:
		return
		
	if current_time > target_time + sustain_duration + 0.3:
		active = false
		queue_free()
		return

	var direction = (end_position - start_position).normalized()
	var total_distance = start_position.distance_to(end_position)
	var speed = total_distance / travel_time
	
	var time_until_hit = target_time - current_time
	var current_distance_from_target = time_until_hit * speed
	global_position = end_position - (direction * current_distance_from_target)
	
# ==========================================================

func get_progress(current_game_time: float) -> float:
	var elapsed = current_game_time - spawn_time
	return elapsed / travel_time

# ==========================================================

func hit_head() -> void:
	is_hit = true
	if sprite:
		sprite.visible = false
	
	# Opcional: Feedback visual de que está segurando
	if sustain_mesh:
		var mat = sustain_mesh.material_override as StandardMaterial3D
		if not mat:
			mat = StandardMaterial3D.new()
			# Tenta copiar o albedo do material original se existir
			var orig_mat = sustain_mesh.get_active_material(0) as StandardMaterial3D
			if orig_mat:
				mat.albedo_color = orig_mat.albedo_color
			sustain_mesh.material_override = mat
		
		mat.albedo_color = mat.albedo_color * 1.5 # Brilho leve

func drop_sustain() -> void:
	is_released = true
	if sustain_mesh:
		# Escurece a malha para indicar que perdeu o sustain
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 0.3, 0.3, 0.5)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sustain_mesh.material_override = mat

# ==========================================================

func destroy_note_miss() -> void:
	active = false
	queue_free()
