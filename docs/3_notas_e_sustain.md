# 3. Notas e Sistema de Sustain (Cauda)

As notas no jogo são instanciadas dinamicamente com base nos eventos traduzidos da `.chart`. 
Elas recebem o momento em que devem aparecer, e o momento `target` (quando chegam ao botão). O tempo de viagem da nota pela esteira é constante (ex: `travel_time = 1.5s`). 

## A Matemática do Posicionamento Físico

No `_process(delta)` de cada nota ativa, calculamos um `progress` normalizado entre 0.0 (início da vida) e 1.0 (momento do Hit).

```gdscript
func get_progress(current_game_time: float) -> float:
	var elapsed = current_game_time - spawn_time
	return elapsed / travel_time
```

Esse progresso é devolvido para o Sistema Chart (Pai), que faz um LERP (Interpolação Linear 3D) entre o `Marker3D` de Inicio e o `Marker3D` Final do chão da esteira.

## A Cauda / Rastro (Sustain)

Se uma nota precisa ser segurada, o arquivo `.chart` traz um parâmetro `sustain_length` maior que zero. O tamanho físico (comprimento do cilindro 3D) da cauda deve ser matematicamente calculado para que seu fim cruze o botão exatamente no tempo musical correto de se soltar.

**A Fórmula do Comprimento:**
```gdscript
# Calculando a velocidade real (espaço / tempo)
var total_distance = spawn_pos.distance_to(target_pos)
var note_speed = total_distance / travel_time

# Se ele dura 1.5s e a velocidade é X, o cilindro deve ter tamanho = X * 1.5
var physical_length = sustain_duration * note_speed
```

**Pivot e Origem no Godot:**
Cilindros e malhas 3D no Godot crescem para ambos os lados a partir do centro (origem no meio). Como nossa nota (a "Cabeça") puxa a cauda como um cometa, o pivô precisava ser ancorado numa ponta. 
A solução foi deslocar o eixo interno da malha em `physical_length / 2.0`. Assim, ao aumentar a escala do cilindro no eixo Z para `physical_length`, ele cresce "para trás" a partir da Cabeça da nota, não invadindo o espaço para frente!

## Feedback Visual: Unshaded Material

Quando você acerta uma nota de Sustain, a cauda precisa se acender para comunicar visualmente o acerto contínuo.

```gdscript
mat.albedo_color = Color(3.0, 3.0, 3.0, 1.0)
```
Multiplicar canais de cores (RGB) por valores acima de 1.0 faz com que o Pixel extrapole o branco e passe a atuar como uma Lâmpada no Pipeline Gráfico. Em configurações de Glow com HDR, isso cria um "Neon" fortíssimo. Para evitar escurecimento provocado pela falta de iluminação direcional, ativamos na malha a flag `Unshaded`, para que ela seja sempre renderizada emitindo sua cor pura.
