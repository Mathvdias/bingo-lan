# RevenueCat · configuração do projeto `bingo`

Estado real do projeto, não um tutorial genérico. O que o código espera está
em `bingo_core/lib/src/constants/entitlements.dart` e em
`bingo_app/lib/shared/services/subscription_service.dart`.

## O que o app espera

| Item | Valor | Onde o código lê |
|---|---|---|
| Projeto RevenueCat | `bingo` | — |
| Entitlement | `premium` | `kPremiumEntitlementId` (bingo_core) |
| Offering atual | `default` (qualquer id serve; o app usa `offerings.current`) | `PurchasesGateway.fetchPackages` |
| Produto semanal | `weekly_subscription` | `SubscriptionService.weeklyProductId` |
| Produto anual | `annual_subscription` | `SubscriptionService.annualProductId` |
| Produto vitalício | `lifetime_purchase` | `SubscriptionService.lifetimeProductId` |
| Pacote Android | `com.nightstudios.bingo` (dev: `com.nightstudios.bingo.dev`) | `android/app/build.gradle.kts` |

O paywall (`/paywall`) não tem ids de produto fixos: ele renderiza o que
`offerings.current.availablePackages` devolver, usando `package.packageType`
para o rótulo do período e `storeProduct.priceString` para o preço. O selo
"economize X%" do anual é calculado contra semanal×52 (ou mensal×12).

`Purchases.configure` é chamado **uma única vez**, em
`SubscriptionService.initialize` (`main_common.dart`). O `PaymentDriver` do
`bingo_core` apenas lê `CustomerInfo`. `Purchases.setLogLevel(debug)` só roda em
`kDebugMode`.

## Chaves (dart-define)

| Variável | Uso |
|---|---|
| `RC_ANDROID_KEY` | chave pública `goog_...` do app Android |
| `RC_IOS_KEY` | chave pública `appl_...` do app iOS |
| `RC_TEST_STORE_KEY` | chave `test_...` do **Test Store**; só vale no flavor dev |

Regra em `Env.revenueCatKeyFor`: no flavor dev, se `RC_TEST_STORE_KEY` estiver
preenchida ela substitui a chave da plataforma. Em prod ela é ignorada e
`Env.validate` exige `RC_ANDROID_KEY` e `RC_IOS_KEY`.

Preencha `bingo_app/.env` (copie de `.env.example`); `scripts/run_dev.sh` e
`build_release.sh` leem esse arquivo. Nunca versione chaves.

## 1. Dashboard RevenueCat

1. Projeto **bingo** → **Apps & providers** → confirme os apps:
   - Google Play: package `com.nightstudios.bingo`
   - Apple App Store: bundle id do iOS (quando o scheme iOS existir)
   - **Test Store**: criado automaticamente; copie a chave `test_...`
2. **Entitlements** → `premium` (display name livre).
3. **Products** → crie os três ids acima **por loja** e anexe cada um ao
   entitlement `premium`.
4. **Offerings** → `default`, marcado como *current*, com os pacotes:
   - `$rc_weekly` → `weekly_subscription`
   - `$rc_annual` → `annual_subscription`
   - `$rc_lifetime` → `lifetime_purchase`

   No Test Store o sandbox hoje expõe `$rc_monthly`, `$rc_annual` e
   `$rc_lifetime`; o app renderiza esses três sem alteração (o selo do anual
   usa o mensal×12 quando não há semanal).

## 2. Test Store (dev) — testar o paywall sem Play Console

1. Em **Apps & providers → Test Store**, copie a chave pública `test_...`.
2. `bingo_app/.env`:
   ```
   RC_TEST_STORE_KEY=test_xxxxxxxxxxxxxxxx
   ```
3. `bingo_app/scripts/run_dev.sh` (imprime "RevenueCat: usando Test Store").
4. Lobby → **Upgrade** → o paywall lista os pacotes do Test Store com preços
   fictícios. A compra é simulada pelo RevenueCat e o entitlement `premium`
   ativa na hora: o selo PREMIUM aparece no lobby, o auto-globo destrava, o
   limite de jogadores some e os anúncios deixam de carregar.
5. Para voltar a free: dashboard → **Customers** → o usuário anônimo →
   *Delete customer*, ou limpe os dados do app.

## 3. Google Play — ordem obrigatória

Os produtos só podem ser criados no Play Console **depois do primeiro upload
de um AAB** com a permissão `com.android.vending.BILLING` (o plugin do
RevenueCat já a declara).

1. `./build_release.sh` (exige `RC_ANDROID_KEY` e `RC_IOS_KEY` no `.env`).
2. Play Console → app → **Teste → Teste interno** → envie
   `build/app/outputs/bundle/prodRelease/app-prod-release.aab`.
3. **Monetizar → Produtos**:
   - **Assinaturas**: `weekly_subscription` (plano base semanal) e
     `annual_subscription` (plano base anual).
   - **Produtos no app**: `lifetime_purchase` (gerenciado, não consumível).
   Os ids precisam ser exatamente estes; eles são os `Product ID` que você
   cadastra no RevenueCat para a loja Google Play.
4. **Configuração → Acesso à API / Conta de serviço** (ver abaixo) para o
   RevenueCat validar recibos.
5. **Monetizar → Teste de licença**: adicione o e-mail da conta Google do
   dispositivo de teste para compras sandbox (não cobradas).
6. Instale a build do teste interno pelo link do Play (não um APK local) e
   compre pelo paywall.

### Conta de serviço (Google Play ↔ RevenueCat)

1. Google Cloud Console (projeto vinculado ao Play Console) → **IAM e
   administrador → Contas de serviço → Criar**. Nome sugerido:
   `revenuecat-play`.
2. Na conta criada → **Chaves → Adicionar chave → JSON**. Guarde o arquivo
   fora do repositório.
3. No Cloud Console, habilite a API **Google Play Android Developer API** e a
   **Google Play Developer Reporting API**.
4. Play Console → **Usuários e permissões → Convidar novo usuário** com o e-mail
   da conta de serviço. Permissões mínimas: *Ver dados financeiros*,
   *Gerenciar pedidos e assinaturas*, e no app *Ver informações do app*.
5. RevenueCat → **Apps & providers → Google Play → Service Account
   credentials JSON** → faça upload. A propagação do Play leva até 36 h; até
   lá o dashboard pode mostrar erro de credencial.
6. Opcional mas recomendado: **Real-time developer notifications** (Pub/Sub)
   seguindo o link no mesmo painel do RevenueCat.

## 4. App Store (quando houver iOS)

1. App Store Connect → **Assinaturas** e **Compras no app** com os mesmos ids.
2. Copie o **App-Specific Shared Secret** e a **In-App Purchase Key (.p8)**
   para o RevenueCat em **Apps & providers → App Store**.
3. Teste com conta de sandbox (Ajustes → App Store → Conta de sandbox).

## 5. Remote Config que afeta o paywall

Parâmetros em `bingo_app/remoteconfig/*.template.json` (publicados por
`scripts/rc_publish.sh`): `purchases_enabled` (mostra o botão Upgrade e o
auto-globo), `revenue_model` + `max_free_players_path_a` (limite de jogadores
grátis e dica "N/M"), `ads_enabled`, `paywall_variant` (A/B). Em debug o
`minimumFetchInterval` é zero.

## 6. Funil no Firebase Analytics

`paywall_view{source}` → `begin_checkout{items}` → `purchase{value,currency}`
e `restore_purchases{result: granted|none|error}`. A propriedade de usuário
`subscription_status` (`premium`/`free`) é atualizada sempre que o cache do
status muda (`SubscriptionService.isPremium`).
