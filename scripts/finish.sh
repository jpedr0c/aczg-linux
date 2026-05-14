#!/bin/bash
# Uso: aczgfinish <nome-da-entrega>

if [ $# -lt 1 ]; then
  echo "❌ Use: aczgfinish <nome-da-entrega>"
  exit 1
fi

NOME_ENTREGA="$1"
BRANCH="dev-feature-$NOME_ENTREGA"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "❌ Você não está dentro de um repositório Git!"
  exit 1
fi

if ! git branch | grep -q "$BRANCH"; then
  echo "❌ Branch '$BRANCH' não encontrada localmente!"
  exit 1
fi

echo "🔀 Voltando para a master..."
git checkout master

echo ""
echo "🔗 Realizando merge de '$BRANCH' na master..."
if ! git merge "$BRANCH"; then
  echo "❌ Merge falhou! Resolva os conflitos antes de continuar."
  exit 1
fi

echo "✅ Merge realizado com sucesso!"

echo ""
echo "🗑️  Deletando branch local '$BRANCH'..."
git branch -d "$BRANCH"

if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
  echo "🗑️  Deletando branch remota 'origin/$BRANCH'..."
  git push origin --delete "$BRANCH"
else
  echo "ℹ️  Branch remota não encontrada, pulando remoção remota."
fi

echo ""
echo "✅ Feature '$NOME_ENTREGA' finalizada e branch removida!"