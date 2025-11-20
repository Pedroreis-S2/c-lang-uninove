#include "imports.h"


void main() {
    float saldo = 100.0;
    printf("🎰 Bem-vindo à Slot Machine! Seu saldo inicial é: $%.2f 🎰\n", saldo);
    do {
        printf("🎲 Deseja jogar uma rodada? (s/n): ");
        char resposta;
        scanf(" %c", &resposta);  // Espaço antes do %c para ignorar whitespace
        
        bool nao = resposta == 'n' || resposta == 'N';
        bool sim = resposta == 's' || resposta == 'S';
        
        if (nao) {
            printf("Obrigado por jogar! Seu saldo final é: $%.2f\n", saldo);
            break;
        }
        else if (!sim) {  // Mudei de sim == false para !sim
            printf("Resposta inválida. Por favor, digite 's' para sim ou 'n' para não.\n");
            continue;
        }
        float aposta;
        do {
            printf("💰 Digite o valor da sua aposta (saldo atual: $%.2f): ", saldo);
            scanf("%f", &aposta);
            if (aposta > saldo) {
                printf("❌ Saldo insuficiente para essa aposta. Tente novamente.\n");
            }
            else if (aposta <= 0) {
                printf("❌ Aposta deve ser maior que zero. Tente novamente.\n");
            }
        } while (aposta > saldo || aposta <= 0);

        srand(time(NULL));
        saldo = inicia_jogo(saldo, aposta);
    } while (
        saldo > 0
    );
    

}