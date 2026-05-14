#!/bin/bash
# Configura Cron Job para commits diários automáticos
# Uso: auto_commit.sh [periodicidade_cron] [caminho_projeto]
# Exemplo: auto_commit.sh "0 18 * * *" /home/user/projetos/meu-app

CRON_SCHEDULE="${1:-0 18 * * *}"
PROJETO_DIR="${2:-$HOME/projeto}"
LOG_DIR="/var/log/aczg"
LOG_FILE="$LOG_DIR/ci-pipeline.log"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$LOG_DIR" ]; then
  sudo mkdir -p "$LOG_DIR"
  sudo chmod 777 "$LOG_DIR"
fi

COMMITTER_SCRIPT="$SCRIPT_DIR/run_commit.sh"

cat > "$COMMITTER_SCRIPT" << EOF
#!/bin/bash

PROJETO_DIR="$PROJETO_DIR"
LOG_FILE="$LOG_FILE"
TIMESTAMP=\$(date "+%Y-%m-%d %H:%M:%S")
DISPLAY=:0
XAUTHORITY="\$HOME/.Xauthority"
export DISPLAY XAUTHORITY

echo "" >> "\$LOG_FILE"
echo "[ACZG-CI] ----------------------------------------" >> "\$LOG_FILE"
echo "[ACZG-CI] Auto-commit iniciado: \$TIMESTAMP" >> "\$LOG_FILE"

cd "\$PROJETO_DIR" || {
  echo "[ACZG-CI][ERRO] Diretório não encontrado: \$PROJETO_DIR" >> "\$LOG_FILE"
  notify-send "ACZG Auto-commit ❌" "Diretório do projeto não encontrado!"
  exit 1
}

if git diff --quiet && git diff --cached --quiet; then
  echo "[ACZG-CI][INFO] Nenhuma alteração detectada. Commit ignorado." >> "\$LOG_FILE"
  notify-send "ACZG Auto-commit ℹ️" "Nenhuma alteração para commitar."
  exit 0
fi

git add -A
COMMIT_MSG="auto-commit: \$TIMESTAMP"
git commit -m "\$COMMIT_MSG" >> "\$LOG_FILE" 2>&1

EXIT_CODE=\$?
if [ \$EXIT_CODE -eq 0 ]; then
  echo "[ACZG-CI][OK] Commit realizado com sucesso: '\$COMMIT_MSG'" >> "\$LOG_FILE"
  notify-send "ACZG Auto-commit ✅" "Commit automático realizado com sucesso!"
else
  echo "[ACZG-CI][FALHA] Falha no commit em \$TIMESTAMP" >> "\$LOG_FILE"
  notify-send "ACZG Auto-commit ❌" "Falha no commit automático! Verifique os logs."
fi
EOF

chmod +x "$COMMITTER_SCRIPT"
echo "✅ Script de auto-commit criado: $COMMITTER_SCRIPT"

CRON_CMD="$CRON_SCHEDULE bash $COMMITTER_SCRIPT"

( crontab -l 2>/dev/null | grep -v "run_commit.sh" ; echo "$CRON_CMD" ) | crontab -

echo ""
echo "⏰ Cron Job de auto-commit registrada:"
echo "   $CRON_CMD"
echo ""
echo "📄 Logs serão salvos em: $LOG_FILE"
echo "✅ Auto-commit configurado com sucesso!"