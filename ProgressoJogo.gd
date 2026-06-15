extends Node

# Controla qual a maior fase que o jogador liberou
var fase_maxima_liberada: int = 3

# Estrutura de dados para guardar as configurações de cada fase
var info_fases = {
	1: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/scom/song.ogg", "chart": "res://assets/songs/scom/notes.chart" },
	2: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/Aerials/guitar.ogg", "chart": "res://assets/songs/Aerials/notes.chart" },
	3: { "arquivo_cena": "res://scenes/game.tscn", "musica": "res://assets/songs/Stereolove/song.mp3", "chart": "res://assets/songs/Stereolove/notes.chart" }
}

# Variável temporária para a fase que está rodando agora
var fase_atual: int = 1

func carregar_fase(numero_fase: int):
	if numero_fase in info_fases:
		fase_atual = numero_fase
		get_tree().change_scene_to_file(info_fases[numero_fase]["arquivo_cena"])

func unlock_next_fase():
	if fase_atual >= fase_maxima_liberada:
		fase_maxima_liberada = fase_atual + 1
