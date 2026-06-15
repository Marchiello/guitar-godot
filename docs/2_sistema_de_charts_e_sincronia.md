# 2. Sistema de Charts e Sincronia Rítmica

O núcleo de um jogo musical (Rhythm Game) é ler as batidas e sincronizá-las visualmente com a música.

## Leitura do formato `.chart`
Arquivos `.chart` padrão (usados na comunidade de *Clone Hero*) organizam os eventos em seções.
- `[SyncTrack]`: Define a resolução (quantos ticks por batida) e as mudanças de BPM (Batidas Por Minuto).
- `[ExpertSingle]`: Define as notas que o jogador precisa acertar em uma dificuldade específica.

### Como a Leitura Funciona (Raciocínio)
Lemos o arquivo `.chart` linha por linha:
1. Extraímos o `Resolution` (ex: 192 ticks equivalem a 1 tempo musical/beat).
2. Armazenamos as alterações de BPM em um array `bpm_events = [{tick, bpm}]`. No `.chart`, o BPM é armazenado multiplicado por 1000 (ex: `120000` = `120 BPM`).
3. Armazenamos as notas `N` em `chart_notes = [{time (em ticks), lane, sustain}]`.

## A Matemática do Tempo: Convertendo Ticks em Segundos
O Godot e as físicas do jogo funcionam em Segundos (Tempo Real). Mas o arquivo de música armazena as notas em Ticks (Tempo Rítmico Musical). 

```gdscript
func tick_to_seconds(target_tick: int) -> float:
	var total_seconds = 0.0
	var current_tick = 0
	var current_bpm = 120.0
	
	for event in bpm_events:
		if target_tick <= event["tick"]:
			break
		# Calcula quanto tempo passou com o BPM anterior até o ponto da mudança
		var ticks_diff = event["tick"] - current_tick
		var beats_diff = float(ticks_diff) / float(resolution)
		total_seconds += beats_diff * (60.0 / current_bpm)
		current_tick = event["tick"]
		current_bpm = event["bpm"]
		
	# Calcula o trecho restante
	var ticks_diff = target_tick - current_tick
	var beats_diff = float(ticks_diff) / float(resolution)
	total_seconds += beats_diff * (60.0 / current_bpm)
	return total_seconds
```
**Por que isso é necessário?**
O BPM de uma música nem sempre é constante. Se a música acelera (de 120 para 150 BPM no meio), um "tick" de nota depois desse evento vale menos segundos do que antes. Essa função interage com o histórico de BPMs para traduzir o tempo exato em milissegundos que aquela nota precisa atingir a zona de acerto.

## Sincronização do Relógio (Prevenção de Lag)
Se você basear a queda das notas no *Delta Time* da CPU (`_process(delta)` -> `clock += delta`), pequenas engasgadas no computador (frame drops) farão as notas perderem sincronia com o áudio (que é imutável na placa de som).

**A Solução de Sincronia Áudio-Relógio:**
```gdscript
game_clock = audio_player.get_playback_position() + song_start_delay
```
No `_process`, o relógio da esteira "pergunta" ao motor de som em que ponto exato a música está. Assim, se houver um travamento de vídeo, as notas darão um pequeno "teleporte" visual para acompanhar a música sem causar dessincronia!

## Janela de Hit (Hit Window)
Quando um botão é apertado, o código itera pelo array de `active_notes`.
Se existe uma nota cuja `target_time` está próxima do `game_clock` (dentro de uma tolerância `hit_window` de `0.15s`), declaramos um "Hit". Se o loop de notas acabar e nenhuma se qualificou, chamamos de `Ghost Hit` (penalidade por espamar botões, incrementando os "Erros" e zerando o Combo).
