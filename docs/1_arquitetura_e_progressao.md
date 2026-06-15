# Aula 1: O Cérebro do Jogo (Arquitetura e Progressão)

Imagine que o seu jogo é um teatro. Cada "Fase" ou "Menu" é uma cena no palco.
Quando o Godot muda do "Menu" para a "Fase 1", ele apaga a luz, demite todos os atores, joga o cenário fora e constrói tudo de novo do zero.

**O Problema:** Se tudo é jogado no lixo, como o jogo vai lembrar que você bateu o recorde de 100 pontos? A pontuação foi jogada no lixo também!

## A Solução: O "Autoload" (O Gerente do Teatro)
No Godot, nós podemos criar um arquivo especial chamado de **Autoload** (ou Singleton). Ele é como um gerente que fica sentado lá no teto do teatro, assistindo as cenas mudarem. Ele **nunca** é destruído!

No nosso projeto, nós criamos um script chamado `ProgressoJogo.gd` e avisamos pro Godot (lá em `Project -> Project Settings -> Autoload`) que ele é o gerente.

### O Dicionário de Fases (O Fichário do Gerente)
Como o gerente sabe quais músicas existem? Nós ensinamos a ele usando uma coisa da programação chamada **Dicionário** (ou `Dictionary`). Um Dicionário é literalmente como uma gaveta de arquivos com etiquetas.

```gdscript
var info_fases = {
	# Gaveta número 0 (O Tutorial)
	0: { "arquivo_cena": "res://scenes/game.tscn", "musica": "tutorial.ogg", "chart": "tutorial.chart" },
	
	# Gaveta número 1 (Fase 1)
	1: { "arquivo_cena": "res://scenes/game.tscn", "musica": "rock.ogg", "chart": "rock.chart" }
}

var fase_atual: int = 1 # O Gerente anota no post-it: "O jogador está na fase 1"
```

**Por que isso é genial para você?**
Veja que todas as gavetas usam o MESMO `"arquivo_cena": "game.tscn"`.
Nós só construímos o palco de tocar guitarra **uma única vez**! Se você tem 50 músicas, você não vai criar 50 fases! Você manda o Godot abrir o palco `game.tscn`, e o palco grita para o gerente lá no teto: *"Ôh Chefe! Qual é a música que o jogador escolheu?"*. O gerente lê o post-it (`fase_atual`) e devolve o arquivo de som certo.

### Condicionais (O porteiro da Balada)
Como impedimos o jogador de acessar a Fase 2 se ele não venceu a Fase 1?
Usando um famoso comando chamado `if` (que significa "Se", em inglês).

```gdscript
var fase_maxima_liberada: int = 1

func unlock_next_fase():
	# SE a fase que eu acabei de passar é a MAIOR fase que eu já tinha chegado...
	if fase_atual >= fase_maxima_liberada:
		# Então o meu novo limite é a fase atual + 1 (ou seja, 2!)
		fase_maxima_liberada = fase_atual + 1
```
Se ele repetiu a fase 1 pra ganhar mais pontos, `1 >= 2` é Falso. Então ele não ganha liberação nova. Simples e elegante!
