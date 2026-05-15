# ACZG Hero Project 🚀

Automação de tarefas cotidianas do ACZG com Shell Script, Alias e Cron Jobs — instalável em qualquer máquina Linux com um único comando.

---

## Visão Geral

Este projeto implementa um conjunto de ferramentas de automação para o fluxo de trabalho do ACZG, cobrindo desde a inicialização de projetos Git até um mini pipeline de Integração Contínua com testes Gradle automatizados e commits diários.

Toda a solução é distribuída como um repositório que, após clonado, configura o ambiente completo através de um único script instalador (`setup.sh`), tornando-a portável para qualquer máquina Linux.

### O que é automatizado

| Área | O que faz |
|---|---|
| Inicialização de projetos | Cria pasta, README e repositório Git com primeiro commit |
| Gestão de branches | Abre e fecha branches de feature com padrão de nomenclatura |
| CI com Gradle | Executa testes unitários via cron, gera logs e dispara alertas |
| Auto-commit | Realiza commits diários automáticos no projeto em desenvolvimento |
| Observabilidade | Alias dedicado para consulta filtrada dos logs do pipeline |
| Setup | Instalador único que configura aliases, scripts e crons em qualquer máquina |

---

## Estrutura do Repositório

```
aczg-hero/
├── scripts/
│   ├── new_project.sh        # Task 1 — inicializa projeto Git
│   ├── init.sh               # Task 2 — abre branch de feature
│   ├── finish.sh             # Task 2 — fecha branch e merge na master
│   ├── setup_ci.sh           # Task 3 — configura cron de testes Gradle
│   ├── auto_commit.sh        # Task 3 — configura cron de auto-commit
│   └── show_logs.sh          # Task 4 — exibe logs do pipeline
├── setup.sh                  # Task 5 — instalador do ambiente completo
└── README.md
```
---

## Instalação

### Pré-requisitos

- Linux (Ubuntu 20.04+ recomendado)
- `git`, `bash`, `crontab`, `notify-send`
- Gradle instalado e projeto configurado

### Passo a passo

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/aczg-hero.git
cd aczg-hero

# 2. Dê permissão de execução ao instalador
chmod +x setup.sh

# 3. Execute o instalador passando o caminho e nome do seu projeto Gradle
./setup.sh /caminho/para/seu/projeto nome-do-projeto

# 4. Aplique os aliases na sessão atual do terminal
source ~/.bashrc   # ou source ~/.zshrc se usar Zsh
```

Após esses quatro passos, todos os aliases e cron jobs estarão ativos.

### O que o instalador faz

```
./setup.sh
    │
    ├── Verifica dependências (git, bash, crontab, notify-send)
    ├── Cria ~/.aczg/scripts/ e /var/log/aczg/
    ├── Copia e concede permissão de execução a todos os scripts
    ├── Gera ~/.aczg/aliases.sh com todos os aliases
    ├── Injeta source no ~/.bashrc ou ~/.zshrc (sem duplicar)
    └── Configura as duas Cron Jobs automaticamente
```

---

## Tasks

### Task 1 — Inicializar Projetos ACZG

**Script:** `scripts/new_project.sh`  
**Alias:** `aczgnew`

Cria a estrutura inicial de um novo projeto: pasta, `README.md` e repositório Git com o primeiro commit já realizado.

**Uso:**
```bash
aczgnew <caminho> <nome-do-projeto>
```

**Exemplo:**
```bash
aczgnew ~/projetos meu-app
```

**O que acontece:**
```
~/projetos/meu-app/
├── README.md       → "projeto meu-app inicializado...."
└── .git/           → git init + git add + git commit "first commit - repositório configurado"
```

---

### Task 2 — Gerenciar Branches de Features

**Scripts:** `scripts/init.sh` e `scripts/finish.sh`  
**Aliases:** `aczginit` e `aczgfinish`

Padroniza o fluxo de abertura e fechamento de branches de feature com o prefixo `dev-feature-`.

#### `aczginit` — Abrir uma feature

```bash
aczginit <nome-da-entrega>
```

Sequência executada:
1. Exibe `git status` do repositório atual
2. Cria e muda para a branch `dev-feature-<nome-da-entrega>`
3. Lista todas as branches locais e remotas

#### `aczgfinish` — Fechar uma feature

```bash
aczgfinish <nome-da-entrega>
```

Sequência executada:
1. Volta para a branch `master`
2. Realiza merge de `dev-feature-<nome-da-entrega>` na master
3. Remove a branch localmente
4. Remove a branch remotamente (se existir em `origin`)

**Exemplo de fluxo completo:**
```bash
# Abre a feature
aczginit login

