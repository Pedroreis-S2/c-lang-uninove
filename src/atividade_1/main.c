#include "imports.h"

void espaco () {
    printf("----------------------------------------------------------------\n");
}
void solicita_informacoes(char mensagem[], char formato[], void *variavel) {
    printf("%s", mensagem);
    scanf(formato, variavel);
}

void main() {
    char nome[100];
    printf("Atividade 1 - Nome usuario");
    solicita_informacoes("Digite seu nome: ", "%s", nome);
    imprime_nome(nome);
    espaco();

    printf("atividade 2 - Números");
    float num_1, num_2, num_3;
    solicita_informacoes("Digite um numero inteiro: ", "%f", &num_1);
    solicita_informacoes("Digite outro numero inteiro: ", "%f", &num_2);
    imprime_dois_numeros(num_1, num_2);
    espaco();

    printf("atividade 3 - Média");
    solicita_informacoes("Digite um numero float: ", "%f", &num_1);
    solicita_informacoes("Digite outro numero float: ", "%f", &num_2);
    solicita_informacoes("Digite mais um numero float: ", "%f", &num_3);
    imprime_media_numeros(num_1, num_2, num_3);
    espaco();

    printf("atividade 4 - numeo inteiro");
    solicita_numero_inteiro();
    espaco();

    printf("atividade 5 - dois numeros float");
    solicita_dois_numeros_float();
    espaco();

    printf("atividade 6 - antecessor");
    solicita_informacoes("Digite um número inteiro para descobrir seu antecessor: ", "%i", &num_1);
    imprime_antecessor(num_1);
    espaco();

    printf("atividade 7 - um quarto");
    solicita_informacoes("Digite um número inteiro para descobrir um quarto dele: ", "%i", &num_1);
    imprime_fracao_um_quarto(num_1);
    espaco();

    printf("atividade 8 - valor ao quadrado");
    solicita_informacoes("Digite um número inteiro para descobrir seu valor ao quadrado: ", "%i", &num_1);
    calcula_valor_quadrado(num_1);
    espaco();

    printf("atividade 9 - reajuste poupanca");
    solicita_informacoes("Digite o valor da sua poupança: ", "%f", &num_1);
    reajuste_2_porcento(num_1);
    espaco();

    printf("atividade 10 - area e perimetro retangulo");
    solicita_informacoes("Digite a largura de um retângulo: ", "%f", &num_1);
    solicita_informacoes("Digite a altura de um retângulo: ", "%f", &num_2);
    imprime_area_perimetro_retangulo(num_1, num_2);
    espaco();

    printf("atividade 11 - valor com desconto");
    solicita_informacoes("Digite o valor do produto", "%f", &num_1);
    solicita_informacoes("Digite o percentual de desconto: ", "%d", &num_2);
    imprime_valor_com_desconto(num_1, num_2);
    espaco();

    printf("atividade 12 - reajuste salario");
    solicita_informacoes("Digite o salario de um funcionario: ", "%f", &num_1);
    solicita_informacoes("Digite o percentual de reajuste: ", "%d", &num_2);
    reajusta_valores_salario(num_1, num_2);
    espaco();

    printf("atividade 13 - celsius para fahrenheit");
    solicita_informacoes("Digite a temperatura em graus Celsius para converter em Fahrenheit: ", "%f", &num_1);
    calcula_graus_fahrenheit(num_1);
    espaco();

    printf("atividade 14 - litros gasolina");
    float autonomia, tempo_horas, velocidade_media;

    solicita_informacoes("Digite a autonomia do veículo (km/l): ", "%f", &autonomia);
    solicita_informacoes("Digite o tempo de viagem (horas): ", "%f", &tempo_horas);
    solicita_informacoes("Digite a velocidade média (km/h): ", "%f", &velocidade_media);

    calcula_quantidade_litros_gasolina(autonomia, tempo_horas, velocidade_media);
}