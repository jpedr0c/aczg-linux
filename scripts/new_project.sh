#!/bin/bash
# Uso: aczg_new_project.sh <caminho> <nome-do-projeto>

if [ $# -lt 2 ]; then
  echo "❌ Use: aczgnew <caminho> <nome-do-projeto>"
  exit 1
fi

CAMINHO="$1"
NOME="$2"
DESTINO="$CAMINHO/$NOME"

if [ -d "$DESTINO" ]; then
  echo "❌ Já existe uma pasta em: $DESTINO"
  exit 1
fi

mkdir -p "$DESTINO"
echo "📁 Pasta criada: $DESTINO"

echo "projeto $NOME iniciado...." > "$DESTINO/README.md"
echo "📄 README.md criado"

cd "$DESTINO" || exit 1
git init
git add README.md
git commit -m "first commit - repositório configurado e README adicionado"

echo ""
echo "✅ Projeto '$NOME' inicializado com sucesso em $DESTINO"