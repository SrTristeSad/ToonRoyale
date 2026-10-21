# ToonRoyale

**Survival 2D top-down em Lua / LOVE2D 11.5, baseado no Moo-Quest.**

O cliente Lua, o servidor Node.js, os protocolos e os testes foram importados de https://github.com/SrTristeSad/Moo-Quest. A primeira fase substitui terreno e recursos naturais por visual em tiles com grama, arvores e pedras em visao top-down.

## Executar offline

Windows: abra INICIAR-TOONROYALE.bat. Outros sistemas: instale LOVE2D 11.5 e execute love . na pasta do jogo.

WASD/setas movimentam, mouse orienta, F1 oculta o painel e Esc sai. O mapa tem 14400 x 14400 unidades, recursos deterministas, camera seguindo o jogador e colisao espacial local com arvores/pedras. O mapa nao precisa de servidor.

## Modo original Moo-Quest

O sistema online foi preservado. Windows: INICIAR-WINDOWS.bat. Outros sistemas: definir TOONROYALE_ONLINE=1 antes de executar love .; preparar servidor Node, build e artes conforme a documentacao antiga em docs/.

No modo online, grama, arvores, arbustos, pedras e ouro ja podem ser renderizados com o novo estilo. Construcoes, armas, animais, interface e protocolos seguem inicialmente os sistemas do Moo-Quest, para nao quebrar as funcionalidades existentes.

## Estagio da arte

Os tiles de grama (96x96) e sprites top-down das arvores, pedras e personagem sao gerados em canvases no arquivo src/game/toon_tiles.lua. **Sao artes procedurais provisórias**, nao PNGs finais. O desenho foi isolado num modulo para possibilitar a troca posterior por PNGs cartoon originais sem reescrever a logica do jogo.

O modo offline ainda nao tem coleta, inventario, construcao, salvamento nem multiplayer; o Moo-Quest online preservado possui seus proprios sistemas.

## Arte Tiny Swords (Pixel Frog)

O ToonRoyale usa o pacote **Tiny Swords Free Pack** para a grama (tiles de 64x64), quatro arvores animadas, quatro arbustos animados, quatro pedras e seis pedras de ouro. **O codigo do jogo esta pronto para essas artes, mas os PNGs nao estao no GitHub** por causa da licenca do autor.

1. Baixe seu ZIP na pagina oficial: https://pixelfrog-assets.itch.io/tiny-swords
2. No Windows, **arraste o ZIP para IMPORTAR-TINY-SWORDS.bat** (ou coloque o ZIP na pasta raiz e execute o BAT).
3. Execute INICIAR-TOONROYALE.bat. O mapa offline exibira automaticamente as artes importadas.
4. Para outros sistemas, execute npm install e depois node tools/import-tiny-swords.mjs "/caminho/Tiny Swords (Free Pack).zip".

As 19 imagens selecionadas vao para a pasta local assets/third_party/tiny_swords/, ignorada pelo Git. Caso voce nao importe o pacote, o jogo ainda abre com as artes procedurais provisórias. A importacao nao altera as regras do servidor Moo-Quest.

Licenca: o autor permite uso em jogos pessoais/comerciais, mas nao a redistribuicao, revenda ou reempacotamento dos arquivos de arte (mesmo editados). Nao publique assets/third_party em repositorios ou downloads de assets. Credito opcional: Tiny Swords, Pixel Frog.
