# Dissecando o: `nota.gd`

> **O que é este arquivo?** Ele é o DNA gráfico de cada nota musical. Ele diz como a nota calcula sua velocidade para descer a esteira, como ela acende a luz de Neon e a verdadeira bruxaria matemática de como desenhar a cauda 3D (Rastro) que fica grudada atrás dela.

## 1. O Acordo de Viagem (A Bússola da Nota)
A função `setup` é chamada pelo mestre (`sistema_chart.gd`) no exato momento que a nota nasce. Ele entrega pra nota as coordenadas do mapa:
```gdscript
func setup(start: Vector3, end: Vector3, travel_t: float, hit_t: float, sustain_dur: float, lane_idx: int) -> void:
```
- **start e end:** "Você nasce aqui, e precisa morrer ali embaixo em cima do botão".
- **travel_t:** "Você tem exatos 1.5 segundos para fazer essa viagem. Nem um milissegundo a mais".

O cálculo de velocidade é Física do ensino fundamental (`Velocidade = Distância / Tempo`):
```gdscript
	var total_distance = (end - start).length()
	speed = total_distance / travel_time
```

## 2. A Criação do Rastro (A Bruxa da Geometria)
Se essa nota tiver uma Duração Longa (Sustain), a gente precisa materializar um cilindro luminoso gigante atrás dela.

```gdscript
		mesh_sustain.visible = true
		var sustain_length = speed * sustain_duration
		mesh_sustain.scale.z = sustain_length
```
Se a velocidade dela é de 10 Metros por Segundo, e ela dura 2.0 Segundos, nós dizemos: "Godot, pegue o tamanho 3D desse cilindro e estique a Profundidade (Z) dele para 20 Metros!".

**O Grande Truque de Magia (O Deslocamento):**
Um cilindro no Godot cresce a partir do seu centro (o famoso "umbigo"). Se esticarmos para 20 metros, 10 metros crescem pra trás da nota, e 10 metros furam a tela pra frente, engolindo o botão prematuramente!
Para corrigir isso:
```gdscript
		# O tamanho físico base do cilindro cru é de 1.0 (meio metro de Raio a partir do centro)
		# Se a gente arredar ele Z vezes esse raio, ele cola a cabeça bem no pivô!
		mesh_sustain.position.z = sustain_length / 2.0 
```
Pronto! A nota (Sprite circular) fica intacta como se estivesse puxando um lençol imenso pela pontinha dele!

## 3. Atualizando o Rastro Enquanto Pressionado
Quando a nota entra no botão e o jogador segura a tecla, o Sprite circular some, mas a cauda tem que continuar diminuindo até acabar.
Isso roda no `_process(delta)` se a nota for marcada como `being_held`:
```gdscript
func update_sustain(game_clock: float) -> void:
	# Quanto tempo já passou desde que batemos no botão até agora?
	var elapsed = game_clock - target_time
	
	# Quanto ainda SOBRA de rastro para desenhar?
	var remaining_time = sustain_duration - elapsed
	var new_length = speed * remaining_time
	
	# Estica e conserta a posição de novo baseada na lona menor!
	mesh_sustain.scale.z = new_length
	mesh_sustain.position.z = new_length / 2.0
```
É assim que vemos a lona 3D "sendo engolida" pela boca verde do botão! Matemática e ilusão de ótica puras!

## 4. Instanciando Material Neon Imortal
Para fazer o rastro brilhar com Glow, nós pintamos o material com `emission = Color(1, 1, 1) * 2.0`. 
Mas tem uma regra crítica no Godot: **Materiais 3D são compartilhados por padrão para economizar memória.**
Se você tiver 50 rastros verdes na tela e apagar a cor de um deles, os 50 apagam juntos! 

Para resolver isso, nós mandamos o Código arrancar o material da memória compartilhada e forjar uma cópia local exclusiva só para essa notinha, usando `.duplicate()`:
```gdscript
var original_mat = mesh_sustain.get_surface_override_material(0)
var new_mat = original_mat.duplicate()
```
Agora cada nota pode piscar, apagar e brilhar em intensidades próprias sem fritar as vizinhas!
