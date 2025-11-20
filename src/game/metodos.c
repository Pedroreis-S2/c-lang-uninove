#include "imports.h"

void Sleep(int milliseconds) {
    usleep(milliseconds * 1000);
}

int getch() {
    struct termios old_termios, new_termios;
    int ch;
    
    tcgetattr(0, &old_termios);
    new_termios = old_termios;
    new_termios.c_lflag &= ~ICANON;
    new_termios.c_lflag &= ~ECHO;
    tcsetattr(0, TCSANOW, &new_termios);
    
    ch = getchar();
    
    tcsetattr(0, TCSANOW, &old_termios);
    return ch;
}

rolo* obter_item(listaRolo *lista, int indice) {
    if (indice < 0 || indice >= lista->index) {
        return NULL;
    }
    return &lista->itens[indice];
}

int valor_randomico(int maximo) {
    int minimo = 0;
    return minimo + rand() % (maximo - minimo + 1);
}

void limpar_tela() {
    system("clear");
}

void exibir_roleta_temporaria(char simbolos[9]) {
    printf("\n========================\n");
    printf("    SLOT MACHINE\n");
    printf("========================\n");
    printf("| %c | %c | %c |\n", simbolos[0], simbolos[1], simbolos[2]);
    printf("|---|---|---|\n");
    printf("| %c | %c | %c |\n", simbolos[3], simbolos[4], simbolos[5]);
    printf("|---|---|---|\n");
    printf("| %c | %c | %c |\n", simbolos[6], simbolos[7], simbolos[8]);
    printf("========================\n");
}

void exibir_roleta_temporaria_emoji(char emoji_temp[9][5]) {
    printf("\n========================\n");
    printf("    SLOT MACHINE\n");
    printf("========================\n");
    printf("| %s | %s | %s |\n", emoji_temp[0], emoji_temp[1], emoji_temp[2]);
    printf("|---|---|---|\n");
    printf("| %s | %s | %s |\n", emoji_temp[3], emoji_temp[4], emoji_temp[5]);
    printf("|---|---|---|\n");
    printf("| %s | %s | %s |\n", emoji_temp[6], emoji_temp[7], emoji_temp[8]);
    printf("========================\n");
}

listaRolo girar_roleta(listaRolo *lista, int indices) {
    listaRolo nova_lista;
    nova_lista.index = 0;
    for (int i = 0; i < lista->index; i++) {

        int idx = valor_randomico(indices - 1);
        rolo temp = *obter_item(lista, idx);

        nova_lista.itens[nova_lista.index++] = temp;
    }

    return nova_lista;
}


void animar_roleta_embaralhando(listaRolo *lista_original, int duracao_ms) {
    char simbolos_animacao[9];
    char simbolos_girando[] = {'|', '/', '-', '\\', '|', '/', '-', '\\', '|'};
    int frames = duracao_ms / 150; // Aproximadamente 150ms por frame
    
    printf("🎰 Preparando para girar a roleta...\n");
    Sleep(1000);
    
    // Animação de embaralhamento
    for (int frame = 0; frame < frames; frame++) {
        limpar_tela();
        
        for (int i = 0; i < 9; i++) {
            if (frame < frames - 3) {
                // Fase de embaralhamento
                simbolos_animacao[i] = simbolos_girando[(frame + i) % 8];
            } else {
                // Últimos frames - vai revelando o resultado
                int chance_revelar = ((frame - (frames - 3)) * 100) / 3;
                if ((rand() % 100) < chance_revelar) {
                    simbolos_animacao[i] = obter_item(lista_original, i)->emoji;
                } else {
                    simbolos_animacao[i] = simbolos_girando[(frame + i) % 8];
                }
            }
        }
        
        printf("🎰 GIRANDO A ROLETA... 🎰\n");
        exibir_roleta_temporaria(simbolos_animacao);
        
        if (frame < frames - 3) {
            printf("\n💫 Embaralhando...\n");
        } else {
            printf("\n🎯 Parando...\n");
        }
        
        Sleep(150);
    }
    
    limpar_tela();
    printf("🎰 RESULTADO FINAL! 🎰\n");
    exibeRoleta(lista_original);
}

void exibeRoleta(listaRolo *lista) {
    printf("\n========================\n");
    printf("      RESULTADO\n");
    printf("========================\n");
    printf("| %s | %s | %s |\n", 
        obter_item(lista, 0)->emoji,
        obter_item(lista, 1)->emoji,
        obter_item(lista, 2)->emoji
    );
    printf("|----|----|----|\n");
    printf("| %s | %s | %s |\n", 
        obter_item(lista, 3)->emoji,
        obter_item(lista, 4)->emoji,
        obter_item(lista, 5)->emoji
    );
    printf("|----|----|----|\n");
    printf("| %s | %s | %s |\n", 
        obter_item(lista, 6)->emoji,
        obter_item(lista, 7)->emoji,
        obter_item(lista, 8)->emoji
    );
    printf("========================\n");
}

