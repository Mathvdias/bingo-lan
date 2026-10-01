# Auditoria técnica e de produto · Bingo · 2026-09-30

Escopo: `bingo_app`, `bingo_core`, scripts de build, configuração Android/iOS, monetização.
Objetivo: deixar o app redondo para a Play Store primeiro, iOS depois.
Caminhos relativos a `bingo_app/` salvo quando indicado `core/` = `bingo_core/lib/src`.

## Veredito

O app está a 85% do publicável e o código é bem estruturado: SDK separado, injeção de
dependência, autenticação do WebSocket antes do upgrade, validação de bingo no host, JWT
por sala com segredo que nunca sai do celular do host, 6 idiomas, testes. Os 15% que
faltam são concentrados e explicam exatamente o que você reportou: paywall, RevenueCat e
anúncios não funcionam porque as flags do Remote Config nascem desligadas, o entitlement
tem dois nomes, e o jogador nunca chega à cartela por uma rota errada.

## P0 · bloqueia o uso real

| # | Problema | Onde | Correção |
|---|---|---|---|
| 1 | Jogador nunca chega à cartela: scan navega para `/player/game/$cardId?name=` e a rota só existe como `/player/game` lendo `extra` | `lib/features/player/scan_screen.dart:75`, `lib/shared/router.dart:70-78` | Navegar com `extra: (cardId, name)` e ler o record na rota |
| 2 | Entitlement com dois nomes: app checa `premium`, core checa `pro_access`. Quem paga continua bloqueado no auto-globo e no limite de jogadores | `core/drivers/payment_driver.dart:9` vs `lib/shared/services/subscription_service.dart:51` | Unificar em `premium` |
| 3 | Monetização nasce desligada: defaults `purchases_enabled=false`, `ads_enabled=false`, `revenue_model=ad_supported`. Sem parâmetros no console do Firebase o app é 100% grátis e sem botão de upgrade | `lib/shared/services/revenue_config_service.dart:27-35` | Criar os parâmetros no Firebase e revisar defaults |
| 4 | Segredos versionados: `scripts/run_dev.sh` tem chaves do RevenueCat, Clarity, Gemini e Supabase; `android/key.properties.example` tem senha real; chave Gemini apareceu em `env.dart` e `.vscode/launch.json` no histórico. `.env` não está no `.gitignore` | `scripts/run_dev.sh:3-8`, `android/key.properties.example:4-5` | Rotacionar Gemini e Supabase, `source .env`, gitignore, limpar histórico |
| 5 | Chave Gemini compilada no APK via dart-define; extraível e cobrável. Modelo `gemini-pro` já foi descontinuado e a chamada cai no fallback local | `build_release.sh:50`, `lib/shared/services/ai_service.dart:33` | Remover Gemini do cliente; manter piadas locais |
| 6 | Conexão falha em silêncio: `WebSocketChannel.connect` sem `await ready`; `onError`/`onDone` só logam. Jogador entra numa sala morta | `core/drivers/local_shelf_game_connection.dart:57-75` | `await ready`, stream de estado de conexão, UI de erro |
| 7 | Fim de jogo não existe na UI: `GameOverEvent` e `RejectClaimEvent` só vão para o log no host e no jogador; botão de sortear continua ativo | `lib/features/host/host_room_view_model.dart:213`, `lib/features/player/player_game_view_model.dart:37-42` | Fase de jogo `waiting/playing/over`, overlay de vencedor, "jogar de novo" |
| 8 | Piada da IA chega como snackbar vermelho de erro a cada bola, e o número só aparece depois da chamada de rede | `host_room_view_model.dart:174-181` | Ação própria `AnnounceNumber`, piada fire-and-forget |
| 9 | Convite inconsistente em 3 lugares: host emite `{token}` + `bingo://join`, `BingoInvite` espera `s` + `bingolucca://`, texto de share usa `bingo://room`. O título da sala sempre cai em "Sala de Bingo" | `host_setup_view_model.dart:69-83`, `core/models/bingo_invite.dart:22-46`, ARB `inviteShareLinkMessage` | `BingoInvite` como único serializador |

