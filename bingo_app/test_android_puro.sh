#!/bin/bash

# Script para teste Android puro (sem Flutter)
echo "🤖 Teste Android Puro (Sem Flutter)..."

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

# 2. Teste Android puro com timeout
echo "🚀 Enviando teste Android puro para Firebase..."
echo "📊 Resultados: https://console.firebase.google.com/project/bingo-lucca-app/testlab"

gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/dev/debug/app-dev-debug.apk \
  --test build/app/outputs/apk/androidTest/dev/debug/app-dev-debug-androidTest.apk \
  --device model=SmallPhone.arm,version=30,locale=en_US,orientation=portrait \
  --timeout 2m \
  --test-targets "class com.nightstudios.bingo.SimpleAndroidTest#useAppContext"

echo "✅ Teste Android puro concluído!"
