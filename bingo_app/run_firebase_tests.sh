#!/bin/bash

# Script para rodar integration tests no Firebase Test Lab
echo "🔧 Preparando Firebase Test Lab Integration Tests..."

# 1. Login no Google Cloud (se necessário)
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    echo "📝 Fazendo login no Google Cloud..."
    gcloud auth login
fi

# 2. Configurar projeto
echo "📱 Configurando projeto Firebase..."
gcloud config set project bingo-lucca-app

# 3. Build dos APKs
echo "🏗️ Buildando APKs para teste..."
cd android

# Build APK do app
flutter build apk --debug --flavor dev

# Build APK de teste
./gradlew app:assembleAndroidTest

cd ..

# 4. Upload para Firebase Test Lab
echo "🚀 Enviando para Firebase Test Lab..."

# Testar com um dispositivo específico
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/dev/debug/app-dev-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=Pixel2.arm,version=30,locale=en_US,orientation=portrait \
  --device model=SmallPhone.arm,version=30,locale=pt_BR,orientation=landscape \
  --timeout 5m \
  --results-bucket=bingo-test-results \
  --results-dir="integration-tests-$(date +%Y%m%d-%H%M%S)" \
  --environment-variables "coverage=true"

echo "✅ Testes enviados para Firebase Test Lab!"
echo "📊 Resultados disponíveis em: https://console.firebase.google.com/project/bingo-lucca-app/testlab"
echo "⏱️ Aguarde a conclusão dos testes..."
