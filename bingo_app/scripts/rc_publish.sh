#!/bin/bash
# Publica o Remote Config do ambiente: scripts/rc_publish.sh prod|dev
set -e
cd "$(dirname "$0")/.."
env="${1:?uso: rc_publish.sh prod|dev}"
case "$env" in
  prod) project=nightstudios-bingo ;;
  dev)  project=bingo-lucca-app ;;
  *) echo "ambiente inválido: $env"; exit 1 ;;
esac
cp "remoteconfig/$env.template.json" remoteconfig/active.template.json
firebase deploy --only remoteconfig --project "$project"
rm -f remoteconfig/active.template.json
