# Documentação do Guitar Godot

Bem-vindo à documentação do projeto Guitar Godot. Esta documentação foi escrita para auxiliar desenvolvedores a entenderem a arquitetura do projeto e recriarem suas lógicas e mecânicas, desde o parsing de arquivos `.chart` até os truques avançados de renderização em 3D.

## Módulos do Sistema

Por favor, navegue pelos módulos abaixo para entender como cada peça do jogo funciona por baixo dos panos:

1. **[Arquitetura e Progressão](1_arquitetura_e_progressao.md)**  
   Explica o uso do Autoload (Singleton) para salvar recordes de combo e gerenciar o avanço de fases do jogo, além da injeção de dependências das músicas.

2. **[Sistema de Charts e Sincronia Rítmica](2_sistema_de_charts_e_sincronia.md)**  
   O coração do jogo. Como os arquivos do *Clone Hero / Guitar Hero* são lidos, como os Ticks musicais são convertidos em Segundos, e como o relógio do jogo previne dessincronia do áudio.

3. **[Notas e Sistema de Sustain (Cauda)](3_notas_e_sustain.md)**  
   Como instanciar e gerenciar as notas 3D dinamicamente. Explica a matemática necessária para esticar o rastro da nota com base no tempo de duração (sustain) e a lógica de colisão visual (Glow).

4. **[Renderização, Luzes e Profundidade (Z-Fighting)](4_renderizacao_e_profundidade.md)**  
   Soluções gráficas adotadas no Godot 4 (Compatibility Mode). Como criar o efeito de luz Neon/Glow sem suporte a HDR e como forçar o Godot a renderizar elementos transparentes na ordem correta usando `render_priority`.
