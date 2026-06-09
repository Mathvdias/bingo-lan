#!/bin/bash

# Script para teste rápido no Firebase Test Lab
echo "⚡ Teste Rápido Firebase Test Lab..."

# 1. Build APKs se necessário
if [ ! -f "build/app/outputs/apk/dev/debug/app-dev-debug.apk" ]; then
    echo "🏗️ Buildando APK do app..."
    flutter build apk --debug --flavor dev
fi

if [ ! -f "build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk" ]; then
    echo "🏗️ Buildando APK de teste..."
    cd android
    ./gradlew app:assembleAndroidTest
    cd ..
fi

# 2. Teste rápido com timeout menor
echo "⚡ Enviando teste rápido para Firebase..."
echo "📊 Resultados: https://console.firebase.google.com/project/bingo-lucca-app/testlab"

gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/dev/debug/app-dev-debug.apk \
  --test build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk \
  --device model=SmallPhone.arm,version=30,locale=en_US,orientation=portrait \
  --timeout 3m \
  --environment-variables "clearPackageData=true"

echo "✅ Teste rápido concluído!"
