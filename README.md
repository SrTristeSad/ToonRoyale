# ToonRoyale

Survival 2D top-down em Lua / LÖVE2D. Primeiro marco: **cliente offline independente**, com mundo de 6400×6400 unidades, câmera seguindo o personagem, movimento WASD, colisões com árvores/pedras, grama procedural e personagem top-down.

## Executar

Instale LÖVE 2D 11.5 e abra esta pasta com o LÖVE (ou execute `love .`).

## Estado honesto

Este é um **protótipo inicial**, não um clone completo do Moo Quest nem um jogo survival pronto. Os elementos são desenhos vetoriais temporários em código; **não são as artes cartoon finais**. Não há inventário, coleta, salvamento, construção, inimigos ou multiplayer nesta versão.

## Origem e próximos passos

O Moo Quest (https://github.com/SrTristeSad/Moo-Quest) foi examinado como referência técnica. Seu cliente é LÖVE2D e seu servidor Node.js depende de protocolo de jogo externo; por isso não foi transplantado sem auditoria. Próximos passos: avaliar módulos reutilizáveis e respectivas licenças, produzir sprites PNG originais de árvores/pedras/grama/personagem, adicionar coleta, inventário, crafting e salvamento offline. Não incorporar artes de terceiros sem direitos de redistribuição.
