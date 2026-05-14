#!/bin/bash
# Instalador do ambiente ACZG Hero Project
# Uso: ./setup.sh [caminho_projeto_gradle] [nome_projeto_gradle]
# Exemplo: ./setup.sh /home/user/projetos/meu-app meu-app

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ACZG_SCRIPTS_DIR="$HOME/.aczg/scripts"
ALIASES_FILE="$HOME/.aczg/aliases.sh"
LOG_DIR="/var/log/aczg"

PROJETO_DIR="${1:-$HOME/projeto}"
PROJETO_NOME="${2:-aczg-project}"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

print_header() {
  echo ""
  echo -e "${BLUE}${BOLD}══════════════════════════════════════════${NC}"
  echo -e "${BLUE}${BOLD}  $1${NC}"
  echo -e "${BLUE}${BOLD}══════════════════════════════════════════${NC}"
}

print_ok()   { echo -e "  ${GREEN}✅ $1${NC}"; }
print_info() { echo -e "  ${YELLOW}ℹ️  $1${NC}"; }
print_err()  { echo -e "  ${RED}❌ $1${NC}"; }

clear
echo -e "${BOLD}"
echo "  ░█████╗░░█████╗░███████╗░██████╗░"
echo "  ██╔══██╗██╔══██╗╚════██║██╔════╝░"
echo "  ███████║██║░░╚═╝░░███╔═╝██║░░██╗░"
echo "  ██╔══██║██║░░██╗██╔══╝░░██║░░╚██╗"
echo "  ██║░░██║╚█████╔╝███████╗╚██████╔╝"
echo "  ╚═╝░░╚═╝░╚════╝░╚══════╝░╚═════╝░"
echo -e "${NC}"
echo -e "  ${BOLD}ACZG Hero Project — Instalador${NC}"
echo -e "  Projeto Gradle : ${YELLOW}$PROJETO_NOME${NC}"
echo -e "  Caminho        : ${YELLOW}$PROJETO_DIR${NC}"
echo -e "  Scripts em     : ${YELLOW}$ACZG_SCRIPTS_DIR${NC}"

print_header "ETAPA 1 — Verificando dependências"

for DEP in git bash grep crontab notify-send; do
  if command -v "$DEP" &>/dev/null; then
    print_ok "$DEP encontrado"
  else
    print_err "$DEP não encontrado — instale antes de continuar"
    exit 1
  fi
done

print_header "ETAPA 2 — Criando estrutura de diretórios"

mkdir -p "$ACZG_SCRIPTS_DIR"
print_ok "Diretório de scripts: $ACZG_SCRIPTS_DIR"

if [ ! -d "$LOG_DIR" ]; then
  sudo mkdir -p "$LOG_DIR"
  sudo chmod 777 "$LOG_DIR"
  print_ok "Diretório de logs criado: $LOG_DIR"
else
  print_info "Diretório de logs já existe: $LOG_DIR"
fi

print_header "ETAPA 3 — Instalando scripts"

SCRIPTS=(
  "aczg_new_project.sh"
  "aczginit.sh"
  "aczgfinish.sh"
  "setup_ci.sh"
  "auto_commit.sh"
  "show_logs.sh"
)

for SCRIPT in "${SCRIPTS[@]}"; do
  SRC="$REPO_DIR/scripts/$SCRIPT"
  DST="$ACZG_SCRIPTS_DIR/$SCRIPT"

  if [ -f "$SRC" ]; then
    cp "$SRC" "$DST"
    chmod +x "$DST"
    print_ok "$SCRIPT instalado"
  else
    print_err "$SCRIPT não encontrado em $SRC"
    exit 1
  fi
done

print_header "ETAPA 4 — Configurando aliases"

cat > "$ALIASES_FILE" << EOF
# ─── ACZG Hero Project — Aliases ───────────────────────────────────────────
export ACZG_SCRIPTS_DIR="$ACZG_SCRIPTS_DIR"

# Task 1 — Inicializar novo projeto
alias aczgnew='bash \$ACZG_SCRIPTS_DIR/aczg_new_project.sh'

# Task 2 — Gerenciar branches
alias aczginit='bash \$ACZG_SCRIPTS_DIR/aczginit.sh'
alias aczgfinish='bash \$ACZG_SCRIPTS_DIR/aczgfinish.sh'

# Task 4 — Visualizar logs do pipeline
alias aczglogs='bash \$ACZG_SCRIPTS_DIR/show_logs.sh'
EOF

print_ok "Arquivo de aliases criado: $ALIASES_FILE"

print_header "ETAPA 5 — Carregando aliases no shell"

if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.bash_profile"
fi

SOURCE_LINE="source $ALIASES_FILE  # ACZG Hero Project"

if grep -q "ACZG Hero Project" "$SHELL_RC"; then
  print_info "Aliases já estão no $SHELL_RC — pulando"
else
  echo "" >> "$SHELL_RC"
  echo "$SOURCE_LINE" >> "$SHELL_RC"
  print_ok "Aliases adicionados ao $SHELL_RC"
fi

print_header "ETAPA 6 — Configurando Cron Jobs"

bash "$ACZG_SCRIPTS_DIR/setup_ci.sh" "0 8 * * 1-5" "$PROJETO_DIR" "$PROJETO_NOME"
print_ok "Cron Job de CI configurada (seg-sex às 8h)"

bash "$ACZG_SCRIPTS_DIR/auto_commit.sh" "0 18 * * 1-5" "$PROJETO_DIR"
print_ok "Cron Job de auto-commit configurada (seg-sex às 18h)"

print_header "✅ Instalação concluída!"

echo ""
echo -e "  ${BOLD}Aliases disponíveis após reabrir o terminal:${NC}"
echo -e "  ${GREEN}aczgnew${NC}    <caminho> <nome>   → inicializa projeto"
echo -e "  ${GREEN}aczginit${NC}   <entrega>          → inicia branch de feature"
echo -e "  ${GREEN}aczgfinish${NC} <entrega>          → finaliza e merge na master"
echo -e "  ${GREEN}aczglogs${NC}   [--ok|--falha]     → exibe logs do pipeline"
echo ""
echo -e "  ${BOLD}Cron Jobs ativas:${NC}"
echo -e "  ${YELLOW}Seg-Sex 08:00${NC} → testes Gradle de '$PROJETO_NOME'"
echo -e "  ${YELLOW}Seg-Sex 18:00${NC} → auto-commit do projeto"
echo ""
echo -e "  ${BOLD}Para aplicar os aliases agora:${NC}"
echo -e "  ${BLUE}source $SHELL_RC${NC}"
echo ""