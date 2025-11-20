# Dependências do Projeto C - Game Slot Machine

## Dependências do Sistema (já incluídas no Dockerfile)

### Compilação e Build
- `gcc` - Compilador GNU C
- `build-essential` - Ferramentas essenciais de build
- `make` - Ferramenta de automação de build
- `gdb` - Debugger GNU

### Bibliotecas C Utilizadas
- `libc6-dev` - Biblioteca C padrão (desenvolvimento)
- `unistd.h` - Interface POSIX para chamadas do sistema
- `termios.h` - Interface de controle de terminal
- `stdio.h` - Entrada e saída padrão
- `stdlib.h` - Funções de biblioteca padrão
- `time.h` - Funções de tempo

### Funcionalidades Implementadas
- **Animação da Roleta**: Usa `usleep()` para delays em milissegundos
- **Limpeza de Tela**: Comando `clear` do sistema
- **Entrada de Teclado**: Implementação customizada do `getch()` usando `termios`
- **Números Aleatórios**: Função `rand()` com seed `srand(time(NULL))`

### Como Compilar
```bash
gcc -o main main.c metodos.c
```

### Como Executar
```bash
./main
```

## Compatibilidade
- ✅ Linux (Debian/Ubuntu)
- ✅ Docker
- ⚠️ Windows (requer adaptações específicas)
- ✅ macOS (com ajustes mínimos)