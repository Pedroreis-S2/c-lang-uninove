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

## Rodar (container)

```
docker compose up -d dev
docker compose logs -f dev
```

Abra http://localhost:5000. Testes: `docker compose exec dev flutter test`.
Produção (nginx): `docker compose up --build web` → http://localhost:8080.

O container inicia o Flutter e observa `lib/`, `web/`, `assets/` e `pubspec`
por polling, inclusive em volumes do Codespace/Windows. Salvar um arquivo
dispara a recompilação e a página aberta recarrega automaticamente depois do
sucesso, sem botão, comando interativo ou extensão de depuração. Alterações
no `pubspec.yaml`/`pubspec.lock` também executam `flutter pub get`.

No Flutter 3.24 web isso é **hot restart**, não hot reload com preservação de
estado: o estado em memória é reiniciado; o SQLite continua persistido.
Erros de compilação aparecem nos logs e não recarregam a página; corrija e
salve novamente. O polling do navegador não é ativado no build de produção.

Se o container já estava rodando com a configuração antiga, execute uma vez:
`docker compose up -d --build --force-recreate dev`. Depois basta salvar os
arquivos. Não execute outro `flutter run` na mesma porta. Na raiz do
repositório, `make estudae` usa esse mesmo fluxo automático.

Testes da recarga automática (o segundo comando roda no host com Node):

```sh
docker compose exec -T dev python3 -B -m unittest discover -s scripts -p 'test_*.py'
node --test scripts/test_bootstrap.cjs
```

Os dados da lista ficam só em memória: reiniciar o app apaga tudo (é o que a Aula 10 pede).
