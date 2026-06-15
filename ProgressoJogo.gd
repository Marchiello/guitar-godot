extends Node

# Controla qual a maior fase que o jogador liberou
var fase_maxima_liberada: int = 1

# Estrutura de dados para guardar as configurações de cada fase
var info_fases = {
	1: { "arquivo_cena": "res://cenas/Game.tscn", "musica": "res://audio/musica_fase1.mp3" },
	2: { "arquivo_cena": "res://cenas/Game.tscn", "musica": "res://audio/musica_fase2.mp3" },
	3: { "arquivo_cena": "res://cenas/Game.tscn", "musica": "res://audio/musica_fase3.mp3" }
}

# Variável temporária para a fase que está rodando agora
var fase_atual: int = 1

func carregar_fase(numero_fase: int):
	if numero_fase in info_fases:
		fase_atual = numero_fase
		# Aqui você muda para a cena genérica do Game
		get_tree().change_scene_to_file(info_fases[numero_fase]["arquivo_cena"])
