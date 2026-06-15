extends Node

@export var note_scene: PackedScene
@export var audio_player: AudioStreamPlayer
@export var travel_time: float = 2.0
@export var esteira_mesh: Node3D
@export var scroll_speed: float = 2.0

@export var esteira_texture: Texture2D 

@export_group("Nós de Spawn (Origem)")
@export var spawn_markers: Array[Marker3D] = []

@export_group("Nós de Alvo (Destino)")
@export var target_markers: Array[Marker3D] = []

var spawn_positions: Array[Vector3] = []
var target_positions: Array[Vector3] = []

var chart_notes_queue: Array = []
var active_notes: Array = []
var bpm_events: Array = []
var fret_buttons_nodes: Array[Node] = []
var current_combo: int = 0
var max_combo: int = 0
var consecutive_misses: int = 0

var error_sounds: Array[AudioStream] = [
	preload("res://assets/ErrorSongs/Error1.ogg"),
	preload("res://assets/ErrorSongs/Error2.ogg"),
	preload("res://assets/ErrorSongs/Error3.ogg")
]
var error_audio_player: AudioStreamPlayer

const UI_SCENE = preload("res://scenes/ui.tscn")
const GAME_OVER_SCENE = preload("res://scenes/game_over.tscn")
const VICTORY_SCENE = preload("res://scenes/victory.tscn")
var ui_instance: CanvasLayer
var game_over_triggered: bool = false
var victory_triggered: bool = false

var resolution: float = 192.0

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
		
	var botoes_parent = get_node_or_null("../Botões")
	if botoes_parent:
		fret_buttons_nodes = botoes_parent.get_children()
		
	# Carrega de forma dinâmica as infos do Autoload ProgressoJogo
	if ProgressoJogo and ProgressoJogo.info_fases.has(ProgressoJogo.fase_atual):
		var fase_info = ProgressoJogo.info_fases[ProgressoJogo.fase_atual]
		load_chart_file(fase_info["chart"])
		if audio_player:
			audio_player.stream = load(fase_info["musica"])
	else:
		load_chart_file("res://assets/songs/notes.chart") # Fallback
	
	game_clock = 0.0
	audio_started = false
	current_combo = 0
	max_combo = 0
	consecutive_misses = 0
	game_over_triggered = false
	victory_triggered = false
	
	if not ui_instance:
		ui_instance = UI_SCENE.instantiate()
		add_child(ui_instance)
		
	if not error_audio_player:
		error_audio_player = AudioStreamPlayer.new()
		# Dá pra ajustar o volume aqui se ficar muito alto (ex: -5.0)
		error_audio_player.volume_db = 0.0
		add_child(error_audio_player)

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
	if game_over_triggered or victory_triggered: return
	
	if not audio_player:
		return
		
	if not audio_started:
		game_clock += delta
		if game_clock >= song_start_delay:
			audio_player.play()
			audio_started = true
	else:
		game_clock = audio_player.get_playback_position() + song_start_delay
		
	check_note_spawns(game_clock)
	update_active_notes(game_clock)
	
	# Verifica Condição de Vitória (todas as notas acabaram e a música parou)
	if audio_started and chart_notes_queue.is_empty() and active_notes.is_empty():
		if audio_player and not audio_player.playing:
			trigger_victory()

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
		elif event.is_action_released(lane_actions[lane]):
			check_release_attempt(lane)

# ==========================================================

func check_hit_attempt(lane: int) -> void:
	var hit_something = false
	for note in active_notes:
		if is_instance_valid(note) and note.active and note.lane == lane and not note.is_hit:

			if game_clock > note.target_time + hit_window:
				continue
				
			var time_difference = abs(game_clock - note.target_time)
			if time_difference <= hit_window:
				hit_note(note)
				hit_something = true
				break 

			if note.target_time > game_clock + hit_window:
				break
				
	if not hit_something:
		# Jogador apertou o botão na pista correta, mas não tinha nenhuma nota no tempo
		reset_combo()

# ==========================================================

