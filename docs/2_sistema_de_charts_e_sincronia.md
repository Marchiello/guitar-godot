# Aula 2: O Coração Musical (Sincronia e Arquivos .chart)

Preste muita atenção, porque entender isso separa os amadores dos profissionais.
Em jogos de tiro ou Mario, os inimigos se movem usando a velocidade do seu processador. Se o seu PC for fraco e der uma travada rápida, o jogo congela, você espera um pouquinho, e tudo volta ao normal. 

**Em jogos de Música, isso é Proibido.** A música toca direto da sua placa de som. Ela não liga se o seu jogo travou. Se o seu jogo parar por 1 segundo e as notas de guitarra congelarem no ar, quando ele voltar, as notas estarão 1 segundo atrasadas. A música já passou!

## O Relógio Divino (Sincronização Absoluta)
O truque é nunca confiar na matemática do computador para mover as notas. A sua "bússola" deve ser a **música**.
O Godot tem uma função maravilhosa no reprodutor de áudio (`AudioStreamPlayer`) chamada `get_playback_position()`. Ela te responde a pergunta: *"Em qual segundo exato da música nós estamos?"*.

```gdscript
# Todo "frame" da tela (60 vezes por segundo), atualizamos nosso relógio:
game_clock = audio_player.get_playback_position() + song_start_delay
```
O que acontece se o computador travar por 1 segundo? O relógio não conta 1, ele **pula** direto pro segundo correto da música. As notas dão um "teleporte" na tela e continuam exatamente alinhadas com o áudio!

## O que raios é um ".chart"?
`.chart` é um arquivo de texto de bloquinho de notas que a comunidade do jogo *Clone Hero* criou.
O nosso código (`sistema_chart.gd`) vai abrir esse arquivo e tentar achar a seção que fala sobre as notas (a seção `[ExpertSingle]`).

O arquivo tem linhas tipo essa:
`  1152 = N 0 192`

Nós programamos o Godot para agir como um "Tradutor":
1. Ele quebra a frase nos pedaços vazios (espaços).
2. O primeiro pedaço (`1152`) é o **Tempo** da nota (medido em "Ticks" musicais).
3. O terceiro pedaço (`0`) é o **Botão** (0 é Verde, 1 Vermelho, etc).
4. O quarto pedaço (`192`) é o **Rastro**. Se for maior que zero, é a duração que o cara tem que segurar o botão.

### Listas (Arrays)
Como guardamos milhares de notas para o jogo lembrar? Colocamos dentro de um **Array**. Um Array (Lista) é como um vagão de trem. Ele guarda várias coisas em fila indiana.
Nós colocamos cada notazinha no vagão. Conforme a música toca e o segundo daquela nota se aproxima, a esteira do nosso jogo "Cospe" a nota na tela e tira ela do vagão de espera.

## Janela de Acerto (O Juiz do Jogo)
Quando você aperta o Botão Laranja da vida real, como o computador sabe que você acertou a nota laranja da tela?

Ele faz uma conta de subtração (uma diferença)!
```gdscript
var diferenca_de_tempo = abs(nota.tempo_alvo - game_clock)

# Se a diferença entre a nota encostar na linha e o momento atual for menor que 0.15s...
if diferenca_de_tempo <= 0.15: 
	 # ACERTOU! (Hit)
	 destruir_nota()
```
A função mágica `abs()` (Valor Absoluto) tira o sinal negativo. Ou seja, não importa se você apertou 0.15 segundos **adiantado** ou 0.15 segundos **atrasado**. Se a nota estava perto, você ganha o ponto!
