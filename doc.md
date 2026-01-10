## 1. Definição do Produto e Escopo

### 1.1. Resumo Executivo

Aplicativo cross-platform (Android/iOS) para gestão de bingos presenciais.

* **Problema:** Falta de equipamentos (globo, som) em festas.
* **Solução:** App Híbrido. O celular do Host vira o servidor (via Wi-Fi ou Nuvem), o celular dele vira o microfone (Megafone) e os convidados usam seus celulares como cartelas digitais.
* **Modelo:** Freemium (Host Pay).

### 1.2. Matriz de Feature Flags (Gatekeeper)

Todas as features premium são protegidas por flags no Firebase Remote Config.

| Chave (Key) | Tipo | Default (Família) | Descrição |
| --- | --- | --- | --- |
| `is_megafone_paid` | `bool` | `false` | Cobra pelo uso do Microfone? |
| `is_globo_paid` | `bool` | `false` | Cobra pelo acesso ao Sorteio? |
| `is_localhost_paid` | `bool` | `false` | Cobra para criar sala Wi-Fi? |
| `is_onlinehost_paid` | `bool` | `false` | Cobra para criar sala Online? |
| `is_validation_paid` | `bool` | `false` | Cobra para validar cartela automaticamente? |
| `max_free_online_users` | `int` | `10` | Limite de usuários em sala online grátis. |

---

## 2. Arquitetura de Software (Detalhada)

### 2.1. Estrutura do Monorepo

```text
/bingo-project/
├── /bingo_core/          [PACKAGE DART] (Lógica, Infra, Drivers)
│   ├── pubspec.yaml
│   ├── lib/
│       ├── src/
│           ├── drivers/  (Adapters para libs externas)
│           ├── logic/    (Regras de Negócio Puras: AccessControl, BingoLogic)
│           ├── models/   (Data Classes: RoomInfo, BingoCard)
│           └── api/      (Fachada pública do SDK)
│
├── /bingo_app/           [FLUTTER APP] (UI, Assets, ViewModels)
│   ├── pubspec.yaml
│   ├── lib/
│       ├── main.dart
│       ├── features/     (Módulos da UI: Lobby, Game, Megafone)
│       └── shared/       (Widgets globais)

```

### 2.2. Padrão de UI: MVVM Nativo (Triple)

* **View:** `StatelessWidget` + `ListenableBuilder`.
* **ViewModel:** `ChangeNotifier` (gerencia estado global da tela) ou `ValueNotifier` (granular).
* **Model:** Interfaces do `bingo_core`.

---

## 3. Especificação do SDK (`bingo_core`)

### 3.1. Interfaces dos Drivers (Contratos)

**A. `IConfigDriver` (Remote Config)**

```dart
abstract class IConfigDriver {
  Future<void> fetchAndActivate();
  bool getBool(String key);
  int getInt(String key);
}

```

**B. `IAudioDriver` (Megafone)**

```dart
abstract class IAudioDriver {
  Future<bool> requestPermission();
  Future<void> startLoopback(); // Inicia Mic -> Speaker
  Future<void> stopLoopback();
  Stream<double> get volumeStream; // Opcional: Para animação de ondas sonoras
}

```

**C. `IGameConnection` (Conectividade Polimórfica)**
Esta interface é implementada duas vezes: uma para `LocalShelf` e outra para `RemoteSupabase`.

```dart
abstract class IGameConnection {
  // Host Methods
  Future<void> hostRoom(String roomName);
  Future<void> broadcastEvent(GameEvent event);
  
  // Player Methods
  Future<void> joinRoom(String connectionId); // IP ou Código
  Future<void> sendPlayerEvent(PlayerEvent event);
  
  // Common
  Stream<GameEvent> get eventStream; // Escuta o jogo
  Future<void> disconnect();
}

```

**D. `IPaymentDriver` (RevenueCat)**

```dart
abstract class IPaymentDriver {
  Future<void> init();
  Future<bool> get isProUser;
  Future<void> purchasePro();
  Future<void> restorePurchases();
}

```

### 3.2. Lógica de Acesso (`AccessControlService`)

```dart
class AccessControlService {
  final IConfigDriver _config;
  final IPaymentDriver _payment;

  // Lógica Mestra: (Flag Livre) OU (Pagou)
  bool canAccess(String featureKey) {
    bool isPaidFeature = _config.getBool(featureKey);
    if (!isPaidFeature) return true; // É grátis (Modo Família)
    return _payment.isProUser; // Verifica se comprou
  }
}

```

---

## 4. Protocolos de Dados (O "Contrato" Rede)

Como o app funciona tanto via WebSocket local quanto Internet, o protocolo JSON deve ser idêntico.

### 4.1. Modelo da Cartela (Otimização)

Não enviamos a matriz 5x5. Enviamos a `SEED`.

```dart
class BingoCard {
  final int id; // Seed
  List<int> get matrix => _generateMatrix(id); // Gera determinístico
  
  static List<int> _generateMatrix(int seed) {
    final random = Random(seed);
    // ... lógica B-I-N-G-O aqui ...
  }
}

```

