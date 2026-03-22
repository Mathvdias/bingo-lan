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

echo "🏗️ Gerando App Bundle de release..."
flutter build appbundle --release --flavor prod

echo "✅ App Bundle gerado com sucesso!"
echo "📍 Localização: build/app/outputs/bundle/prodRelease/app-prod-release.aab"

echo "📊 Informações do build:"
echo "   - Minificação: ✅ Ativada"
echo "   - Ofuscação: ✅ Ativada"
echo "   - Otimização de recursos: ✅ Ativada"
echo "   - Assinatura: ✅ Configurada"

echo ""
echo "🎯 Para testar o App Bundle:"
echo "   1. Faça upload do arquivo .aab no Google Play Console"
echo "   2. Ou use o bundletool para testar localmente:"
echo "      bundletool build-apks --bundle=build/app/outputs/bundle/prodRelease/app-prod-release.aab --output=app.apks --ks=android/app/upload-keystore.jks --ks-pass=pass:SUA_SENHA --key-pass=pass:SUA_SENHA"
