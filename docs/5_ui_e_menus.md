# Aula 5: Telas e Botões (O Menu Imortal)

Se você não entender a diferença entre ancoragem e posição absoluta, você vai sofrer muito.

## A Corda Elástica (Sistema de Ancoragem)
Imagine que você tem uma televisão na sala e uma TV pequenininha na cozinha. Você quer colar um adesivo de "START" bem no meio de ambas.
Se você falar pra uma fita métrica cega: *"Mova-se 200 centímetros para a direita"*, na TV da sala isso pode cair no centro, mas na TV da cozinha o adesivo vai ficar pendurado na parede fora da tela! Isso é "Coordenada Absoluta" (`X = 200, Y = 100`). **NUNCA FAÇA ISSO EM UI!**

**O Certo: Âncoras (Anchors)**
O Godot tem caixas inteligentes, como o `HBoxContainer` (Uma caixa de sapatos invisível que guarda botões um do lado do outro). Nós usamos ela no `menu_fases.tscn`.
E nas regras dela, marcamos as âncoras (`Anchor`) em **Center / Centro**.
Sabe o que isso significa? É como amarrar cordas elásticas nos 4 cantos da caixa até os limites da tela do jogador. Se ele encolher a janela do PC para a metade do tamanho, as 4 cordas perdem força de forma proporcional, mantendo a caixa no exato meio perfeito. Fim de dores de cabeça!

## Congelamento do Tempo e o Menu Imortal
Nos jogos, quando o jogador aperta "Pause", nós usamos um código muito poderoso e destrutivo:
```gdscript
get_tree().paused = true
```
O `get_tree()` é a árvore que engloba o próprio tecido da realidade do seu jogo inteiro. Quando você declara "Pausado", as guitarras param, o som cala, a nota flutua, a gravidade some, **e a tela de toque de botões desliga.**

**O GRANDE PROBLEMA:**
Pense: Se o tempo não passa, como o botão de "Voltar" do Pause vai funcionar? O computador vai ignorar você clicando nele, porque as ações dele também congelaram no tempo.

**O Escudo Temporal (`Process Mode = ALWAYS`)**
Nós criamos a cena `pause_menu.tscn`. Mas antes de salvar, clicamos na base dela (a raiz), fomos do lado direito no menu do Godot chamado "Process", e mudamos a opção Mode de "Inherit" (Herdar o congelamento do universo) para **"Always"** (SEMPRE PROCESSAR!).

Essa é a armadura impenetrável. Agora, quando a música parar, esse Menu vai continuar operando seus próprios loops invisíveis! Ele liga o cursor do mouse oculto de volta pra tela, pega o seu clique, e então você aciona o botão e manda despausar! Uma engenharia digna de estúdio grande explicada em 5 minutos!
