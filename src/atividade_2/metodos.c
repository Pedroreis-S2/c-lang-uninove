#include <stdio.h>

void printa_valor_maior_que_dez() {
    int numero;
    printf("Digite um número inteiro: ");
    scanf("%d", &numero);
    if (numero > 10) {
        printf("O número %d é maior que 10.\n", numero);
    } else {
        printf("O número %d não é maior que 10.\n", numero);
    }
}

void adiciona_oito() {
    int num1, num2;
    printf("Digite o primeiro número inteiro: ");
    scanf("%d", &num1);
    printf("\nDigite o segundo número inteiro: ");
    scanf("%d", &num2);

    resultado = num1 + num2;
    if (resultado > 20) {
        printf("O resultado é %d, que é maior que 20.\n", resultado);
        resultado += 8;
    }
    else {
        printf("O resultado é %d, que não é maior que 20.\n", resultado);
    }
}

void multiplo_tres() {
    int numero;
    printf("Digite um número inteiro: ");
    scanf("%d", &numero);

    if (numero % 3 == 0) {
        printf("O número %d é múltiplo de 3.\n", numero);
    } else {
        printf("O número %d não é múltiplo de 3.\n", numero);
    }
}

void divisivel_cinco() {
    int numero;
    printf("Digite um número inteiro: ");
    scanf("%d", &numero);

    if (numero % 5 == 0) {
        printf("O número %d é divisível por 5.\n", numero);
    } else {
        printf("O número %d não é divisível por 5.\n", numero);
    }
}

void divisivel_tres_sete() {
    int numero;
    printf("Digite um numero inteiro: ");
    scanf("%d", &numero);

    bool divisivel = (numero % 3 == 0) && (numero % 7 == 0);
    if (divisivel) {
        printf()
    }
}

void emprestimo_trinta_porc() {
    int salario = scanf("%d");
}