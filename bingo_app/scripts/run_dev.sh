#!/bin/bash
# Roda o flavor dev com as chaves lidas de bingo_app/.env (nunca versionado).
# Copie .env.example para .env e preencha.
set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
else
  echo "Aviso: .env não encontrado; rodando sem chaves (compras desativadas)."
fi

if [ -n "${RC_TEST_STORE_KEY:-}" ]; then
  echo "RevenueCat: usando Test Store (RC_TEST_STORE_KEY)."
fi

flutter run -t lib/main_dev.dart --flavor dev \
  --dart-define=RC_ANDROID_KEY="${RC_ANDROID_KEY:-}" \
  --dart-define=RC_IOS_KEY="${RC_IOS_KEY:-}" \
  --dart-define=RC_TEST_STORE_KEY="${RC_TEST_STORE_KEY:-}" \
  --dart-define=ENVIRONMENT=dev \
  "$@"