### 4.2. Mensagens WebSocket (JSON)

**Type: `SYNC_STATE` (Host -> Player ao conectar)**

```json
{
  "type": "SYNC_STATE",
  "payload": {
    "drawn_numbers": [1, 15, 42],
    "last_number": 42,
    "status": "PLAYING"
  }
}

```

**Type: `NUMBER_DRAWN` (Host -> Player)**

```json
{
  "type": "NUMBER_DRAWN",
  "payload": { "number": 66 }
}

```

**Type: `SHOUT_BINGO` (Player -> Host)**

```json
{
  "type": "SHOUT_BINGO",
  "payload": {
    "card_id": 99281,
    "player_name": "Tio Zé"
  }
}

```

---

## 5. Fluxos de Tela e Navegação (`bingo_app`)

Usando `go_router`.

### 5.1. Mapa de Rotas

* `/` (Splash -> Init SDK)
* `/lobby` (Tela Inicial: Escolha entre Jogar ou Organizar)
* `/megafone` (Tela isolada do microfone grátis)
* `/paywall` (Modal de Venda)
* `/host`
* `/setup` (Escolha: Local vs Online)
* `/room` (Painel do Globo e Validação)


* `/player`
* `/scan` (Procura Wi-Fi ou Digita Código)
* `/game` (A Cartela)



### 5.2. Detalhe da Tela: `HostGameScreen`

* **ViewModel:** `HostGameViewModel`
* **Estado:**
* `lastNumber` (ValueNotifier<int>)
* `history` (ValueNotifier<List<int>>)
* `bingoClaims` (ValueNotifier<List<Claim>>) - Fila de quem gritou bingo.


* **UI:**
* Centro: Número Gigante.
* Rodapé: Botão "Sortear Próximo".
* Topo: Botão "Validar" (abre dialog para digitar ID da cartela).



---

## 6. Tratamento de Erros e Resiliência

### 6.1. Perda de Conexão (Modo Local)

Se o Host fechar o app ou o Wi-Fi cair:

1. **SDK Player:** Detecta desconexão do WebSocket.
2. **UI Player:** Mostra "Reconectando ao Host...".
3. **Lógica:** O SDK tenta reconectar no mesmo IP a cada 2 segundos por 1 minuto.

### 6.2. Perda de Conexão (Modo Online)

O `supabase_flutter` gerencia a reconexão automática. A UI deve mostrar um ícone de "Offline" se a internet cair.

### 6.3. Falha no Microfone

Se `IAudioDriver` falhar (permissão negada ou erro de hardware):

* UI exibe Snackbar: "Não foi possível acessar o microfone. Verifique as configurações."
* O App **não** deve travar (Crash Free).

---

## 7. Setup do Projeto (Passo a Passo)

### Passo 1: Dependências Finais

**`bingo_core/pubspec.yaml`**

```yaml
dependencies:
  # Core
  shelf: ^1.4.1
  shelf_web_socket: ^1.0.4
  web_socket_channel: ^2.4.0
  bonsoir: ^2.0.0
  supabase_flutter: ^2.3.0
  network_info_plus: ^5.0.1
  
  # Hardware
  sound_stream: ^0.3.0
  audio_session: ^0.1.18
  permission_handler: ^11.1.0
  
  # Logic
  firebase_remote_config: ^4.3.8
  purchases_flutter: ^6.1.0
  get_it: ^7.6.6
  uuid: ^4.2.1

```

**`bingo_app/pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  bingo_core:
    path: ../bingo_core
  
  # UI Libs
  go_router: ^13.0.1
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0
  wakelock_plus: ^1.1.0
  lottie: ^3.0.0 # Para animação de Bingo!

```

### Passo 2: Inicialização (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializa SDK
  await BingoSDK.initialize(
    supabaseUrl: "...",
    supabaseKey: "...",
    revenueCatKey: "...",
  );

  // 2. Busca Flags (Gatekeeper)
  final config = GetIt.I.get<IConfigDriver>();
  await config.fetchAndActivate();

  runApp(const BingoApp());
}

```

---

## 8. Estratégia de Testes

Como vamos testar sem o globo físico e sem 20 pessoas?

1. **Teste de Unidade (SDK):**
* Testar geração de cartela (`BingoCard.matrix`) para garantir que a Seed 1024 sempre gera os mesmos números.
* Testar `AccessControlService` mockando as flags (True/False) e vendo se libera/bloqueia.


2. **Teste de Integração (Local):**
* Rodar o App em 2 Simulators (ou 1 Real + 1 Simulator).
* Conectar via `localhost` (encaminhamento de porta `adb reverse` se for Android).


3. **Teste de Áudio:**
* Obrigatório dispositivo real. Simulators não emulam Bluetooth loopback corretamente.



---

Este documento cobre **absolutamente tudo** o que é necessário para construir o **Bingo Raiz Tech** de forma profissional, escalável e segura. Pode iniciar o `flutter create`!