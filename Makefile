# Estudae e UninoVet usam a porta 5000, entao roda-se UM projeto por vez.
# No Codespace: rode o alvo e abra as portas na aba PORTS.
#
#   make estudae   -> Estudae (app Flutter em :5000)
#   make uninovet  -> UninoVet: painel Java em :8080 e app Flutter em :5000
#   make down      -> desliga tudo

# Enderecos das duas aplicacoes. No Codespace cada porta vira uma URL propria;
# no computador local e localhost.
ifdef CODESPACE_NAME
JAVA_URL := https://$(CODESPACE_NAME)-8080.$(GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN)
APP_URL  := https://$(CODESPACE_NAME)-5000.$(GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN)
else
JAVA_URL := http://localhost:8080
APP_URL  := http://localhost:5000
endif

.PHONY: help estudae uninovet down

help:
	@echo "make estudae   -> sobe o Estudae (porta 5000)"
	@echo "make uninovet  -> sobe o UninoVet (Java na 8080, app na 5000)"
	@echo "make down      -> desliga tudo"

estudae: down
	cd estudae && docker compose up dev
	@echo ">> Estudae subindo. Abra a porta 5000 (aguarde o Flutter compilar)."

# Sobe o Java primeiro; depois passa a URL dele como argumento para o Flutter.
uninovet: down
	cd uninoVet && APP_URL=$(APP_URL) docker compose up -d --build db web
	@echo ">> Aguardando o painel Java responder em $(JAVA_URL) ..."
	@until curl -s -o /dev/null http://localhost:8080/; do sleep 2; done
	cd uninoVet && API_BASE=$(JAVA_URL) docker compose up -d mobile
	@echo ">> Painel Java (admin): $(JAVA_URL)"
	@echo ">> Aplicativo Flutter:  $(APP_URL)  (aguarde o Flutter compilar)"

down:
	-cd estudae && docker compose down
	-cd uninoVet && docker compose down
