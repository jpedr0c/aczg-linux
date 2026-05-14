#!/bin/bash
# Configura a Cron Job de CI: roda testes Gradle, gera log e lança alerta
# Uso: setup_ci.sh [periodicidade_cron] [caminho_projeto] [nome_projeto]
# Exemplo: setup_ci.sh "0 8 * * *" /home/user/projetos meu-app

CRON_SCHEDULE="${1:-0 8 * * *}"
PROJETO_DIR="${2:-$HOME/projeto}"
PROJETO_NOME="${3:-aczg-project}"
LOG_DIR="/var/log/aczg"
LOG_FILE="$LOG_DIR/ci-pipeline.log"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$LOG_DIR" ]; then
  echo "📁 Criando diretório de logs em $LOG_DIR (requer sudo)..."
  sudo mkdir -p "$LOG_DIR"
  sudo chmod 777 "$LOG_DIR"
fi

RUNNER_SCRIPT="$SCRIPT_DIR/run_tests.sh"

cat > "$RUNNER_SCRIPT" << EOF
#!/bin/bash

PROJETO_DIR="$PROJETO_DIR"
PROJETO_NOME="$PROJETO_NOME"
LOG_FILE="$LOG_FILE"
TIMESTAMP=\$(date "+%Y-%m-%d %H:%M:%S")
DISPLAY=:0  # necessário para o notify-send funcionar via cron
XAUTHORITY="\$HOME/.Xauthority"
export DISPLAY XAUTHORITY

echo "" >> "\$LOG_FILE"
echo "[ACZG-CI] ========================================" >> "\$LOG_FILE"
echo "[ACZG-CI] Início do pipeline: \$TIMESTAMP" >> "\$LOG_FILE"
echo "[ACZG-CI] Projeto: \$PROJETO_NOME" >> "\$LOG_FILE"
echo "[ACZG-CI] ========================================" >> "\$LOG_FILE"

cd "\$PROJETO_DIR" || {
  echo "[ACZG-CI][ERRO] Diretório não encontrado: \$PROJETO_DIR" >> "\$LOG_FILE"
  notify-send "ACZG CI ❌" "Diretório do projeto não encontrado!"
  exit 1
}

echo "[ACZG-CI] Executando testes com Gradle..." >> "\$LOG_FILE"
./gradlew test >> "\$LOG_FILE" 2>&1
EXIT_CODE=\$?

if [ \$EXIT_CODE -eq 0 ]; then
  echo "[ACZG-CI][OK] Testes passaram com sucesso em \$TIMESTAMP" >> "\$LOG_FILE"
  notify-send "ACZG CI ✅" "Testes de '\$PROJETO_NOME' passaram com sucesso!"
  echo "[ACZG-CI] Prosseguindo para o próximo estágio do pipeline..." >> "\$LOG_FILE"
else
  echo "[ACZG-CI][FALHA] Testes falharam em \$TIMESTAMP (exit code: \$EXIT_CODE)" >> "\$LOG_FILE"
  notify-send "ACZG CI ❌" "Testes de '\$PROJETO_NOME' FALHARAM! Verifique os logs."
  exit 1
fi
EOF

chmod +x "$RUNNER_SCRIPT"
echo "✅ Script executor criado: $RUNNER_SCRIPT"

CRON_CMD="$CRON_SCHEDULE bash $RUNNER_SCRIPT"

( crontab -l 2>/dev/null | grep -v "run_tests.sh" ; echo "$CRON_CMD" ) | crontab -

echo ""
echo "⏰ Cron Job de CI registrada:"
echo "   $CRON_CMD"
echo ""
echo "📄 Logs serão salvos em: $LOG_FILE"
echo "✅ Pipeline de CI configurado com sucesso!"