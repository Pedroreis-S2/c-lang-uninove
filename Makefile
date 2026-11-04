# UninoVet e Estudae usam as mesmas portas, entao roda-se UM por vez.
# No Codespace: rode o alvo e abra a porta na aba PORTS.
#
#   make estudae   -> Estudae (app Flutter em :5000)
#   make uninovet  -> UninoVet (tudo em :3000 ; painel em /admin ; API em /api)
#   make down      -> desliga os dois

.PHONY: help estudae uninovet down

help:
	@echo "make estudae   -> sobe o Estudae (porta 5000)"
	@echo "make uninovet  -> sobe o UninoVet (porta 3000: / app, /admin painel, /api)"
	@echo "make down      -> desliga os dois"

estudae: down
	cd estudae && docker compose up dev
	@echo ">> Estudae subindo. Abra a porta 5000 (aguarde o Flutter compilar)."

uninovet: down
	cd uninoVet && docker compose up -d
	@echo ">> UninoVet subindo. Abra a porta 3000: / app, /admin painel, /api (aguarde o Flutter compilar)."

down:
	-cd estudae && docker compose down
	-cd uninoVet && docker compose down
