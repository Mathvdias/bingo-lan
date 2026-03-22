#!/bin/bash

# Script para rodar integration tests localmente
echo "🔧 Preparando Integration Tests Locais..."

# 1. Verificar se há dispositivos conectados
echo "📱 Verificando dispositivos..."
adb devices

# 2. Build dos APKs
echo "🏗️ Buildando APKs para teste..."
cd android

# Build APK do app
flutter build apk --debug --flavor dev

# Build APK de teste
./gradlew app:assembleAndroidTest

cd ..

# 3. Rodar testes localmente
echo "🧪 Rodando testes de integração..."

# Rodar um teste específico
echo "📊 Testando app_test.dart..."
cd android
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/app_test.dart
cd ..

echo "✅ Testes locais concluídos!"
echo "📊 Verifique os resultados no console"
