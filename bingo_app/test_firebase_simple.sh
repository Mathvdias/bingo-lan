#!/bin/bash

# Script simples para testar Firebase Test Lab
echo "🔧 Testando Firebase Test Lab (Simples)..."

# 1. Verificar se os APKs existem
echo "📱 Verificando APKs..."
if [ ! -f "build/app/outputs/apk/dev/debug/app-dev-debug.apk" ]; then
    echo "❌ APK do app não encontrado. Buildando..."
    cd android
    flutter build apk --debug --flavor dev
    cd ..
fi

if [ ! -f "build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk" ]; then
    echo "❌ APK de teste não encontrado. Buildando..."
    cd android
    ./gradlew app:assembleAndroidTest
    cd ..
fi

# 2. Rodar teste simples no Firebase
echo "🚀 Enviando para Firebase Test Lab..."
echo "📊 Resultados em: https://console.firebase.google.com/project/bingo-lucca-app/testlab"

gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/dev/debug/app-dev-debug.apk \
  --test build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk \
  --device model=SmallPhone.arm,version=30,locale=en_US,orientation=portrait \
  --timeout 3m

echo "✅ Teste concluído!"
