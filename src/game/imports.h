#ifndef METODOS_H
#define METODOS_H

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>

typedef struct {
    char chave[50];
    int valor;
    char emoji[5];
} rolo;

typedef struct {
    rolo itens[9];
    int index;
} listaRolo;

float inicia_jogo(float saldo, float aposta);
void animar_roleta_embaralhando(listaRolo *lista_original, int duracao_ms);
void limpar_tela();
void exibir_roleta_temporaria(char simbolos[9]);
void exibir_roleta_temporaria_emoji(char emoji_temp[9][5]);
void exibeRoleta(listaRolo *lista);
void Sleep(int milliseconds);
int getch();

#endif