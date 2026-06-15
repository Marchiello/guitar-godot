# Aula 3: A Magia 3D (Notas, Física e o Rastro)

No mundo 3D, tudo funciona com **Eixos**: `X` (Esquerda/Direita), `Y` (Cima/Baixo) e `Z` (Frente/Trás).
Para uma nota cair certinho do topo da guitarra pro botão lá embaixo, nós não empurramos ela manualmente. Nós dizemos pro Godot qual é o Ponto A e qual o Ponto B, e usamos uma matemática chamada **LERP**.

## LERP (A sua Bússola Interpoladora)
LERP significa "Interpolação Linear". Basicamente, imagine que você quer viajar de São Paulo ao Rio de Janeiro. A viagem leva 10 horas. Você está dirigindo há 5 horas. Você completou 50% (ou `0.5`) da viagem. Se você perguntar pro GPS: "Qual cidade fica em 50% desse caminho?", ele te dá a resposta exata de onde você está.

É isso que fazemos com a nota!
Nós sabemos que a nota leva `1.5` segundos para fazer o caminho. 
```gdscript
# Descobrindo a porcentagem
var progresso = (relogio_do_jogo - tempo_que_a_nota_nasceu) / 1.5

# Pedindo a resposta pro LERP: "Me dê a posição 3D exata dessa porcentagem!"
nota.global_position = PontoInicial.lerp(PontoFinal, progresso)
```

## O Rastro (Sustain) e a Mágica do Pivô (Parenting)
Algumas notas tem uma cauda luminosa gigante que indica que você precisa segurar o botão por, digamos, `2.0` segundos.
Como criamos uma cauda de "2 segundos"?

Simples: Se a nota viaja numa velocidade de 10 Metros por Segundo, em 2 segundos ela teria percorrido 20 Metros. Então nós geramos um cilindro 3D, pegamos a propriedade **Escala** (`Scale.Z`) dele, e multiplicamos o tamanho para 20!

**O GRANDE PROBLEMA DA VIDA REAL:**
Na vida real, se você pegar uma bola de chiclete no meio da mesa e esticar para 20 metros, ela cresce 10 metros para a direita e 10 metros para a esquerda. O centro não muda!
Se você esticar o cilindro da nossa nota, metade dele vai passar pra frente do botão, estragando o visual. Nós queremos que a nota seja o "bico" e o rastro cresça só para trás!

**A Solução: NÓS DENTRO DE NÓS (Parenting)**
Imagine segurar o cabo de uma vassoura. Onde está a sua mão? No meio? Na ponta?
No Godot, nós usamos "Pais e Filhos". Criamos um Nó vazio que não tem desenho nenhum, chamado de "Pivô", e colocamos ele na **Ponta** superior do rastro (como se estivéssemos segurando a ponta do cabo da vassoura). Quando nós esticamos a madeira da vassoura, nós usamos o código para arrastar a vassoura pra trás para compensar o esticamento!

O resultado? Uma cauda brilhante incrível que só cresce rumo ao topo da tela, presa embaixo da nota!
