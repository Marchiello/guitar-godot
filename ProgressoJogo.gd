extends Node

# Controla qual a maior fase que o jogador liberou
var fase_maxima_liberada: int = 3

# Estrutura de dados para guardar as configurações de cada fase
var info_fases = {
	0: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/Tutorial/song.ogg", "chart": "res://assets/songs/Tutorial/notes.chart", "album": "" },
	1: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/scom/song.ogg", "chart": "res://assets/songs/scom/notes.chart", "album": "res://assets/songs/scom/album.png" },
	2: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/Aerials/guitar.ogg", "chart": "res://assets/songs/Aerials/notes.chart", "album": "res://assets/songs/Aerials/album.webp" },
	3: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/Stereolove/song.mp3", "chart": "res://assets/songs/Stereolove/notes.chart", "album": "res://assets/songs/Stereolove/album.jpg" }
}

var recordes_combo = {
	0: 0,
	1: 0,
	2: 0,
	3: 0
}

# Variável temporária para a fase que está rodando agora
var fase_atual: int = 1

func atualizar_recorde(novo_combo: int) -> bool:
	if fase_atual in recordes_combo and novo_combo > recordes_combo[fase_atual]:
		recordes_combo[fase_atual] = novo_combo
		return true
	return false

func carregar_fase(numero_fase: int):
	if numero_fase in info_fases:
		fase_atual = numero_fase
		get_tree().change_scene_to_file(info_fases[numero_fase]["arquivo_cena"])

func unlock_next_fase():
	if fase_atual >= fase_maxima_liberada:
		fase_maxima_liberada = fase_atual + 1

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