float calcula_pagamento(listaRolo *lista, float aposta) {
    // Irei deixar esse comentario para facilitar o entendimento da roleta
    
        // A roleta funciona assim
        //    a  b  c
        // 1  x  x  x
        // 2  x  x  x
        // 3  x  x  x

        // Linhas vencedoras:
        // Horizontal: 1, 2, 3
        // Vertical: a, b, c
        // Diagonal: 1a, 2b, 3c e 1c, 2b, 3a

        // pontos para cada combinação:
        // horizontal: valor + 10% do valor apostado
        // vertical: valor + 7% do valor apostado
        // diagonal: valor + 15% do valor apostado
        // todos iguais: 10x o valor da aposta

    float retorno = 0.0;
    rolo a1 = *obter_item(lista, 0);
    rolo a2 = *obter_item(lista, 3);
    rolo a3 = *obter_item(lista, 6);
    rolo b1 = *obter_item(lista, 1);
    rolo b2 = *obter_item(lista, 4);
    rolo b3 = *obter_item(lista, 7);
    rolo c1 = *obter_item(lista, 2);
    rolo c2 = *obter_item(lista, 5);
    rolo c3 = *obter_item(lista, 8);

    if (a1.valor == a2.valor && a2.valor == a3.valor) {
        printf("Linha A Vertical! Você ganhou %.2f R$ \n", aposta * 0.1);
        retorno += (aposta * 0.1);
    }
    if (b1.valor == b2.valor && b2.valor == b3.valor) {
        printf("Linha B Vertical! Você ganhou %.2f R$ \n", aposta * 0.1);
        retorno += (aposta * 0.1);
    }
    if (c1.valor == c2.valor && c2.valor == c3.valor) {
        printf("Linha C Vertical! Você ganhou %.2f R$ \n", aposta * 0.1);
        retorno += (aposta * 0.1);
    }

    if (a1.valor == b1.valor && b1.valor == c1.valor) {
        printf("Linha 1 Horizontal! Você ganhou %.2f R$ \n", aposta * 0.07);
        retorno += (aposta * 0.07);
    }
    if (a2.valor == b2.valor && b2.valor == c2.valor) {
        printf("Linha 2 Horizontal! Você ganhou %.2f R$ \n", aposta * 0.07);
        retorno += (aposta * 0.07);
    }
    if (a3.valor == b3.valor && b3.valor == c3.valor) {
        printf("Linha 3 Horizontal! Você ganhou %.2f R$ \n", aposta * 0.07);
        retorno += (aposta * 0.07);
    }
    if (a1.valor == b2.valor && b2.valor == c3.valor) {
        printf("Diagonal 1! Você ganhou %.2f R$ \n", aposta * 0.15);
        retorno += (aposta * 0.15);
    }
    if (a3.valor == b2.valor && b2.valor == c1.valor) {
        printf("Diagonal 2! Você ganhou %.2f R$ \n", aposta * 0.15);
        retorno += (aposta * 0.15);
    }
    if (a1.valor == a2.valor && a2.valor == a3.valor &&
        a1.valor == b1.valor && b1.valor == b2.valor &&
        a1.valor == b3.valor && b3.valor == c1.valor &&
        a1.valor == c2.valor && c2.valor == c3.valor) {
        printf("🎉 JACKPOT! TODOS OS ITENS SÃO IGUAIS!");

        retorno += aposta * 10;
    }
    if (retorno > 0) {
        printf("\n\nTotal ganho nesta rodada: %.2f R$ \n", retorno);
        retorno += aposta;
    }
    else {
        printf("😞 Nenhuma combinação vencedora desta vez. Aposta perdida( %.2f R$)\n", aposta);
    }
    

    return retorno;
}

int define_quantidade_itens_roleta(float saldo, float aposta) {
    int quantidade_itens = 3; // Valor padrão
    int valor_maximo_itens = 9;

    if (aposta >= saldo * 0.5) {
        quantidade_itens = valor_maximo_itens;
    } else if (aposta >= saldo * 0.4) {
        quantidade_itens = 7;
    } else if (aposta >= saldo * 0.2) {
        quantidade_itens = 5;
    } else {
        quantidade_itens = 3;
    }

    return quantidade_itens;
    
}

float inicia_jogo(float saldo, float aposta) {
    
    rolo item1 = {"Cereja", 1, "🍒"};
    rolo item2 = {"Laranja", 2, "🍊"};
    rolo item3 = {"Uva", 3, "🍇"};
    rolo item4 = {"Melancia", 4, "🍉"};
    rolo item5 = {"Bar", 5, "🍺"};
    rolo item6 = {"Sino", 6, "🔔"};
    rolo item7 = {"Banana", 7, "🍌"};
    rolo item8 = {"Diamante", 8, "💎"};
    rolo item9 = {"Picole", 9, "🍧"};

    listaRolo lista;
    lista.index = 0;
    lista.itens[lista.index++] = item1;
    lista.itens[lista.index++] = item2;
    lista.itens[lista.index++] = item3;
    lista.itens[lista.index++] = item4;
    lista.itens[lista.index++] = item5;
    lista.itens[lista.index++] = item6;
    lista.itens[lista.index++] = item7;
    lista.itens[lista.index++] = item8;
    lista.itens[lista.index++] = item9;
    
    int indices = define_quantidade_itens_roleta(saldo, aposta);
    listaRolo lista_embaralhada = girar_roleta(&lista, indices);
    
    animar_roleta_embaralhando(&lista_embaralhada, 2000);
    float pagamento = calcula_pagamento(&lista_embaralhada, aposta);
    
    
    float saldo_atualizado = saldo - aposta + pagamento;
    printf("Jogo iniciado com saldo: %.2f\n", saldo);
    printf("Seu saldo atualizado é: %.2f\n", saldo_atualizado);
    printf("\n\n");

    return saldo_atualizado;
}

