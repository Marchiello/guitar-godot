# Dissecando o: `ProgressoJogo.gd`

> **O que é este arquivo?** Ele é o "Cérebro" do jogo. Tecnicamente chamado de Singleton ou Autoload. Diferente das fases que são criadas e destruídas, esse script nasce quando o jogo abre e só morre quando o jogador fecha o aplicativo no Windows.

## 1. O Cabeçalho e as Variáveis Globais
```gdscript
extends Node
```
Todo script no Godot precisa herdar (`extends`) de alguma coisa. Como esse script não tem imagem, nem física, e só serve pra guardar dados, ele herda da classe mais básica e leve de todas: `Node`.

```gdscript
var fase_maxima_liberada: int = 3
var fase_atual: int = 1
var jogo_zerado_visto: bool = false
```
Aqui criamos gavetas na memória (variáveis) para lembrar o estado do jogador. 
Se a fase do jogo fosse destruída e o jogador voltasse pro menu, o menu perguntaria: *"Em qual fase você estava mesmo?"* e a fase responderia: *"Não sei, eu morri"*. É por isso que guardamos o `fase_atual` aqui em cima, no lugar seguro.

## 2. O Grande Dicionário de Fases
```gdscript
var info_fases = {
	0: { "arquivo_cena": "res://scenes/game.tscn", "musica": "...", "chart": "..." },
	1: { "arquivo_cena": "res://scenes/game.tscn", "musica": "...", "chart": "..." }
}
```
Um Dicionário (`{}`) funciona como um arquivo de pastas no computador. Quando o Menu de Fases quiser carregar a Fase 1, ele vai buscar na "pasta" `1` qual é o áudio que ele tem que injetar na cena do jogo. Isso evita que você precise desenhar 50 fases 3D no editor do Godot. O palco é um só (`game.tscn`), só mudam os atores!

## 3. As Funções de Controle (Os Botões do Gerente)
```gdscript
func atualizar_recorde(novo_combo: int) -> bool:
	if fase_atual in recordes_combo and novo_combo > recordes_combo[fase_atual]:
		recordes_combo[fase_atual] = novo_combo
		return true
	return false
```
Sempre que a música acaba, a fase manda um zap pra essa função: *"Chefe, o cara fez 100 de combo!"*. O Autoload confere: *"Esse número é maior que o recorde antigo?"*. Se for, ele salva por cima. Isso garante que pontuações fracas não apaguem o seu troféu!

```gdscript
func carregar_fase(numero_fase: int):
	if numero_fase in info_fases:
		fase_atual = numero_fase
		get_tree().change_scene_to_file(info_fases[numero_fase]["arquivo_cena"])
```
A função sagrada de transporte. Ela atualiza o "post-it" avisando todo mundo que agora estamos na fase X, e em seguida manda a Engine inteira (`get_tree()`) apagar a tela atual e carregar o arquivo da fase.

## 4. O Interceptador Universal (Tela Cheia)
```gdscript
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
```
A função `_input` é ativada pelo Godot SEMPRE que você encosta em qualquer coisa do teclado ou mouse.
Como esse script nunca morre, colocar o código de Fullscreen (Tela Cheia) aqui significa que o F11 vai funcionar na intro, na fase, no game over... literalmente em todo lugar! Nós usamos o `DisplayServer` (o tradutor do Godot para o Windows/Mac) e pedimos para ele trocar o modo de Janela.
