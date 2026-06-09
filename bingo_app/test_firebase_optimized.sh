#!/bin/bash

# Script otimizado para Firebase Test Lab
echo "🔧 Testando Firebase Test Lab (Otimizado)..."

# 1. Verificar e buildar APKs se necessário
echo "📱 Verificando APKs..."
if [ ! -f "build/app/outputs/apk/dev/debug/app-dev-debug.apk" ]; then
    echo "🏗️ Buildando APK do app..."
    cd android
    flutter build apk --debug --flavor dev
    cd ..
fi

if [ ! -f "build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk" ]; then
    echo "🏗️ Buildando APK de teste..."
    cd android
    ./gradlew app:assembleAndroidTest
    cd ..
fi

# 2. Rodar teste simples com timeout maior
echo "🚀 Enviando teste simples para Firebase Test Lab..."
echo "📊 Resultados em: https://console.firebase.google.com/project/bingo-lucca-app/testlab"

gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/dev/debug/app-dev-debug.apk \
  --test build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk \
  --device model=SmallPhone.arm,version=30,locale=en_US,orientation=portrait \
  --timeout 5m \
  --environment-variables "coverage=true,clearPackageData=true"

echo "✅ Teste concluído!"
