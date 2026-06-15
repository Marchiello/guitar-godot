# 1. Arquitetura e Progressão Global

## O Conceito de Autoload (Singleton)
Em jogos, é comum que certos dados precisem sobreviver à troca de cenas. Se o jogador passa da Fase 1, a Tela de Menu precisa saber que a Fase 2 foi desbloqueada. Se o jogador bate um recorde, essa informação não pode ser esquecida quando a tela do jogo é destruída.

No Godot, resolvemos isso usando um **Autoload** (Node global). No nosso projeto, ele é chamado de `ProgressoJogo.gd`.

### A Estrutura dos Dados

```gdscript
var info_fases = {
	1: { 
		"arquivo_cena": "res://scenes/game.tscn", 
		"musica": "res://assets/songs/scom/song.ogg", 
		"chart": "res://assets/songs/scom/notes.chart",
		"album": "res://assets/songs/scom/album.png"
	},
	# Outras fases...
}

var recordes_combo = { 1: 0, 2: 0, 3: 0 }
var fase_maxima_liberada: int = 1
var fase_atual: int = 1
```

**Raciocínio Didático:**
Em vez de ter 3 cenas diferentes (`game_fase1.tscn`, `game_fase2.tscn`), temos **uma única cena de jogo** (`game.tscn`). 
O dicionário `info_fases` age como um banco de dados relacional. Quando o jogador clica na Fase 2 no `menu_fases.tscn`, nós alteramos `fase_atual = 2` e carregamos `game.tscn`. 
Quando a cena `game.tscn` acorda, o seu script (`sistema_chart.gd`) vai até o Singleton global e pergunta: *"Qual fase estou rodando?"*. Ele obtém o caminho dos recursos correspondentes e injeta a música `.ogg`, a `.chart` e a capa do álbum de forma totalmente dinâmica.

### Sistema de Destraves

```gdscript
func unlock_next_fase() -> void:
	if fase_atual == fase_maxima_liberada:
		fase_maxima_liberada += 1
```
Esse método é chamado exclusivamente na lógica de vitória da fase. É uma matemática simples: o jogador só sobe o "teto" de fases liberadas se ele acabar de ganhar a fase limite que ele possui acesso atual. 
Isso facilita programar o mapa de fases: se o ID do botão for maior que `fase_maxima_liberada`, então `button.disabled = true` e escurecemos o botão.
