extends Node3D

@export var textures: Array[Texture2D] = []

var start_position: Vector3
var end_position: Vector3
var target_time: float = 0.0
var travel_time: float = 2.0
var spawn_time: float = 0.0
var active: bool = true
var lane: int = 0

var sprite: Sprite3D

# ==========================================================

func setup(start_pos: Vector3, end_pos: Vector3, hit_time: float, current_travel_time: float, lane_index: int) -> void:
	start_position = start_pos
	end_position = end_pos
	target_time = hit_time
	travel_time = current_travel_time
	lane = lane_index # <-- SALVA A LANE AQUI!
	
	spawn_time = target_time - travel_time
	global_position = start_position
	
	sprite = get_node("Textura") as Sprite3D
	if sprite and lane >= 0 and lane < textures.size():
		sprite.texture = textures[lane]

# ==========================================================

func update_position(current_game_time: float) -> void:
	if not active:
		return
		
	var elapsed = current_game_time - spawn_time
	var progress = elapsed / travel_time
	
	# Previne saltos visuais bizarros limitando o escopo do lerp
	progress = clamp(progress, 0.0, 1.5)
	
	global_position = start_position.lerp(end_position, progress)
	
	if progress > 1.15: 
		destroy_note_miss()

# ==========================================================

func get_progress(current_game_time: float) -> float:
	var elapsed = current_game_time - spawn_time
	return elapsed / travel_time

# ==========================================================

func destroy_note_miss() -> void:
	active = false
	queue_free()
