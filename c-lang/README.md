# 📚 Algoritmos e Programação Linear - C

Este repositório contém os projetos e atividades da matéria **Algoritmos e Programação Linear** desenvolvidos em linguagem C durante o semestre atual.

## 🏗️ Estrutura do Projeto

```
src/
├── atividade_1/          # Primeira atividade da disciplina
│   ├── main.c
│   ├── metodos.c
│   └── imports.h
├── game/                 # Projeto do jogo Slot Machine
│   ├── main.c
│   ├── metodos.c
│   └── imports.h
└── run.sh               # Script de compilação e execução
```

## 🐳 Ambiente de Desenvolvimento

O projeto é desenvolvido utilizando **Docker** através do **GitHub Codespaces** para garantir consistência do ambiente entre diferentes máquinas.

### Pré-requisitos
- GitHub Codespaces (recomendado)
- Docker (caso rode localmente)

### Configuração
O ambiente já está configurado com todas as dependências necessárias:
- GCC (compilador C)
- Make
- Bibliotecas de desenvolvimento (libc6-dev, ncurses-dev)
- Ferramentas de debug (GDB)

## 🚀 Como Executar

### Container Docker
O container é iniciado automaticamente no Codespaces. Caso precise reiniciar:
```bash
docker compose -f .devcontainer/docker-compose.yml up -d
```

### Executando as Atividades
Para compilar e executar qualquer atividade, use o script `run.sh`:
```bash
cd src
./run.sh <nome_da_pasta>
```

**Exemplo:**
```bash
./run.sh atividade_1
./run.sh game
```

### Executando o Jogo (Slot Machine)
O projeto do jogo possui um Makefile para facilitar a execução:

```bash
# Compilar e executar
make play

# Apenas compilar
make all

# Executar sem compilar
make run

# Limpar arquivos compilados
make clean

# Ver ajuda
make help
```

## 🎰 Sobre o Jogo

O projeto **Slot Machine** é um caça-níqueis desenvolvido em C que inclui:

### Funcionalidades
- 🎲 Sistema de apostas com saldo
- 🎰 Animação de roleta com emojis
- 💫 Efeitos visuais durante o embaralhamento
- 💰 Controle de saldo e apostas
- 🎮 Interface interativa com `getch()`

### Características Técnicas
- Uso de estruturas (`struct`) para organização dos dados
- Manipulação de arrays e ponteiros
- Funções de terminal para animações
- Sistema de números aleatórios
- Compatibilidade Linux/Docker

## 📋 Atividades da Disciplina

- **Atividade 1**: [Descrição da primeira atividade]
- **Projeto Final**: Slot Machine - Jogo de caça-níqueis completo

## 🛠️ Tecnologias Utilizadas

- **Linguagem**: C (padrão C99)
- **Compilador**: GCC
- **Build System**: Make
- **Containerização**: Docker
- **IDE**: VS Code + Codespaces
- **Sistema**: Linux (Debian Bullseye)

## 👨‍🎓 Informações Acadêmicas

- **Disciplina**: Algoritmos e Programação Linear
- **Semestre**: 2025/2
- **Instituição**: Uninove

---

*Desenvolvido como parte dos requisitos da disciplina de Algoritmos e Programação Linear.*
