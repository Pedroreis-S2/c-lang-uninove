#!/bin/bash
# chmod +x run.sh

if [ -z "$1" ]; then
    echo "Necessário informar o nome da pasta."
    exit 1
fi

PASTA="$1"

if [ ! -d "$PASTA" ]; then
    echo "Pasta '$PASTA' não encontrada."
    exit 1
fi

ARQUIVO_EXEC="$PASTA/main"

gcc "$PASTA"/*.c -o "$ARQUIVO_EXEC"
if [ $? -eq 0 ]; then
    clear
    echo "Compilação concluída. Executando $ARQUIVO_EXEC..."
    echo "-----------------------------------------"
    ./"$ARQUIVO_EXEC"
else
    echo "Erro na compilação."
fi