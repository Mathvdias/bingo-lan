# Guia de Configuração do RevenueCat

## 1. Criar Conta e Projeto

1. Acesse https://www.revenuecat.com
2. Crie uma conta (gratuita para começar)
3. Clique em **"Create New Project"**
4. Nome do projeto: **Bingo Lucca**

## 2. Criar App

1. No dashboard, clique em **"Add App"**
2. Escolha **"Apple App Store"** (iOS)
3. App Name: `Bingo Lucca iOS`
4. Bundle ID: `com.bingolucca.app` (ou seu bundle ID)
5. Clique em **"Save"**

6. Repita para Android:
   - Clique em **"Add App"**
   - Escolha **"Google Play Store"**
   - App Name: `Bingo Lucca Android`
   - Package Name: `com.bingolucca.app`

## 3. Configurar Produtos

### 3.1 Criar Entitlement

1. Na sidebar, clique em **"Entitlements"**
2. Clique em **"+ New"**
3. Identifier: `premium`
4. Display name: `Premium Access`
5. Clique em **"Save"**

### 3.2 Criar Produtos

1. Na sidebar, clique em **"Products"**
2. Criar produtos conforme abaixo:

#### Produto 1: Semanal
- Product ID: `weekly_subscription`
- Type: `Subscription`
- Display Name: `Assinatura Semanal`
- Price: `$2.99/week`
- Attach to entitlement: `premium`

#### Produto 2: Anual  
- Product ID: `annual_subscription`
- Type: `Subscription`
- Display Name: `Assinatura Anual`
- Price: `$29.99/year`
- Attach to entitlement: `premium`

#### Produto 3: Lifetime
- Product ID: `lifetime_purchase`
- Type: `Non-Subscription`
- Display Name: `Acesso Vitalício`
- Price: `$49.99` (one-time)
- Attach to entitlement: `premium`

### 3.3 Criar Offering

1. Na sidebar, clique em **"Offerings"**
2. Clique em **"+ New Offering"**
3. Identifier: `default`
4. Display name: `Planos Premium`
5. Adicione os 3 produtos criados:
   - Weekly subscription
   - Annual subscription  
   - Lifetime purchase
6. Marque **"Make this the current offering"**
7. Clique em **"Save"**

## 4. Configurar App Store / Play Store

### iOS (App Store Connect)

1. Acesse https://appstoreconnect.apple.com
2. Meu app → **"Assinaturas"** ou **"Compras no App"**
3. Criar 3 produtos com os mesmos IDs:
   - `weekly_subscription` - Assinatura renovável automática - 1 semana - $2.99
   - `annual_subscription` - Assinatura renovável automática - 1 ano - $29.99
   - `lifetime_purchase` - Compra não consumível - $49.99

4. Em cada produto:
   - Adicionar descrições
   - Fazer upload de screenshot de review (pode ser mock)
   - Marcar como "Ready to Submit"

5. Copiar **Shared Secret** (App Store Connect → Meu app → App Information → App-Specific Shared Secret)

6. No RevenueCat:
   - Va para **Project Settings** → **Apple App Store**
   - Cole o Shared Secret
   - Habilite **"Sandbox Testing"**

### Android (Google Play Console)

1. Acesse https://play.google.com/console
2. Seu app → **"Monetização"** → **"Produtos"**
3. Criar os mesmos 3 produtos:
   - `weekly_subscription` - Assinatura - 1 semana - R$ 14,99
   - `annual_subscription` - Assinatura - 1 ano - R$ 149,99
   - `lifetime_purchase` - Produto gerenciado - R$ 249,99

4. Copiar **Service Account JSON**:
   - Google Cloud Console → IAM → Service Accounts
   - Criar ou usar conta existente
   - Download JSON key

5. No RevenueCat:
   - Va para **Project Settings** → **Google Play**
   - Upload Service Account JSON
   - Habilite **"Sandbox Testing"**

## 5. Obter API Keys

1. No RevenueCat dashboard, clique em **Project Settings** (ícone de engrenagem)
2. Clique em **"API keys"**
3. Copie:
   - **Public API Key (Apple)**: `appl_xxxxx`
   - **Public API Key (Google)**: `goog_xxxxx`

## 6. Configurar no App

No arquivo `main_common.dart`, adicione após Supabase:

```dart
// Initialize RevenueCat
final revenuecatKey = Platform.isIOS 
  ? 'appl_YOUR_IOS_KEY'
  : 'goog_YOUR_ANDROID_KEY';

await SubscriptionService.initialize(apiKey: revenuecatKey);
```

Ou simplesmente use a key conforme instrução no BingoSDK.initialize.

## 7. Testar com Sandbox

### iOS
1. Settings → App Store → Sandbox Account
2. Adicionar conta de teste (criar no App Store Connect)
3. Rodar app em dispositivo/simulator
4. Tentar comprar → Usar conta sandbox

### Android  
1. Play Console → Licença → Adicionar email de teste
2. Usar esse email no dispositivo
3. Rodar app
4. Tentar comprar → Modo sandbox automático

## 8. Verificar Webhooks

1. No RevenueCat, vá para **"Integrations"**
2. Adicione **"Webhooks"** (opcional para notificações)
3. URL: Sua API backend (se tiver)

## 9. Dashboard e Analytics

Após as primeiras compras, você verá no RevenueCat dashboard:
- Revenue
- Active subscriptions
- Churn rate
- Conversion rate

## Pronto! 🎉

RevenueCat está configurado e pronto para processar pagamentos.

**IMPORTANTE**: Nunca commite API keys no código! Use variáveis de ambiente.
