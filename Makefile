# Estudae - atalhos para rodar com Docker (Windows, macOS, Linux e Codespace).
# Cada alvo e so um "docker compose": o container resolve o resto.
#
#   make up    -> app Flutter (dev) na porta 5000, recarrega sozinho ao salvar
#   make logs  -> acompanha a compilacao
#   make test  -> testes do Flutter dentro do container
#   make prod  -> build de producao (nginx) na porta 8080
#   make down  -> desliga tudo
#
# No Codespace: rode o alvo e abra a porta na aba PORTS.

.PHONY: help up estudae logs test prod rebuild down

help:
	@echo make up      : sobe o Estudae na porta 5000
	@echo make logs    : logs da compilacao
	@echo make test    : testes do Flutter
	@echo make prod    : build de producao na porta 8080
	@echo make rebuild : recria o container de dev
	@echo make down    : desliga tudo

up:
	docker compose up -d dev
	@echo Estudae subindo. Abra a porta 5000 e aguarde o Flutter compilar.
	@echo Acompanhe com: make logs

# Mesmo alvo com o nome antigo.
estudae: up

logs:
	docker compose logs -f dev

test:
	docker compose exec -T dev flutter test

prod:
	docker compose up -d --build web
	@echo Build de producao em http://localhost:8080

rebuild:
	docker compose up -d --build --force-recreate dev

down:
	docker compose down
