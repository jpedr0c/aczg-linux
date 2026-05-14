#!/bin/bash
# Exibe os logs do pipeline ACZG-CI registrados no arquivo de log
# Uso: aczglogs           → mostra todos os logs do pipeline
#      aczglogs --ok      → mostra apenas sucessos
#      aczglogs --falha   → mostra apenas falhas
#      aczglogs --n 50    → mostra as últimas 50 linhas filtradas

LOG_FILE="/var/log/aczg/ci-pipeline.log"

if [ ! -f "$LOG_FILE" ]; then
  echo "⚠️  Arquivo de log não encontrado: $LOG_FILE"
  echo "   O pipeline ainda não foi executado nenhuma vez."
  exit 1
fi

FILTRO="[ACZG-CI]"
LINHAS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --ok)
      FILTRO="[ACZG-CI][OK]"
      shift
      ;;
    --falha)
      FILTRO="[ACZG-CI][FALHA]"
      shift
      ;;
    --n)
      LINHAS="$2"
      shift 2
      ;;
    *)
      echo "❌ Argumento inválido: $1"
      echo "   Uso: aczglogs [--ok | --falha] [--n <numero>]"
      exit 1
      ;;
  esac
done

echo "📋 Logs do pipeline ACZG-CI"
echo "📄 Arquivo: $LOG_FILE"
echo "🔍 Filtro: $FILTRO"
echo "════════════════════════════════════════"

if [ -n "$LINHAS" ]; then
  grep "$FILTRO" "$LOG_FILE" | tail -n "$LINHAS"
else
  grep "$FILTRO" "$LOG_FILE"
fi

echo ""
echo "════════════════════════════════════════"
TOTAL_OK=$(grep -c "\[ACZG-CI\]\[OK\]" "$LOG_FILE")
TOTAL_FALHA=$(grep -c "\[ACZG-CI\]\[FALHA\]" "$LOG_FILE")
echo "✅ Sucessos registrados : $TOTAL_OK"
echo "❌ Falhas registradas   : $TOTAL_FALHA"