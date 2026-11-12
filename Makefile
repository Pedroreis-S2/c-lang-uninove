# Estudae e UninoVet usam a porta 5000, entao roda-se UM projeto por vez.
# No Codespace: rode o alvo e abra as portas na aba PORTS.
#
#   make estudae   -> Estudae (app Flutter em :5000)
#   make uninovet  -> UninoVet completo: 3 aplicacoes + banco
#                       :3000 porta unica (app do cliente em /, clinica em /clinica/)
#                       :5000 app do cliente (Flutter)
#                       :8080 aplicacao da clinica (Java: painel, agenda, /admin e API)
#   make logs      -> acompanha os logs do UninoVet
#   make down      -> desliga tudo

# Enderecos. No Codespace cada porta vira uma URL propria; no computador local e localhost.
# O app do cliente chama a API pela porta unica (3000): mesma origem, sem CORS.
ifdef CODESPACE_NAME
PROXY_URL := https://$(CODESPACE_NAME)-3000.$(GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN)
JAVA_URL  := https://$(CODESPACE_NAME)-8080.$(GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN)
APP_URL   := https://$(CODESPACE_NAME)-5000.$(GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN)
else
PROXY_URL := http://localhost:3000
JAVA_URL  := http://localhost:8080
APP_URL   := http://localhost:5000
endif

.PHONY: help estudae uninovet logs down

help:
	@echo "make estudae   -> sobe o Estudae (porta 5000)"
	@echo "make uninovet  -> sobe o UninoVet (3000 unica, 5000 app, 8080 clinica)"
	@echo "make logs      -> logs do UninoVet"
	@echo "make down      -> desliga tudo"

estudae: down
	cd estudae && docker compose up dev
	@echo ">> Estudae subindo. Abra a porta 5000 (aguarde o Flutter compilar)."

# Ordem: banco e Java primeiro (o Java cria os usuarios de exemplo), depois o
# Flutter com o endereco da porta unica, por fim o proxy.
uninovet: down
	cd uninoVet && APP_URL=$(PROXY_URL) docker compose up -d --build db web
	@echo ">> Aguardando a clinica (Java) responder ..."
	@until curl -s -o /dev/null http://localhost:8080/login; do sleep 2; done
	cd uninoVet && API_BASE=$(PROXY_URL) docker compose --profile proxy up -d mobile proxy
	@echo ""
	@echo ">> Porta unica (abra esta):  $(PROXY_URL)"
	@echo ">> Clinica (Java):           $(PROXY_URL)/clinica/   ou   $(JAVA_URL)"
	@echo ">> App do cliente (Flutter): $(APP_URL)  (aguarde o Flutter compilar)"
	@echo ">> Contas de exemplo: veja uninoVet/README.md"

logs:
	cd uninoVet && docker compose --profile proxy logs -f

down:
	-cd estudae && docker compose down
	-cd uninoVet && docker compose --profile proxy down
