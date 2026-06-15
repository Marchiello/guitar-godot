extends Node

@export var note_scene: PackedScene
@export var audio_player: AudioStreamPlayer
@export var travel_time: float = 2.0
@export var esteira_mesh: Node3D
@export var scroll_speed: float = 2.0

# Certifique-se de arrastar a imagem da esteira aqui no Inspector!
@export var esteira_texture: Texture2D 

@export_group("Nós de Spawn (Origem)")
@export var spawn_markers: Array[Marker3D] = []

@export_group("Nós de Alvo (Destino)")
@export var target_markers: Array[Marker3D] = []

var spawn_positions: Array[Vector3] = []
var target_positions: Array[Vector3] = []

var chart_notes_queue: Array = []
var active_notes: Array = []

var resolution: float = 192.0
var current_bpm: float = 120.0 

@export var song_start_delay: float = 2.0 
@export var hit_window: float = 0.15

var game_clock: float = 0.0
var audio_started: bool = false

var esteira_material: StandardMaterial3D

var lane_actions: Array[String] = [
	"botao_verde",
	"botao_vermelho",
	"botao_amarelo",
	"botao_azul",
	"botao_laranja"
]

# ==========================================================
# ==========================================================
# ==========================================================

func _ready() -> void:
	if spawn_markers.size() != 5 or target_markers.size() != 5:
		push_error("Erro: Faltam marcadores de spawn ou alvo!")
		return

	for i in range(5):
		spawn_positions.append(spawn_markers[i].global_position)
		target_positions.append(target_markers[i].global_position)
		
	load_chart_file("res://assets/songs/notes.chart")
	
	game_clock = 0.0
	audio_started = false

	if esteira_mesh and esteira_texture:
		var malha_real: MeshInstance3D = null
		
		if esteira_mesh is MeshInstance3D:
			malha_real = esteira_mesh as MeshInstance3D
		else:
			if esteira_mesh.has_node("BracoGuitarra"):
				malha_real = esteira_mesh.get_node("BracoGuitarra") as MeshInstance3D
			
			if not malha_real:
				for filho in esteira_mesh.get_children(true):
					if filho is MeshInstance3D:
						malha_real = filho as MeshInstance3D
						break
		
		if malha_real:
			esteira_material = StandardMaterial3D.new()
			esteira_material.albedo_texture = esteira_texture
			esteira_material.uv1_repeat = true
			esteira_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
			
			esteira_material.uv1_rotate_within_bounds = true
			
			esteira_material.uv1_scale = Vector3(3.0, 1.0, 5.0)
			esteira_material.uv1_offset = Vector3(0.0, 0.0, 0.0)
			
			malha_real.set_surface_override_material(0, esteira_material)
			print("🎸 SUCESSO: Textura alinhada e rotacionada nativamente!")
	
# ==========================================================
			
func _process(delta: float) -> void:
	if not audio_player:
		return
		
	if not audio_started:
		game_clock += delta
		if game_clock >= song_start_delay:
			audio_player.play()
			audio_started = true
	else:
		game_clock = audio_player.get_playback_position() + song_start_delay

	if esteira_material:
		var uv_offset = fmod(game_clock * scroll_speed, 1.0)
		
		esteira_material.uv1_offset = Vector3(0.0,uv_offset, 0.0)

	check_note_spawns(game_clock)
	update_active_notes(game_clock)

# ==========================================================

func _input(event: InputEvent) -> void:
	for lane in range(5):
		if event.is_action_pressed(lane_actions[lane]):
			check_hit_attempt(lane)

# ==========================================================

func check_hit_attempt(lane: int) -> void:
	for note in active_notes:
		if is_instance_valid(note) and note.active and note.lane == lane:
			var time_difference = abs(game_clock - note.target_time)
			if time_difference <= hit_window:
				hit_note(note)
				return
			else:
				break

# ==========================================================

func hit_note(note: Node3D) -> void:
	active_notes.erase(note)
	note.queue_free()

# ==========================================================

func check_note_spawns(current_time: float) -> void:
	while chart_notes_queue.size() > 0:
		var next_note = chart_notes_queue[0]
		var spawn_time = next_note["time"] - travel_time
		if current_time >= spawn_time:
			chart_notes_queue.remove_at(0)
			spawn_note(next_note["lane"], next_note["time"])
		else:
			break

# ==========================================================

func spawn_note(lane: int, hit_time: float) -> void:
	if not note_scene:
		return
	var note_instance = note_scene.instantiate()
	add_child(note_instance)
	note_instance.setup(spawn_positions[lane], target_positions[lane], hit_time, travel_time, lane)
	active_notes.append(note_instance)

# ==========================================================

func update_active_notes(current_time: float) -> void:
	for i in range(active_notes.size() - 1, -1, -1):
		var note = active_notes[i]
		if is_instance_valid(note):
			note.update_position(current_time)
		else:
			active_notes.remove_at(i)


# ==========================================================

func load_chart_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	var section = ""
	current_bpm = 111.271
	resolution = 192.0
	chart_notes_queue.clear()
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.begins_with("[") and line.ends_with("]"):
			section = line.to_upper()
			continue
		if section == "[EXPERTSINGLE]":
			if " N " in line:
				var parts = line.split(" ", false) 
				var tick = int(parts[0])
				var lane = int(parts[3])
				if lane >= 0 and lane <= 4:
					var time_in_seconds = (tick * (60.0 / (current_bpm * resolution))) + song_start_delay
					var note_data = {
						"time": time_in_seconds,
						"lane": lane
					}
					chart_notes_queue.append(note_data)
	file.close()
	chart_notes_queue.sort_custom(func(a, b): return a["time"] < b["time"])