# ... desenvolve, commita normalmente ...

# Fecha a feature
aczgfinish login
```

> **Tratamento de erros:** se o merge gerar conflitos, o script interrompe a execução antes de deletar qualquer branch, preservando o estado para resolução manual. Se a branch remota não existir, a remoção remota é ignorada sem erro.

---

### Task 3 — Mini Pipeline de CI

**Scripts:** `scripts/setup_ci.sh` e `scripts/auto_commit.sh`

Implementa dois estágios de pipeline via Cron Job:

#### Estágio 1 — Testes Gradle (`setup_ci.sh`)

Configura uma cron que executa `./gradlew test` no projeto especificado, registra o resultado em log e dispara uma notificação de desktop.

```bash
# Uso
bash scripts/setup_ci.sh [periodicidade_cron] [caminho_projeto] [nome_projeto]

# Exemplo com periodicidade customizada
bash scripts/setup_ci.sh "0 9 * * 1-5" /home/user/projetos/meu-app meu-app

# Usando defaults (todo dia útil às 8h)
bash scripts/setup_ci.sh
```

**Fluxo:**
```
Cron dispara
     │
     ▼
./gradlew test
     │
  ┌──┴──┐
PASSA  FALHA
  │      │
  │    log [ACZG-CI][FALHA] + notify-send ❌ + exit
  │
log [ACZG-CI][OK] + notify-send ✅
"Prosseguindo para o próximo estágio..."
```

#### Estágio 2 — Auto-commit diário (`auto_commit.sh`)

Configura uma cron que realiza `git add -A` e `git commit` automaticamente, apenas se houver alterações no repositório.

```bash
# Uso
bash scripts/auto_commit.sh [periodicidade_cron] [caminho_projeto]

# Exemplo com periodicidade customizada
bash scripts/auto_commit.sh "0 18 * * 1-5" /home/user/projetos/meu-app

# Usando defaults (todo dia útil às 18h)
bash scripts/auto_commit.sh
```

> **Idempotência:** se não houver arquivos modificados, o commit é ignorado com log informativo — nenhum commit vazio é gerado.

---

### Task 4 — Visualizar Logs do Pipeline

**Script:** `scripts/show_logs.sh`  
**Alias:** `aczglogs`

Filtra e exibe no terminal apenas as entradas de log marcadas com `[ACZG-CI]`, com suporte a filtros por status e limite de linhas.

**Uso:**
```bash
aczglogs                    # todos os logs do pipeline
aczglogs --ok               # apenas sucessos [ACZG-CI][OK]
aczglogs --falha            # apenas falhas [ACZG-CI][FALHA]
aczglogs --n 20             # últimas 20 linhas filtradas
aczglogs --falha --n 5      # últimas 5 falhas registradas
```

**Exemplo de saída:**
```
📋 Logs do pipeline ACZG-CI
📄 Arquivo: /var/log/aczg/ci-pipeline.log
🔍 Filtro: [ACZG-CI]
════════════════════════════════════════
[ACZG-CI] ========================================
[ACZG-CI] Início do pipeline: 2024-03-15 08:00:01
[ACZG-CI] Projeto: meu-app
[ACZG-CI][OK] Testes passaram com sucesso em 2024-03-15 08:00:45
[ACZG-CI][OK] Commit realizado: 'auto-commit: 2024-03-15 18:00:02'
════════════════════════════════════════
✅ Sucessos registrados : 2
❌ Falhas registradas   : 0
```

---

### Task 5 — Configuração do Ambiente

**Script:** `setup.sh`

Instalador completo que configura todo o ambiente em qualquer máquina Linux com um único comando. Detecta automaticamente o shell do usuário (`bash` ou `zsh`) e evita duplicação de entradas ao ser executado mais de uma vez.

**Uso:**
```bash
./setup.sh [caminho_projeto] [nome_projeto]
```

**Etapas executadas:**

| Etapa | Descrição |
|---|---|
| 1 | Verifica dependências obrigatórias |
| 2 | Cria `~/.aczg/scripts/` e `/var/log/aczg/` |
| 3 | Copia e concede `chmod +x` a todos os scripts |
| 4 | Gera `~/.aczg/aliases.sh` com todos os aliases |
| 5 | Injeta `source` no `~/.bashrc` ou `~/.zshrc` |
| 6 | Configura as duas Cron Jobs automaticamente |

---

## Referência de Comandos

| Alias | Argumentos | Descrição |
|---|---|---|
| `aczgnew` | `<caminho> <nome>` | Inicializa novo projeto com Git |
| `aczginit` | `<nome-entrega>` | Cria branch `feat-<nome-entrega>` |
| `aczgfinish` | `<nome-entrega>` | Merge e remove branch da feature |
| `aczglogs` | `[--ok\|--falha] [--n N]` | Exibe logs do pipeline CI |

---

## Configuração das Cron Jobs

As cron jobs são configuradas com valores padrão pelo instalador, mas podem ser ajustadas com argumentos:

| Cron Job | Default | Configurável via |
|---|---|---|
| Testes Gradle | Seg–Sex às 08:00 | `bash setup_ci.sh "<cron>"` |
| Auto-commit | Seg–Sex às 18:00 | `bash auto_commit.sh "<cron>"` |

**Sintaxe de cron:**
```
┌─ minuto (0-59)
│ ┌─ hora (0-23)
│ │ ┌─ dia do mês (1-31)
│ │ │ ┌─ mês (1-12)
│ │ │ │ ┌─ dia da semana (0-7, 0 e 7 = domingo)
│ │ │ │ │
* * * * *