func check_release_attempt(lane: int) -> void:
	for note in active_notes:
		if is_instance_valid(note) and note.active and note.lane == lane and note.is_hit and not note.is_released:
			if note.sustain_duration > 0.01:
				# Se soltou o botão antes do sustain acabar (com uma pequena margem de tolerância)
				if game_clock < note.target_time + note.sustain_duration - hit_window:
					note.drop_sustain()
					reset_combo()

# ==========================================================

func hit_note(note: Node3D) -> void:
	increment_combo()
	
	if fret_buttons_nodes.size() > note.lane:
		if fret_buttons_nodes[note.lane].has_method("show_hit_feedback"):
			fret_buttons_nodes[note.lane].show_hit_feedback()
			
	if note.sustain_duration > 0.01:
		note.hit_head()
	else:
		active_notes.erase(note)
		note.queue_free()

# ==========================================================

func check_note_spawns(current_time: float) -> void:
	while chart_notes_queue.size() > 0:
		var next_note = chart_notes_queue[0]
		var spawn_time = next_note["time"] - travel_time
		if current_time >= spawn_time:
			chart_notes_queue.remove_at(0)
			
			spawn_note(next_note["lane"], next_note["time"], next_note["sustain"])
		else:
			break

# ==========================================================

func spawn_note(lane: int, hit_time: float, sustain_time: float) -> void: 
	if not note_scene:
		return
		
	var note_instance = note_scene.instantiate()
	add_child(note_instance)
	
	note_instance.setup(
		spawn_positions[lane],
		target_positions[lane],
		hit_time,
		travel_time,
		lane,
		sustain_time 
	)
	active_notes.append(note_instance)

# ==========================================================

func update_active_notes(current_time: float) -> void:
	for i in range(active_notes.size() - 1, -1, -1):
		var note = active_notes[i]
		if is_instance_valid(note):
			note.update_position(current_time)
			
			# Checar miss por deixar passar
			if not note.is_hit and not note.get_meta("missed", false) and current_time > note.target_time + hit_window:
				note.set_meta("missed", true)
				reset_combo()
		else:
			active_notes.remove_at(i)

# ==========================================================

func increment_combo() -> void:
	if game_over_triggered: return
	
	consecutive_misses = 0
	current_combo += 1
	if current_combo > max_combo:
		max_combo = current_combo
		
	if ui_instance:
		ui_instance.update_combo(current_combo)

func reset_combo() -> void:
	if game_over_triggered: return
	
	consecutive_misses += 1
	
	# Toca o som de erro sorteado!
	if error_audio_player and error_sounds.size() > 0:
		error_audio_player.stream = error_sounds.pick_random()
		error_audio_player.play()
	
	current_combo = 0
	if ui_instance:
		ui_instance.reset_combo()
			
	if consecutive_misses >= 15:
		trigger_game_over()

func trigger_game_over() -> void:
	game_over_triggered = true
	if audio_player:
		audio_player.stop()
		
	var go_modal = GAME_OVER_SCENE.instantiate()
	add_child(go_modal)

func trigger_victory() -> void:
	victory_triggered = true
	if ProgressoJogo:
		ProgressoJogo.unlock_next_fase()
		
	var victory_modal = VICTORY_SCENE.instantiate()
	add_child(victory_modal)

# ==========================================================

func tick_to_seconds(target_tick: int) -> float:
	if bpm_events.size() == 0:
		return target_tick * (60.0 / (120.0 * resolution))
		
	var last_ev = bpm_events[0]
	for ev in bpm_events:
		if ev["tick"] > target_tick:
			break
		last_ev = ev
		
	var ticks_diff = target_tick - last_ev["tick"]
	return last_ev["time_seconds"] + (ticks_diff * (60.0 / (last_ev["bpm"] * resolution)))

# ==========================================================