## P1 · antes de enviar para revisão

Rede e protocolo
- **Status (2026-10-01, PR 4 `feat/fluxo-jogador-rede`):** feito — rota `/player/game` com `PlayerGameArgs`, deep link `bingo://join?data=` ligado, `BingoInvite` único (v2, sem caminho v1), `await ready` + stream de estado + reconexão com backoff reaproveitando o `playerId`, ping 15 s nos dois lados, identidade (`playerId`/`cardId`) atribuída pelo host no `JOINED` com os números já sorteados, `STATE_SYNC` na reconexão e na nova rodada, `ROOM_CLOSED`, `"v":1` no envelope, porta dinâmica com `HostStartException` localizada, `disconnect()` ao voltar do convite, sem `logRequests()`/log de token, issuer+role no JWT, 3 sockets por IP, wakelock, fases `waiting/playing/over` com overlay de vencedor nos dois lados, `AnnounceNumber`, strings no ARB com plural ICU, teste de loopback do servidor. Fora deste PR: goldens, UMP/ads (PR 3), CI (PR 6).
- Sem ping/pong nem reconexão. Celular que perde Wi-Fi fica em `_connectedPlayers` para sempre e consome vaga do limite grátis. `core/.../local_shelf_game_connection.dart:134`.
- Host sem wakelock, sem observer de ciclo de vida, porta fixa 8080 sem tratamento de `EADDRINUSE`, voltar da tela de convite não chama `disconnect()` e a segunda sala lança `StateError`. `host_setup_view_model.dart:56`, `setup_screen.dart:92`.
- Jogador escolhe o próprio `cardId` com `Random().nextInt(999999)`; o host só aprende no `SHOUT_BINGO`. Dá para forçar um seed que bata com os números sorteados. `player_scan_view_model.dart:85`. Host deve atribuir `cardId` e uuid na conexão.
- Entrantes tardios não recebem o estado; jogador ignora `NUMBER_DRAWN`. `player_game_view_model.dart:34-46`.
- `logRequests()` imprime a URL com o token JWT no logcat; `player_scan_view_model.dart:75` loga o token. `Purchases.setLogLevel(debug)` e Clarity `Verbose` sem gate de `kDebugMode`.
- `bonsoir` declarado e nunca usado. Remover.

Segurança e release
- Build release cai no keystore de debug em silêncio se `key.properties` faltar. `android/app/build.gradle.kts:58-62`.
- `build_release.sh` diz "ofuscação ativada" mas não passa `--obfuscate --split-debug-info`.
- `ACCESS_FINE_LOCATION` e `COARSE` só para mostrar o SSID. A Play exige justificativa e declaração. Remover o SSID e as permissões.
- iOS: faltam `NSCameraUsageDescription`, `NSLocalNetworkUsageDescription` e `SKAdNetworkItems`; sobram strings de microfone e Bluetooth de features que não existem.
- Sem fluxo de consentimento UMP para anúncios. Obrigatório para EEA e Reino Unido.
- 6.835 arquivos de `ios/build/`, `android/build/reports`, `.idea/` e `.vscode/launch.json` versionados. Branch `imgbot` indica app de terceiro com leitura.
- Ícone sem adaptive nem monochrome. Descrição do pubspec ainda é o template. `proguard-rules.pro` sem `-keepattributes SourceFile,LineNumberTable`, logo Crashlytics sem símbolos Java.