Exemplos:
"0 8 * * 1-5"    → seg a sex às 08:00 (padrão CI)
"0 18 * * 1-5"   → seg a sex às 18:00 (padrão auto-commit)
"0 */2 * * *"    → a cada 2 horas
"30 9 * * *"     → todo dia às 09:30
```

Para verificar as crons ativas:
```bash
crontab -l
```

---

## Logs do Pipeline

Todos os logs são armazenados em `/var/log/aczg/ci-pipeline.log`.

### Marcadores utilizados

| Marcador | Significado |
|---|---|
| `[ACZG-CI]` | Entrada geral do pipeline |
| `[ACZG-CI][OK]` | Execução bem-sucedida |
| `[ACZG-CI][FALHA]` | Execução com falha |
| `[ACZG-CI][ERRO]` | Erro de configuração (ex: diretório não encontrado) |
| `[ACZG-CI][INFO]` | Informação (ex: nenhuma alteração para commitar) |

### Exemplo de log completo

```
[ACZG-CI] ========================================
[ACZG-CI] Início do pipeline: 2024-03-15 08:00:01
[ACZG-CI] Projeto: meu-app
[ACZG-CI] ========================================
[ACZG-CI] Executando testes com Gradle...

> Task :test

BUILD SUCCESSFUL in 43s

[ACZG-CI][OK] Testes passaram com sucesso em 2024-03-15 08:00:45
[ACZG-CI] Prosseguindo para o próximo estágio do pipeline...

[ACZG-CI] ----------------------------------------
[ACZG-CI] Auto-commit iniciado: 2024-03-15 18:00:01
[ACZG-CI][OK] Commit realizado com sucesso: 'auto-commit: 2024-03-15 18:00:02'
```

---

## Requisitos

### Sistema operacional
- Linux (Ubuntu 20.04+ recomendado)
- macOS com adaptações (notify-send indisponível nativamente)

### Dependências

| Ferramenta | Uso |
|---|---|
| `bash` | Execução de todos os scripts |
| `git` | Controle de versão |
| `crontab` | Agendamento das Cron Jobs |
| `notify-send` | Alertas de desktop (pacote `libnotify-bin`) |
| `gradle` | Execução dos testes unitários (Task 3) |

**Instalação das dependências no Ubuntu:**
```bash
sudo apt update
sudo apt install git libnotify-bin
# gradle: siga a documentação oficial em https://gradle.org/install/
```

## Autor

Desenvolvido como parte do **ZG-Hero Project** do ACZG.
