extends Control

@onready var botao_fase_1 = $BotaoFase1
@onready var botao_fase_2 = $BotaoFase2
@onready var botao_fase_3 = $BotaoFase3

func _ready():
	# O botão 1 sempre fica liberado
	botao_fase_1.disabled = false
	
	# O botão 2 só libera se a fase máxima liberada for maior ou igual a 2
	botao_fase_2.disabled = ProgressoJogo.fase_maxima_liberada < 2
	
	# O botão 3 só libera se a fase máxima liberada for maior ou igual a 3
	botao_fase_3.disabled = ProgressoJogo.fase_maxima_liberada < 3

# Conecte o sinal 'pressed' de cada botão respectivamente:
func _on_botao_fase_1_pressed():
	ProgressoJogo.carregar_fase(1)

func _on_botao_fase_2_pressed():
	ProgressoJogo.carregar_fase(2)

func _on_botao_fase_3_pressed():
	ProgressoJogo.carregar_fase(3)
