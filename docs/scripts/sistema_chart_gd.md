# Dissecando o: `sistema_chart.gd`

> **O que é este arquivo?** Ele é simplesmente O DEUS do jogo. Ele lê os arquivos de música, controla o ritmo, vomita as notas na tela na hora certa, checa se você acertou, e joga a tela de Game Over na sua cara. Se o Guitar Godot fosse uma orquestra, esse script seria o Maestro.

## 1. O Relógio que Nunca Atrasa (AudioStreamPlayer)
No mundo dos jogos rítmicos, usar matemática pra mover o tempo é a receita pro desastre, porque os processadores travam. O áudio, por outro lado, roda limpo na placa de som.
```gdscript
var raw_playback = audio_player.get_playback_position()
game_clock = raw_playback + song_start_delay
```
No `_process` (que roda todo frame da sua placa de vídeo), o código ignora agressivamente o tempo do PC e vai lá na boca da caixa de som perguntar: *"A música está tocando em qual segundo?!"*. 
Com isso, mesmo que seu computador congele pra escanear um antivírus, as notas não vão dessincronizar.

## 2. A Esteira de Vômito (A Fila de Notas)
O jogo possui uma lista gigante de anotações chamada `chart_notes_queue`. Essa lista é alimentada lendo o arquivo de notas (`.chart`). Mas nós não desenhamos 500 notas 3D no começo da música (isso travaria sua máquina). A gente invoca sob demanda!

```gdscript
while chart_notes_queue.size() > 0:
	var next_note = chart_notes_queue[0]
	
	# Se falta 1.5s pra nota bater, HORA DE NASCER!
	if game_clock >= (next_note.target_time - note_travel_time):
		var note_data = chart_notes_queue.pop_front()
		spawn_note(note_data)
	else:
		break
```
**Tradução humana:** "Oh fila! Qual é a sua primeira nota? Se o Relógio Sagrado marcar que essa nota precisa bater no botão daqui a 1.5 segundos, ARRANQUE ela da lista, desenhe ela na vida 3D e mande cair!". O `break` para a fila pra não ler o resto se não tiver na hora ainda. Economia máxima de processador!

## 3. O Juiz Implacável (A Janela de Acerto)
Quando o jogador afunda a tecla `A` no teclado, o código roda uma busca de policial pra achar a nota culpada:
```gdscript
func try_hit(lane_idx: int) -> void:
	for note in active_notes:
		if note.lane == lane_idx and not note.is_hit:
			var diff = abs(note.target_time - game_clock)
			if diff <= HIT_WINDOW: # HIT_WINDOW é 0.15s (150 milissegundos)
				note.is_hit = true
				acertou_mesmo(note)
				return
```
O `abs()` é uma ferramenta linda da matemática. Se você bateu **Adiantado** (O relógio tava em `1.0s` mas o alvo era `1.15s`), a conta daria `-0.15`. O `abs()` limpa o negativo e transforma em `0.15`. Assim o Godot te premia com o Hit independentemente se você pecou por precipitação ou lentidão!

## 4. O Sistema de Erros e Game Over
Toda vez que a tela pisca vermelho (seja por um erro falso onde você apertou o botão vazio, ou por deixar a nota passar), o `reset_combo()` entra em ação:
```gdscript
func reset_combo() -> void:
	if ProgressoJogo and ProgressoJogo.fase_atual == 0:
		get_tree().reload_current_scene() # O TUTORIAL VOLTA DO ZERO
		return
		
	consecutive_misses += 1
	if consecutive_misses >= 15:
		trigger_game_over()
```
Veja a magia da regra da Fase 0! Nós ensinamos o script: "Se o jogador estiver no tutorial, não deixe ele dar Game Over. Em vez disso, aperte o botão de Restart da Engine (O `reload_current_scene`) e atire ele pro Início do Início instantaneamente!". Punição de forma elegante!
