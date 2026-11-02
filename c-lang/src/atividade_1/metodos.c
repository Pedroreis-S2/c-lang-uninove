#include <stdio.h>

void imprime_nome(char nome[]) {
    printf("Nome: %s\n", nome);
}

void imprime_dois_numeros(int num1, int num2) {
    printf("Números: %d e %d\n", num1, num2);
}

void imprime_media_numeros(float num1, float num2, float num3) {
    float media = (num1 + num2 + num3) / 3;
    printf("Média: %.2f\n", media);
}

void solicita_numero_inteiro() {
    int numero;
    printf("Digite um número inteiro: ");
    scanf("%d", &numero);
    printf("Número digitado: %d\n", numero);
}

void solicita_dois_numeros_float() {
    double num1, num2;
    printf("Digite dois números float (separados por espaço): ");
    scanf("%lf %lf", &num1, &num2);
    printf("Números digitados: %.2lf e %.2lf\n", num1, num2);
}

void imprime_antecessor(int numero) {
    printf("Antecessor de %d é %d\n", numero, (numero - 1));
}

void imprime_fracao_um_quarto(int numero) {
    double fracao = numero / 4.0;
    printf("Um quarto de %d é %.2lf\n", numero, fracao);
}

void calcula_valor_quadrado(int numero) {
    int quadrado = numero * numero;
    printf("Quadrado de %d é %d\n", numero, quadrado);
}

void reajuste_2_porcento(float poupanca) {
    float reajustado = poupanca * 1.02;
    printf("Valor após reajuste de 2%%: %.2f\n", reajustado);
}

void imprime_area_perimetro_retangulo(float largura, float altura) {
    float area = largura * altura;
    float perimetro = 2 * (largura + altura);
    printf("Área: %.2f, Perímetro: %.2f\n", area, perimetro);
}

void imprime_valor_com_desconto(float valor, int percentual_desconto) {
    float desconto = (valor * percentual_desconto) / 100.0;
    float valor_final = valor - desconto;
    printf("Valor com %d%% de desconto: %.2f\n", percentual_desconto, valor_final);
}

void reajusta_valores_salario(float salario, int percentual_reajuste) {
    float reajuste = (salario * percentual_reajuste) / 100.0;
    float novo_salario = salario + reajuste;
    printf("Novo salário após %d%% de reajuste: %.2f\n", percentual_reajuste, novo_salario);
}

void calcula_graus_fahrenheit(float celsius) {
    float fahrenheit = ((9 * celsius) + 160) / 5;
    printf("%.2f graus Celsius é %.2f graus Fahrenheit\n", celsius, fahrenheit);
}

void calcula_quantidade_litros_gasolina(float autonomia, float tempo_horas, float velocidade_media) {
    float distancia = velocidade_media * tempo_horas;
    float litros_necessarios = (distancia / autonomia);
    printf("Litros de gasolina necessários para %.2f km: %.2f litros\n", distancia, litros_necessarios);
}