Monetização
- **Status (2026-10-01, PR 3 `feat/monetizacao`):** feito — entitlement único `premium` (`kPremiumEntitlementId`), `Purchases.configure` só em `SubscriptionService`, cache `isPremium` (ValueNotifier) nos gates, paywall próprio sem `purchases_ui_flutter`, banner só no lobby, App Open/interstitial/banner pulados para premium, test ids em debug, iOS sem ads, UMP antes do `MobileAds.initialize`, init preguiçosa do AdMob, funil de analytics ligado, dica "N/M" no convite e na sala, Clarity removido, `REVENUECAT_SETUP.md` atualizado. Pendente só no console: criar produtos na Play após o primeiro AAB e subir a conta de serviço no RevenueCat.
- `Purchases.configure` chamado duas vezes. `core/drivers/payment_driver.dart:16` e `subscription_service.dart:34`.
- Banner e App Open aparecem para quem paga. `banner_ad_widget.dart:27`, `ad_service.dart:100`. Banner está na cartela do jogador durante o jogo, a pior posição.
- Mesmos ad units para Android e iOS; sem test ids em debug.
- `AdService.initialize` só roda se `ads_enabled` já for true na abertura; se o Remote Config virar depois, nada acontece até reiniciar.
- Funil de analytics não dispara: só `app_open` e navegação. `paywall_view`, `purchase`, `restore` existem e nunca são chamados.
- `PaywallViewModel` com strings em português é código morto; a tela usa `PaywallView` do RevenueCat.
- `REVENUECAT_SETUP.md` fala em bundle `com.bingolucca.app`; o real é `com.matheus.bingo`.
- O 11º jogador é expulso com código 1008 sem ver nada, e o host recebe o paywall no meio da festa. Mostrar "7/10 grátis" antes.

UX
- Sem desfazer, sem pausa, sem som ou voz. Histórico de bolas do mais antigo para o mais novo, sem a letra B-I-N-G-O.
- "FREE" no centro da cartela sem tradução. ~15 strings fora do ARB. Plural por concatenação.
- Jogador e solo não têm proteção de voltar no meio do jogo. iOS permite paisagem e a grade estoura.
- Câmera negada mostra o erro padrão do plugin sem caminho para configurações.
- Vazamentos: `HostInviteScreen` cria o ViewModel dentro do `build` e assina stream sem dispose; `HostRoomViewModel` e `PlayerGameViewModel` nunca cancelam assinaturas.
- Contraste: amarelo primário sobre creme como label de aba, ~1,1:1. `BingoBackButton` e `CardCell` sem semântica.

## P2

Versão no protocolo, evento `ROOM_CLOSED`, verificar `issuer` e `role` no JWT, remover caminho v1 do QR, remover root detection que nunca é chamada, `allowBackup=false`, solo com detecção de vitória ou rebaixado, testes de loopback do servidor, goldens atualizados (13 falhando por diferença de pixel), restringir chave do Firebase por pacote e SHA.

## O que funciona bem e deve ser preservado

Abstração `IGameConnection` com DI, autenticação antes do upgrade do WebSocket, segredo por sala em `Random.secure()`, validação de bingo determinística no host, parse de JSON isolado por mensagem, flags de monetização centralizadas, l10n completa com 87 chaves iguais nos 6 idiomas, `flutter analyze` limpo, targetSdk 36, AGP 8.11, NDK 28, 16 KB compatível por padrão.

## Plano de execução

PR 1 · Higiene e segredos
PR 2 · Configuração de release Android e iOS
PR 3 · Monetização
PR 4 · Fluxo do jogador e rede
PR 5 · UX do host e do jogador
PR 6 · Testes e CI

Ações só suas: rotacionar chave Gemini e projeto Supabase; autorizar limpeza de histórico com force push; criar parâmetros no Firebase Remote Config; configurar RevenueCat e Play Console; publicar o site de privacidade.

## Play Console · entradas

Data safety: Advertising ID (AdMob), interações e diagnóstico (Firebase), gravação de sessão (Clarity, se mantido), histórico de compra (RevenueCat). Famílias: não marcar como infantil, público 13+. Classificação: sem apostas, jogo social sem dinheiro. Conta: não há login, exclusão não se aplica. Localização: não se aplica após remover o SSID.
