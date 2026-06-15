# Aula 4: Beleza e Iluminação (Renderização)

O trabalho de um desenvolvedor não é só fazer funcionar. É fazer ficar **Lindo**.
Mas existe um desafio enorme: rodar o jogo de forma brilhante sem exigir que o computador do seu tio precise de uma Placa de Vídeo de 4 mil reais.

## O Truque do "Glow" em Computadores Fracos
Em jogos de nova geração, existe uma tecnologia chamada **HDR**. Ela entende que se o branco absoluto de um monitor é `1.0`, o sol tem uma força de `100.0`. Aí ela gera um brilho cinematográfico (Glow/Bloom) ao redor das cores maiores que 1.
Mas o nosso jogo foi configurado no modo `Compatibility`, feito pra rodar até em celular velho e no navegador Web, que não tem HDR! Qualquer coisa maior que `1.0` é duramente cortada e vira um branco fosco.

**Como "Hackeamos" esse limite?**
Nós dizemos pra Câmera 3D do Godot (na configuração `WorldEnvironment`): *"Olha câmera, eu sei que você não suporta luz maior que 1.0. Mas a partir de agora, qualquer cor que chegar na intensidade 0.85 (85% do branco), eu quero que você embaçe a imagem e jogue um efeito de Halo de Luz nela!"*.

E nós passamos uma cor amarela com `0.85` na textura da nota. E pronto! Ela cria um anel neon mágico sem gastar nada da Placa de Vídeo!

## O Pesadelo do Fogo Amigo (Z-Fighting)
Na vida real, se uma parede está na frente da outra, a luz bate na primeira e você não vê a de trás. O computador sabe desenhar isso bem usando a profundeza Z.
**MAS TUDO MUDA COM VIDROS (Transparência)!** O nosso rastro (Cauda do Sustain) é uma grande lona semi-transparente.
Quando 3 ou 4 objetos de vidro se sobrepõem, o coitado do computador tenta decidir qual está "na frente" do outro usando o pontinho central de cada um deles. Se a câmera se mover 1 milímetro, a placa de vídeo surta e começa a desenhar o de trás na frente do da frente repetidamente. Fica aquele bug horrível tremendo a tela.

**A Regra da Carteirada (`render_priority`)**
A gente resolveu isso de uma forma agressiva. Ao invés de deixar a placa de vídeo adivinhar usando matemática 3D, a gente colou uma "carteirada de prioridade" em cada material.

- `render_priority = 0`: É a base da pirâmide. O Rastro gigante.
- `render_priority = 1`: O Botão. A placa nem mede a distância: como ele tem nível 1, ela desenha ele sempre FURANDO visualmente o Rastro 0, não importando a angulação.
- `render_priority = 2`: A "Cabeça" da nota (Sprite redondo). O Deus da hierarquia. A placa desenha ela por último, engolindo os pixels de todo o resto e gerando aquela beleza visual de sanduíche perfeito do Guitar Hero Clássico.
