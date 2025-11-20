#include <stdio.h>
#include <stdlib.h>

typedef struct {
    char chave[50];
    int valor;
    char emoji;
} rolo;

typedef struct {
    rolo itens[9];
    int index;
} listaRolo;

rolo* obter_item(listaRolo *lista, int indice) {
    if (indice < 0 || indice >= lista->index) {
        return NULL;
    }
    return &lista->itens[indice];
}

int valor_randomico() {
    int minimo = 0;
    int maximo = 8; // índices válidos: 0..8
    return minimo + rand() % (maximo - minimo + 1);
}

listaRolo girar_roleta(listaRolo *lista) {
    listaRolo nova_lista;
    nova_lista.index = 0;
    for (int i = 0; i < lista->index; i++) {
        int idx = valor_randomico();
        printf("Valor randomico: %d\n", idx);
        rolo temp = *obter_item(lista, idx);

        nova_lista.itens[nova_lista.index++] = temp;
    }

    return nova_lista;
}

listaRolo embaralhar_lista(listaRolo *lista) {
    listaRolo nova_lista = *lista;
    for (int i = nova_lista.index - 1; i > 0; i--) {
        int j = valor_randomico() % (i + 1);

        rolo temp = nova_lista.itens[i];
        nova_lista.itens[i] = nova_lista.itens[j];
        nova_lista.itens[j] = temp;
    }
    return nova_lista;
}

char* exibeRoleta(listaRolo *lista) {
    printf("Embaralhando roleta...\n");

    printf("Roleta:\n");

    printf("-------------------------\n");
    printf("%c| %c | %c", 
        obter_item(lista, 0)->emoji,
        obter_item(lista, 1)->emoji,
        obter_item(lista, 2)->emoji
    );
    printf("\n");
    printf("%c| %c | %c", 
        obter_item(lista, 3)->emoji,
        obter_item(lista, 4)->emoji,
        obter_item(lista, 5)->emoji
    );
    printf("\n");
    printf("%c| %c | %c", 
        obter_item(lista, 6)->emoji,
        obter_item(lista, 7)->emoji,
        obter_item(lista, 8)->emoji
    );
    printf("\n");
    return "Roleta exibida com sucesso.";
    
}

void inicia_jogo(float saldo) {
    printf("Jogo iniciado com saldo: %.2f\n", saldo);

    rolo item1 = {"Cereja", valor_randomico(), };
    rolo item2 = {"Laranja", valor_randomico(), '!'};
    rolo item3 = {"Uva", valor_randomico(), '#'};
    rolo item4 = {"Melancia", valor_randomico(), '$'};
    rolo item5 = {"Bar", valor_randomico(), '%'};
    rolo item6 = {"Sino", valor_randomico(), '^'};
    rolo item7 = {"Banana", valor_randomico(), '&'};
    rolo item8 = {"Diamante", valor_randomico(), '*'};
    rolo item9 = {"Picole", valor_randomico(), '+'};

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

    listaRolo lista_embaralhada = girar_roleta(&lista);
    exibeRoleta(&lista_embaralhada);
}

