# Estudaê (plataforma de aulas)

App Flutter (web) da disciplina Computação Móvel. Cada aula do site vira um arquivo em `lib/aulas/`.

| Aula | Arquivo | Telas |
|---|---|---|
| 7 | `aula07_telas.dart` | `TelaInicio` (menu), `TelaDisciplina`, `AvisoModal` |
| 8 | `aula08_estados.dart` | `TelaEstudos` (Plano de estudos: contador, nome, modo foco), `TelaResumo` |
| 9 | `aula09_formulario.dart` | `TelaUltimaSessao`, `TelaFormulario` (tema, duração, observação; validação e retorno) |
| 10 | `aula10_lista.dart` | `TelaLista` (Minhas sessões: cadastrar, editar, excluir com confirmação) |
| 11-12 | `aula11_sqlite.dart` + `dados/` | `TelaSessoesSalvas` (SQLite: cadastro, consulta, edição e exclusão; os dados ficam salvos no `sessoes.db` e sobrevivem a fechar/reabrir) |

## SQLite (Aulas 11 e 12)

A tela "Sessões salvas" grava no SQLite via `sqflite`. No Android usa o banco nativo; na web usa a versão em WebAssembly (`sqflite_common_ffi_web`), escolhida em `lib/dados/config_banco.dart`. Os arquivos do banco no web (`web/sqlite3.wasm` e `web/sqflite_sw.js`) vêm do comando `dart run sqflite_common_ffi_web:setup` e já estão no repositório.

## Trocar de domínio (ex.: virar comércio)

As telas não têm texto, nome de campo nem limite escritos no código. Tudo vem de `lib/config/`:

- `strings.dart`: todos os textos.
- `campos.dart`: nomes dos campos do registro (`tema`, `minutos`, `observacao`). Ex.: `tema` → `nome`, `minutos` → `preco`.
- `regras.dart`: limites da validação (tamanho mínimo do tema, faixa da duração).
- `tema.dart`: cor-base, raios e espaçamentos (paletas clara e escura saem da cor-base).

## Rodar

Só precisa de Docker (com Compose v2). Os atalhos estão no `Makefile`:

| Comando | O que faz |
|---|---|
| `make up` | Sobe o app em modo desenvolvimento → http://localhost:5000 |
| `make logs` | Acompanha a compilação e a recarga automática |
| `make test` | Roda os testes do Flutter dentro do container |
| `make test-reload` | Testes da recarga automática (o segundo roda no host com Node) |
| `make prod` | Build de produção servido por nginx → http://localhost:8080 |
| `make rebuild` | Recria a imagem/container de desenvolvimento |
| `make down` | Desliga tudo |

Sem `make`, os comandos equivalentes são:

```
docker compose up -d dev
docker compose logs -f dev
docker compose exec dev flutter test
docker compose up --build web
docker compose down
```

Na primeira execução, aguarde o download/build da imagem e a compilação do
Flutter antes de abrir a porta 5000: `make up` volta antes de a página estar
pronta (acompanhe com `make logs`).

### Codespace

O `.devcontainer/` cria um ambiente Ubuntu 24.04 com **Docker-in-Docker**,
Compose v2, Node e `make`. Ao abrir o Codespace:

```sh
make up
```

e abra a porta **5000** pela aba **PORTS**. Se o Codespace já existia antes
dessa configuração, execute **Codespaces: Rebuild Container** pela paleta de
comandos. O erro `/var/run/docker.sock: no such file or directory` indica que
o daemon do Docker não está disponível (falta o rebuild).

A imagem base está fixada em `ubuntu-24.04`, compatível com o Moby usado pela
feature do Docker. Não troque pela tag móvel `base:ubuntu`.

### Recarga automática

O container inicia o Flutter e observa `lib/`, `web/`, `assets/` e `pubspec`
por polling, inclusive em volumes do Codespace/Windows. Salvar um arquivo
dispara a recompilação e a página aberta recarrega automaticamente depois do
sucesso, sem botão, comando interativo ou extensão de depuração. Alterações
no `pubspec.yaml`/`pubspec.lock` também executam `flutter pub get`.

No Flutter 3.24 web isso é **hot restart**, não hot reload com preservação de
estado: o estado em memória é reiniciado; o SQLite continua persistido.
Erros de compilação aparecem nos logs e não recarregam a página; corrija e
salve novamente. O polling do navegador não é ativado no build de produção.

Se o container já estava rodando com a configuração antiga, execute uma vez
`make rebuild`. Depois basta salvar os arquivos. Não execute outro
`flutter run` na mesma porta.

Os dados da lista ficam só em memória: reiniciar o app apaga tudo (é o que a Aula 10 pede).

## Estrutura

```
lib/
  main.dart          entrada do app
  aulas/             uma tela/arquivo por aula (7 a 12)
  config/            textos, campos, regras e tema (troca de domínio)
  dados/             acesso ao SQLite (sqflite)
  widgets/           componentes compartilhados
test/                testes do Flutter
web/                 index, bootstrap e arquivos do SQLite (wasm)
scripts/             recarga automática do container de dev (+ testes)
Dockerfile.dev       imagem de desenvolvimento (Flutter)
Dockerfile           build de produção servido por nginx (nginx.conf)
docker-compose.yml   serviços dev (5000) e web (8080)
Makefile             atalhos (make help)
.devcontainer/       ambiente do Codespace (Docker-in-Docker)
```
