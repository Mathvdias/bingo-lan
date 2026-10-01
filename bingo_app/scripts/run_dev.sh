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
  echo "Aviso: .env não encontrado; rodando sem chaves (compras e Clarity desativados)."
fi

flutter run -t lib/main_dev.dart --flavor dev \
  --dart-define=RC_ANDROID_KEY="${RC_ANDROID_KEY:-}" \
  --dart-define=RC_IOS_KEY="${RC_IOS_KEY:-}" \
  --dart-define=CLARITY_PROJECT_ID="${CLARITY_PROJECT_ID:-}" \
  --dart-define=ENVIRONMENT=dev \
  "$@"
