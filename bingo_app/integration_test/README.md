# Testes de Integração - Bingo App

Este diretório contém os testes E2E (end-to-end) para o aplicativo Bingo.

## 📋 Lista de Testes

### Testes Principais (Alta Prioridade)
- **`app_test.dart`** - Teste básico: splash → lobby → host setup
- **`player_flow_test.dart`** - Fluxo completo do jogador: lobby → scan → game
- **`solo_flow_test.dart`** - Fluxo solo mode: lobby → solo → draw numbers  
- **`host_flow_test.dart`** - Fluxo host completo: setup → invite → room

### Testes Secundários (Média Prioridade)
- **`permissions_test.dart`** - Comportamento de permissões de câmera
- **`deeplink_test.dart`** - Funcionalidade de deep link join

### Testes Adicionais (Baixa Prioridade)
- **`offline_test.dart`** - Comportamento offline
- **`paywall_test.dart`** - Interação com paywall

## 🚀 Como Executar

### Pré-requisitos
1. **Emulador Android** ou **Simulador iOS** rodando
2. **Firebase configurado** no projeto
3. **Permissões concedidas** (câmera, etc.)

### Executar Todos os Testes
```bash
flutter test integration_test/
```

### Executar Teste Específico
```bash
# Teste básico
flutter test integration_test/app_test.dart

# Fluxo do jogador
flutter test integration_test/player_flow_test.dart

# Fluxo solo
flutter test integration_test/solo_flow_test.dart

# Fluxo host
flutter test integration_test/host_flow_test.dart

# Permissões
flutter test integration_test/permissions_test.dart

# Deep link
flutter test integration_test/deeplink_test.dart

# Offline
flutter test integration_test/offline_test.dart

# Paywall
flutter test integration_test/paywall_test.dart
```

### Executar com Verbosidade
```bash
flutter test integration_test/ --verbose
```

## 📱 Configuração do Dispositivo

### Android
- Iniciar emulador: `flutter emulators --launch <emulator_name>`
- Verificar dispositivos: `flutter devices`

### iOS  
- Iniciar simulador: `open -a Simulator`
- Verificar dispositivos: `flutter devices`

## 🔧 Keys e Identificadores

Os testes usam as seguintes keys para encontrar widgets:

### Telas (Screens)
- `splash_screen` - Tela de splash
- `lobby_screen` - Tela principal do lobby
- `player_scan_screen` - Tela de scan QR do jogador
- `solo_game_screen` - Tela de jogo solo
- `host_setup_screen` - Tela de configuração do host

### Botões (Buttons)
- `lobby_btn_host` - Botão "Começar Bingo" (host)
- `lobby_btn_join` - Botão "Entrar no Bingo" (jogador)
- `lobby_btn_solo` - Botão "Jogar Solo"
- `solo_draw_button` - Botão "Sortear Número" (solo)
- `create_room_button` - Botão "Criar Sala" (host)
- `start_room_button` - Botão "Iniciar Bingo" (host)

### Campos (Fields)
- `room_name_field` - Campo de nome da sala

## ⚠️ Limitações e Considerações

### QR Code Scanning
- O `MobileScanner` não pode ser facilmente mockado em testes de integração
- Testes atuais verificam apenas o fluxo UI
- Para testes completos de QR, ser necessário implementar mocks específicos

### Permissões
- Testes de permissões dependem do estado do dispositivo
- Em CI/CD, pode ser necessário configurar permissões previamente

### Firebase
- Testes requerem Firebase configurado no emulador/simulador
- Não funcionam no `flutter_tester` (VM sem canal nativo)

### Conectividade
- Testes offline simulam comportamento, mas não desconectam realmente
- Para testes reais offline, usar modo avião ou desativar rede

## 🐛 Troubleshooting

### Erros Comuns

**"No connected device"**
```bash
flutter devices
# Verificar se há emulador/simulador rodando
```

**"Firebase not initialized"**
- Verificar configuração do Firebase
- Usar emulador com Google Play Services

**"Permission denied"**
- Conceder permissões manualmente no emulador
- Configurar permissões nas configurações do dispositivo

**"Widget not found"**
- Verificar se as Keys estão corretas nos widgets
- Usar `flutter test --verbose` para debug

### Debug de Testes

```bash
# Executar com debug
flutter test integration_test/app_test.dart --debug

# Verificar logs detalhados
flutter test integration_test/ --verbose

# Parar em falhas
flutter test integration_test/ --stop-on-first-failure
```

## 🔄 CI/CD Integration

Para usar em GitHub Actions ou outro CI:

```yaml
- name: Run Integration Tests
  run: |
    flutter emulators --launch android_emulator
    flutter test integration_test/
```

## 📈 Cobertura de Testes

Atualmente os testes cobrem:
- ✅ Fluxos principais de navegação
- ✅ Interação básica com UI
- ✅ Comportamento em diferentes cenários
- ⚠️ QR scanning (limitado)
- ⚠️ Firebase real-time (requer setup específico)
- ⚠️ Compras reais (não testadas em CI)

## 🚧 Próximos Passos

1. **Mock do MobileScanner** para testes completos de QR
2. **Testes de performance** e memory leaks
3. **Testes de acessibilidade**
4. **Testes multi-idioma**
5. **Testes de diferentes tamanhos de tela**
