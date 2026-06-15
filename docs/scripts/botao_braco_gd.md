# Dissecando o: `botao_braco.gd`

> **O que é este arquivo?** Ele é a "Alma" física dos 5 botões coloridos que ficam na parte de baixo da guitarra. É ele quem cuida dos cliques, de acender as luzes Neon e de explodir de tamanho quando você acerta uma nota.

## 1. As Texturas Injetáveis (@export)
```gdscript
@export var texture_inactive: Texture2D
@export var texture_active: Texture2D
@export var texture_hit: Texture2D
@export var input_action: String = ""
```
Quando você escreve `@export` na frente de uma variável, ela vira um buraquinho visível lá no painel direito (Inspector) do Godot!
Graças a isso, nós programamos UM ÚNICO SCRIPT genérico e arrastamos ele pros 5 botões. Aí lá no Godot a gente clica no Botão Verde e só joga as imagens verdes nos buracos. Clica no Botão Vermelho e joga as vermelhas. Isso é a essência de ser um programador esperto: não repita código!

## 2. A Troca de Cores e o "Glow Hack"
```gdscript
func set_visual_state(new_texture: Texture2D, glow_intensity: float) -> void:
	if hit_tween: hit_tween.kill() # Mata qualquer animação de acerto rolando
	if sprite and new_texture:
		sprite.texture = new_texture
		sprite.modulate = Color(1, 1, 1) * glow_intensity
```
Essa função troca a imagem do botão e aplica o Brilho. A sacada genial aqui é a matemática de cor do Godot: A cor Branca é formada por Red 1.0, Green 1.0, Blue 1.0 (Daí o `Color(1, 1, 1)`).
Quando a gente multiplica esse branco por `2.5`, ele vira um branco "radioativo" de intensidade 250%. Como a nossa Câmera 3D configurada com "Glow" começa a embaçar coisas que passam de 85%, esse botão vira literalmente uma lâmpada!

## 3. Escutando o Teclado
```gdscript
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(input_action):
		is_pressed = true
		set_visual_state(texture_active, 2.5) 
		luz.light_energy = 5.0
```
Se você aperta o teclado configurado para essa linha (ex: `A` para o botão verde), ele altera a luz ambiente (`OmniLight3D`) para 5.0 (acendendo a esteira levemente) e avisa pro jogo que a chave física de apertar está "Ligada" (`is_pressed = true`).

## 4. O SUCO VISUAL (A Animação de Acerto)
Se o sistema central (`sistema_chart`) perceber que uma nota estava em cima desse botão no milissegundo exato que você apertou, ele invoca de fora essa função mágica:
```gdscript
func _apply_hit_feedback() -> void:
	if is_pressed:
		sprite.texture = texture_hit
		sprite.modulate = Color(1, 1, 1) * 35.0 # EXPLOSÃO BRANCA NAS RETINAS
		luz.light_energy = 50.0 # EXPLOSÃO NA LUZ 3D
		sprite.scale = Vector3(1.5, 1.5, 1.5) # O botão incha 50%!
```
Até aqui, nós só aumentamos os números absurdamente. Mas se parar por aí, o botão vai ficar preso pra sempre gigante e ofuscando a tela. A gente precisa "esfriar" ele.

```gdscript
		hit_tween = create_tween()
		hit_tween.set_parallel(true) # Faça tudo abaixo AO MESMO TEMPO
		
		# Esfrie o branco e a luz em 0.4 segundos usando uma curva Cúbica (Esfria rápido no começo, e lento no fim)
		hit_tween.tween_property(sprite, "modulate", Color(1, 1, 1) * 2.5, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		# Faça o botão encolher de volta para o tamanho 1.0 em 0.25 segundos. Mas use a curva "BACK", 
		# que significa que ele vai encolher demais como uma mola e dar um "pulinho" de volta pro 1.0, gerando um elástico satisfatório.
		hit_tween.tween_property(sprite, "scale", Vector3(1.0, 1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
```
Essa ferramenta `Tween` é a deusa da fluidez em desenvolvimento de games. Ela interpola suavemente qualquer número de A até B no tempo que você mandar!
