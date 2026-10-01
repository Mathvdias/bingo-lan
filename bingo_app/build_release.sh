#!/bin/bash

# Script para gerar App Bundle de release com minificação e ofuscação
echo "🔧 Limpando build anterior..."
flutter clean

echo "📦 Obtendo dependências..."
flutter pub get

echo "🔐 Verificando configuração de assinatura..."
if [ ! -f "android/key.properties" ]; then
    echo "❌ Arquivo key.properties não encontrado!"
    exit 1
fi

if [ ! -f "android/app/upload-keystore.jks" ]; then
    echo "❌ Arquivo upload-keystore.jks não encontrado!"
    exit 1
fi

# Permite ler do arquivo .env se ele existir
if [ -f .env ]; then
    echo "📝 Carregando variáveis do arquivo .env..."
    export $(grep -v '^#' .env | xargs)
fi

# Valida se as variáveis necessárias estão presentes
MISSING_VARS=()
[ -z "$RC_ANDROID_KEY" ] && MISSING_VARS+=("RC_ANDROID_KEY")
[ -z "$RC_IOS_KEY" ] && MISSING_VARS+=("RC_IOS_KEY")
[ -z "$CLARITY_PROJECT_ID" ] && MISSING_VARS+=("CLARITY_PROJECT_ID")

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Erro: As seguintes variáveis de ambiente são obrigatórias para produção:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Crie um arquivo .env na pasta 'bingo_app' ou defina-as na linha de comando antes de rodar o build."
    echo "Exemplo de comando:"
    echo "   RC_ANDROID_KEY=xxx RC_IOS_KEY=xxx CLARITY_PROJECT_ID=xxx ./build_release.sh"
    exit 1
fi

echo "🏗️ Gerando App Bundle de release com as chaves de produção..."
mkdir -p build/symbols
flutter build appbundle --release --flavor prod \
  --obfuscate --split-debug-info=build/symbols \
  --dart-define=RC_ANDROID_KEY="$RC_ANDROID_KEY" \
  --dart-define=RC_IOS_KEY="$RC_IOS_KEY" \
  --dart-define=CLARITY_PROJECT_ID="$CLARITY_PROJECT_ID" \
  --dart-define=ENVIRONMENT=prod

echo "✅ App Bundle gerado com sucesso!"
echo "📍 Localização: build/app/outputs/bundle/prodRelease/app-prod-release.aab"

echo "📊 Informações do build:"
echo "   - Minificação: ✅ Ativada"
echo "   - Ofuscação: ✅ Ativada (símbolos em build/symbols, envie ao Crashlytics)"
echo "   - Otimização de recursos: ✅ Ativada"
echo "   - Assinatura: ✅ Configurada"

echo ""
echo "🎯 Para testar o App Bundle:"
echo "   1. Faça upload do arquivo .aab no Google Play Console"
echo "   2. Ou use o bundletool para testar localmente:"
echo "      bundletool build-apks --bundle=build/app/outputs/bundle/prodRelease/app-prod-release.aab --output=app.apks --ks=android/app/upload-keystore.jks --ks-pass=pass:SUA_SENHA --key-pass=pass:SUA_SENHA"
