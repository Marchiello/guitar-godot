# Dissecando a: Interface e os Menus

> **O que são esses arquivos?** Scripts como `menu_fases.gd`, `pause_menu.gd`, `game_over.gd` e `victory.gd`. Eles são bem mais simples e servem para fazer a ponte entre as telas de papelão e o cérebro do jogo.

## 1. Puxando Informação do Sistema (@onready)
Em qualquer script de Menu, a primeira coisa que vemos são as conexões com os botões físicos da cena:
```gdscript
@onready var btn_fase2: Button = $BotoesContainer/VBoxFase2/BtnFase2
```
A palavra `@onready` é vital. Ela diz pro Godot: *"Fique quieto. Só procure pelo botão BtnFase2 dentro da tela QUANDO a tela inteira terminar de ser desenhada e carregada"*. Se a gente não usasse o `@onready`, o script tentaria pegar o botão no instante zero do tempo, e o Godot devolveria o temido erro `Null Instance` (Botão inexistente!).

## 2. Bloqueando o Caminho (Disabled)
Quando o `menu_fases.gd` acorda, ele vai lá bater na porta do Chefão Invisível (`ProgressoJogo.gd`) e pergunta: *"Até onde esse moleque já jogou?"*.
```gdscript
	if max_fase < 2:
		btn_fase2.disabled = true
		btn_fase2.modulate = Color(0.3, 0.3, 0.3)
```
Se a fase liberada for só a 1, ele pega a propriedade física `disabled` do Botão da Fase 2 e liga ela. O Godot arranca as propriedades de clique do mouse, e pra completar, pintamos ele com uma tinta 30% cinza escuro (`Color(0.3)`) pro jogador saber que está travado.

## 3. O Escudo Temporal de Pause (Process Mode)
Como já discutimos na documentação de menus, o script `pause_menu.gd` sobrevive ao `get_tree().paused = true` por um motivo genial: o nó raiz CanvasLayer foi selecionado na direita (no painel Inspector) e teve sua tag Process Mode alterada para **`Always`**.

```gdscript
func _on_reiniciar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
```
Quando você clica em Reiniciar Música, a função primeiramente desliga o Pause da árvore mestra (descongelando o universo), e logo em seguida solta a Bomba Nuclear `reload_current_scene()`, que manda o motor Godot varrer todas as notas, músicas e placares da memória e acordar na fase do total zero de novo! 

## 4. Salvando e Carregando a Tela Final (Zeramento e Áudio Dinâmico)
A grande recompensa secreta do `menu_fases.gd`:
```gdscript
		# Verifica se zerou o jogo
		if max_fase > 3 and not ProgressoJogo.jogo_zerado_visto:
			ProgressoJogo.jogo_zerado_visto = true
			painel_zeramento.show()
			
			som_zeramento = AudioStreamPlayer.new()
			som_zeramento.stream = preload("res://assets/victorysong.mp3")
			add_child(som_zeramento)
			som_zeramento.play()
```
Se a fase superou a Fase 3, e o usuário nunca viu o Painel, um imenso painel preto (`Color(0,0,0,1)`) engole a tela. Além disso, nós criamos um `AudioStreamPlayer` puramente via código (sem precisar arrastar nó na interface), carregamos a música da vitória e damos o play! E para garantir que a música não fique tocando pra sempre igual um disco arranhado, quando o jogador clica em "Obrigado!", o script dá um `som_zeramento.stop()` e destrói o rádio da memória (`queue_free()`).

## 5. O Segredo do Konami Code (O Easter Egg de Destravar)
Se o jogador for insistente e clicar na Fase 3 bloqueada 20 vezes, ele destrava o jogo inteiro. Mas como fazemos isso se o botão bloqueado ignora o mouse (`MOUSE_FILTER_IGNORE`)?
```gdscript
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if btn_fase3.get_global_rect().has_point(event.global_position):
			click_count_fase3 += 1
			if click_count_fase3 >= 20:
				ProgressoJogo.fase_maxima_liberada = 4
				get_tree().reload_current_scene()
```
Nós ignoramos o botão e conversamos diretamente com a Tela! Nós pegamos a `global_position` do mouse e perguntamos se ela caiu matematicamente dentro do retângulo (`get_global_rect()`) invisível do botão 3. Se sim, contamos +1. Ao chegar em 20, nós subimos o nível de permissão no Autoload e recarregamos a cena. Uma gambiarra brilhante e indetectável!

## 6. Juiciness Pura: Animação de Hover (Passar o Mouse)
Para fazer os botões saltarem aos olhos, nós conectamos os sinais do Godot `mouse_entered` e `mouse_exited` no próprio código (`_ready`) a uma única função de animação:
```gdscript
func _on_btn_hover(btn: Button, is_hovered: bool) -> void:
	if btn.mouse_filter == Control.MOUSE_FILTER_IGNORE: return
```
A primeira regra de ouro: se o botão for bloqueado, abortamos a animação instantaneamente. O botão trancado tem que parecer um cimento morto.
```gdscript
	if is_hovered:
		tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.1)
		tween.tween_property(solid_back, "color", Color(0.2, 0.4, 0.6, 1.0), 0.1)
```
Se for um botão válido, nós disparamos dois motores de interpolação (`Tween`) paralelamente: O botão inteiro incha para 115% do seu tamanho original usando seu centro geográfico (`pivot_offset`), enquanto o quadrado cinza escuro no fundo que servia para bloquear o cenário transita suavemente para um Azul Metálico deslumbrante em meros 0.1 segundos! Essa fluidez torna clicar em menus um minigame viciante por si só.
