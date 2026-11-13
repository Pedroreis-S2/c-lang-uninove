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

# Tudo roda atras do proxy na porta unica 3000 (mesma origem). O app e o painel
# usam caminhos relativos, entao funcionam igual no Windows e no Codespace sem o
# Makefile precisar montar URLs. Por isso os alvos sao so "docker compose up".

.PHONY: help estudae uninovet logs down

help:
	@echo make estudae  : sobe o Estudae na porta 5000
	@echo make uninovet : sobe o UninoVet nas portas 3000, 5000 e 8080
	@echo make logs     : logs do UninoVet
	@echo make down     : desliga tudo

estudae: down
	cd estudae && docker compose up dev
	@echo Estudae subindo. Abra a porta 5000 e aguarde o Flutter compilar.

# O compose cuida da ordem e da espera: banco -> clinica (Java, aguarda ficar
# saudavel pelo healthcheck) -> app Flutter + proxy. Sem script de espera aqui.
uninovet: down
	cd uninoVet && docker compose --profile proxy up -d
	@echo UninoVet subindo. Abra a porta 3000 no navegador.
	@echo No Codespace, libere a porta 3000 na aba PORTS.
	@echo App do cliente em / e painel da clinica em /clinica/.
	@echo O app Flutter leva um tempo para compilar na primeira vez.
	@echo Contas de exemplo: veja uninoVet/README.md

logs:
	cd uninoVet && docker compose --profile proxy logs -f

down:
	-cd estudae && docker compose down
	-cd uninoVet && docker compose --profile proxy down
