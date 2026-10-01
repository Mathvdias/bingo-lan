# 🧪 Integration Tests - Firebase Test Lab

## 📋 Visão Geral

Este projeto está configurado para rodar **Integration Tests** tanto localmente quanto no **Firebase Test Lab**.

## 🏗️ Estrutura do Projeto

```
bingo_app/
├── integration_test/          # Testes de integração
│   ├── app_test.dart
│   ├── solo_flow_test.dart
│   ├── host_flow_test.dart
│   └── player_flow_test.dart
├── test_driver/              # Driver scripts
│   └── integration_test.dart
├── android/app/src/androidTest/  # Configuração Android
│   └── java/com/nightstudios/bingo/
│       └── MainActivityTest.java
└── scripts/
    ├── run_local_tests.sh    # Testes locais
    └── run_firebase_tests.sh # Firebase Test Lab
```

## 🚀 Como Usar

### Opção 1: Testes Locais (Recomendado para Desenvolvimento)

```bash
# 1. Conectar um dispositivo Android ou iniciar emulador
# 2. Rodar os testes
./run_local_tests.sh

# Ou manualmente:
cd android
flutter build apk --debug --flavor dev
./gradlew app:assembleAndroidTest
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/app_test.dart
```

### Opção 2: Firebase Test Lab (Recomendado para CI/CD)

```bash
# 1. Login no Google Cloud (primeira vez apenas)
gcloud auth login
gcloud config set project bingo-lucca-app

# 2. Rodar testes no Firebase
./run_firebase_tests.sh

# Ou manualmente:
cd android
flutter build apk --debug --flavor dev
./gradlew app:assembleAndroidTest

gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/dev/debug/app-dev-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=Pixel2,version=30,locale=en_US,orientation=portrait \
  --timeout 5m
```

## 📱 Dispositivos Disponíveis no Firebase Test Lab

### Android Dispositivos Populares
- **Pixel2** (API 30) - Rápido e confiável
- **Pixel3** (API 30) - Mais recente
- **Small Phone** (API 30) - Teste em tela pequena
- **Medium Phone** (API 30) - Teste em tela média

### Configurações de Teste
```bash
# Múltiplos dispositivos
--device model=Pixel2,version=30,locale=en_US,orientation=portrait \
--device model=Pixel3,version=30,locale=pt_BR,orientation=landscape

# Configurações específicas
--timeout 10m                    # Timeout em minutos
--environment-variables "coverage=true"  # Variáveis de ambiente
--results-bucket=bingo-test-results     # Bucket para resultados
```

## 🔧 Configuração

### Pré-requisitos
1. **Android Studio** com emuladores configurados
2. **Google Cloud SDK** instalado
3. **Firebase Project** configurado
4. **Dispositivo Android** conectado (para testes locais)

### Instalação do Google Cloud SDK
```bash
# macOS
brew install google-cloud-sdk

# Login e configuração
gcloud auth login
gcloud config set project bingo-lucca-app
```

## 📊 Resultados

### Testes Locais
- **Console output** direto no terminal
- **Relatórios** em `build/reports/androidTests/`
- **Screenshots** em `build/outputs/androidTest-results/`

### Firebase Test Lab
- **Dashboard** em: https://console.firebase.google.com/project/bingo-lucca-app/testlab
- **Relatórios detalhados** com performance
- **Screenshots** e **vídeos** dos testes
- **Logs** completos para debugging

## 🎯 Testes Disponíveis

| Teste | Descrição | Fluxo |
|-------|-----------|-------|
| `app_test.dart` | Teste básico do app | Splash → Lobby |
| `solo_flow_test.dart` | Modo solo | Lobby → Solo Game |
| `host_flow_test.dart` | Modo host | Lobby → Host Setup |
| `player_flow_test.dart` | Modo player | Lobby → Scan QR |
| `permissions_test.dart` | Permissões | Câmera, Wi-Fi |
| `offline_test.dart` | Comportamento offline | Sem conexão |

## ⚡ Dicas e Truques

### 1. Testes Rápidos
```bash
# Testar apenas um arquivo
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/app_test.dart
```

### 2. Debug de Testes
```bash
# Verbose output
./gradlew app:connectedAndroidTest --info

# Ver dispositivos conectados
adb devices
```

### 3. Firebase Test Lab Economia
```bash
# Testar em apenas um dispositivo primeiro
--device model=Pixel2,version=30,locale=en_US,orientation=portrait

# Timeout menor para testes rápidos
--timeout 2m
```

## 🔍 Troubleshooting

### Problemas Comuns

**❌ "No devices found"**
```bash
# Verificar dispositivos
adb devices
flutter devices

# Iniciar emulador
emulator @Small_Phone
```

**❌ "BUILD FAILED"**
```bash
# Limpar e rebuild
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
```

**❌ "Firebase authentication failed"**
```bash
# Relogin
gcloud auth login
gcloud config set project bingo-lucca-app
```

## 📈 Melhores Práticas

1. **Testes Locais Primeiro** - Sempre valide localmente antes do Firebase
2. **Testes Específicos** - Use `-Ptarget` para testar arquivos específicos
3. **Timeout Adequado** - Configure timeout baseado na complexidade do teste
4. **Múltiplos Dispositivos** - Teste em diferentes tamanhos de tela
5. **CI/CD Integration** - Configure para rodar automaticamente

## 🚀 Deploy Automatizado

Para CI/CD, adicione ao seu pipeline:

```yaml
# .github/workflows/test.yml
- name: Run Integration Tests
  run: ./run_firebase_tests.sh
```

---

**Nota:** Os integration tests são mais lentos que unit tests, mas fornecem validação completa do fluxo do usuário! 🎯