func load_chart_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	var section = ""
	
	resolution = 192.0 # Valor padrão
	chart_notes_queue.clear()
	
	var notes_by_tick: Dictionary = {}
	bpm_events.clear()
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.begins_with("[") and line.ends_with("]"):
			section = line.to_upper()
			continue
			
		if section == "[SONG]":
			if line.begins_with("Resolution ="):
				var parts = line.split("=", false)
				if parts.size() > 1:
					resolution = float(parts[1].strip_edges())
					
		elif section == "[SYNCTRACK]":
			if " = B " in line:
				var parts = line.split(" ", false)
				var tick = int(parts[0])
				var bpm = float(parts[3]) / 1000.0
				bpm_events.append({"tick": tick, "bpm": bpm})
			
		elif section == "[EXPERTSINGLE]":
			if " N " in line:
				var parts = line.split(" ", false) 
				var tick = int(parts[0])
				var lane = int(parts[3])
				var sustain_ticks = int(parts[4])
				
				if lane >= 0 and lane <= 4:
					if not notes_by_tick.has(tick):
						notes_by_tick[tick] = {}
					
					notes_by_tick[tick][lane] = {
						"lane": lane,
						"sustain_ticks": sustain_ticks
					}
			
			elif " S " in line:
				var parts = line.split(" ", false)
				var tick = int(parts[0])
				var lane = int(parts[3])
				var sustain_ticks = int(parts[4])
				
				if lane >= 0 and lane <= 4:
					if not notes_by_tick.has(tick):
						notes_by_tick[tick] = {}
					
					if notes_by_tick[tick].has(lane):
						notes_by_tick[tick][lane]["sustain_ticks"] = sustain_ticks
					else:
						notes_by_tick[tick][lane] = {
							"lane": lane,
							"sustain_ticks": sustain_ticks
						}

	file.close()
	
	bpm_events.sort_custom(func(a, b): return a["tick"] < b["tick"])
	var current_time_sec = 0.0
	var last_tick_bpm = 0
	var current_bpm_val = 120.0
	if bpm_events.size() > 0:
		current_bpm_val = bpm_events[0]["bpm"]
		
	for i in range(bpm_events.size()):
		var ev = bpm_events[i]
		var ticks_since_last = ev["tick"] - last_tick_bpm
		current_time_sec += ticks_since_last * (60.0 / (current_bpm_val * resolution))
		ev["time_seconds"] = current_time_sec
		last_tick_bpm = ev["tick"]
		current_bpm_val = ev["bpm"]

	var all_ticks = notes_by_tick.keys()
	all_ticks.sort()
	
	for lane in range(5):
		var last_tick_in_lane = -1
		for tick in all_ticks:
			if notes_by_tick[tick].has(lane):
				if last_tick_in_lane != -1:
					var dist = tick - last_tick_in_lane
					if notes_by_tick[last_tick_in_lane][lane]["sustain_ticks"] > dist:
						# Limita o tamanho do sustain para não invadir a próxima nota
						# Deixa um pequeno gap de 0.0 ticks ou pode subtrair algo se quiser
						notes_by_tick[last_tick_in_lane][lane]["sustain_ticks"] = dist
				last_tick_in_lane = tick
	
	# Processamento final e conversão para a linha do tempo do jogo
	for tick in all_ticks:
		for lane in notes_by_tick[tick]:
			var note_data = notes_by_tick[tick][lane]
			var ticks_finais = int(note_data["sustain_ticks"])
			
			var time_in_seconds = tick_to_seconds(tick) + song_start_delay
			
			var sustain_duration = 0.0
			if ticks_finais > 0:
				sustain_duration = tick_to_seconds(tick + ticks_finais) - tick_to_seconds(tick)
			
			chart_notes_queue.append({
				"time": time_in_seconds,
				"lane": note_data["lane"],
				"sustain": sustain_duration
			})
		
	# Ordena a fila cronologicamente para o motor do jogo não se perder
	chart_notes_queue.sort_custom(func(a, b): return a["time"] < b["time"])
	print("📂 [MATEMÁTICA CORRIGIDA] Notas na fila com tamanho real: ", chart_notes_queue.size())
