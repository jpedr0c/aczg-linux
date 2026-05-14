#!/bin/bash
# Uso: aczginit <nome-da-entrega>

if [ $# -lt 1 ]; then
  echo "❌ Use: aczginit <nome-da-entrega>"
  exit 1
fi

NOME_ENTREGA="$1"
BRANCH="dev-feature-$NOME_ENTREGA"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "❌ Você não está dentro de um repositório Git!"
  exit 1
fi

echo "📋 Status atual do repositório:"
echo "────────────────────────────────"
git status

echo ""
echo "🌿 Criando branch: $BRANCH"
git checkout -b "$BRANCH"

echo ""
echo "🌐 Branches locais e remotas:"
echo "────────────────────────────────"
git branch -a