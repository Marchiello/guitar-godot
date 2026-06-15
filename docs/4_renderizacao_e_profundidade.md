# 4. Renderização e Resolução de Problemas de Profundidade

O desenvolvimento 3D apresenta desafios únicos quando lidamos com transparências e compatibilidade de renderizadores visuais de baixo custo (Mobile/Web). 

## O Desafio do Glow (Brilho) no GL Compatibility

O renderizador "Compatibility" (OpenGL) do Godot **não suporta HDR (High Dynamic Range)**, logo não permite armazenar Cores maiores que `1.0`. Qualquer valor como `Color(3.0, 3.0, 3.0)` é rigidamente cortado para `(1.0, 1.0, 1.0)` internamente. 
Isso significava que forçar multiplicadores de cor nos Sprites não gerava *Bloom* ou *Glow* natural.

**A Solução de Design:**
Entramos nas configurações de `WorldEnvironment` da cena `game.tscn` e alteramos as regras do Filtro Pós-Processamento de Glow:
- **HDR Threshold:** Reduzimos o limiar de brilho para `0.85`. O renderizador entende que qualquer cor (mesmo sendo LDR / cortada no teto 1.0) que seja levemente próxima do branco saturado é classificada como uma fonte emissora.
- **Ambient Light e Luz Direcional**: Aplicamos uma base de iluminação em `Energy = 2.0` para que o próprio cenário e os botões atingissem esse limiar organicamente quando iluminados pelas `OmniLight3D` das notas.

## Z-Fighting e Ordenação de Transparência (Alpha Sorting)

Transparências (materiais com Alpha channel) são um pesadelo crônico em motores gráficos 3D. A placa de vídeo processa primitivas transparentes inteiras de uma vez usando a distância cartesiana até a Câmera.
Como a Cauda (Sustain) era um cilindro de 10 metros, sua origem mudava em relação à câmera, fazendo com que subitamente a placa de vídeo julgasse que ele estava "mais perto" da câmera que os Botões Finais da esteira. O resultado visual era a cauda "passando por cima" do botão. O offset de profundidade em Y `-0.1` não surtiu efeito pela forma como materiais opacos e transparentes são misturados.

**A Solução Bruta de Hierarquia Gráfica:**
Materiais e Sprites 3D no Godot possuem a propriedade `render_priority` (Padrão = `0`). Esta propriedade permite ao desenvolvedor ditar fisicamente à GPU a ordem final no pass de desenho da tela.

Organizamos a sobreposição absoluta:
- **`render_priority = 0` (Inferior):** O Material da cauda do Sustain. Desenhado primeiro.
- **`render_priority = 1` (Meio):** O `Sprite3D` dos Botões Receptores (`botao_braco.tscn`). Como é renderizado após a cauda, ele **sempre esmaga/sobrescreve a cauda visualmente**.
- **`render_priority = 2` (Topo):** A "Cabeça" da nota (`nota.tscn / Textura`). Ela passa por cima absoluto de todos, incluindo do Botão Receptor, gerando a imersão exata de *Guitar Hero*, onde a cabeça acerta por cima, mas o rastro flui por debaixo do botão.

## Offset Bidimensional vs Tridimensional
Originalmente as notas pareciam "flutuar". Isso se deu pois a propriedade `offset = Vector2(0, 125)` de Sprites 2D sendo projetados no 3D é aplicada em um eixo coplanar. Com as pesadas rotações na matriz XZ do `Transform3D` da nota, um offset Y gerava empuxo diagonal para cima. Remover esse offset forçou a âncora visual e física estarem localizadas num único `Vector3D` centralizado na esteira.
