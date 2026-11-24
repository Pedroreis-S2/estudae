# Estudaê - atalhos para rodar o projeto com Docker (local ou Codespace).
#
#   make up       -> app Flutter em modo desenvolvimento na porta 5000
#   make logs     -> acompanha a compilação / recarga automática
#   make test     -> testes do Flutter (dentro do container)
#   make prod     -> build de produção servido por nginx na porta 8080
#   make down     -> desliga tudo
#
# No Codespace: rode o alvo e abra a porta pela aba PORTS.

COMPOSE := docker compose

.PHONY: help check-docker up estudae logs test test-reload prod rebuild down

help:
	@echo "make up          : sobe o Estudae (dev) na porta 5000"
	@echo "make logs        : logs da compilacao / recarga automatica"
	@echo "make test        : roda os testes do Flutter"
	@echo "make test-reload : testes da recarga automatica"
	@echo "make prod        : build de producao (nginx) na porta 8080"
	@echo "make rebuild     : recria a imagem/container de dev"
	@echo "make down        : desliga tudo"

check-docker:
	@command -v docker >/dev/null 2>&1 || { echo "Docker nao encontrado."; exit 1; }
	@$(COMPOSE) version >/dev/null 2>&1 || { echo "Docker Compose v2 nao encontrado."; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "Sem acesso ao daemon do Docker (ele esta rodando?)."; exit 1; }

up: check-docker
	$(COMPOSE) up -d dev
	@echo "Estudae subindo. Abra a porta 5000 e aguarde o Flutter compilar."
	@echo "Acompanhe com: make logs"

# Mesmo alvo com o nome antigo.
estudae: up

logs:
	$(COMPOSE) logs -f dev

test: check-docker
	$(COMPOSE) exec -T dev flutter test

test-reload: check-docker
	$(COMPOSE) exec -T dev python3 -B -m unittest discover -s scripts -p 'test_*.py'
	node --test scripts/test_bootstrap.cjs

prod: check-docker
	$(COMPOSE) up -d --build web
	@echo "Build de producao em http://localhost:8080"

rebuild: check-docker
	$(COMPOSE) up -d --build --force-recreate dev

down: check-docker
	$(COMPOSE) down
