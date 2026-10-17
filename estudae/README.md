# Estudaê (plataforma de aulas)

App Flutter (web) da disciplina Computação Móvel. Cada aula do site vira um arquivo em `lib/aulas/`.

| Aula | Arquivo | Telas |
|---|---|---|
| 7 | `aula07_telas.dart` | `TelaInicio` (menu), `TelaDisciplina`, `AvisoModal` |
| 8 | `aula08_estados.dart` | `TelaEstudos` (Plano de estudos: contador, nome, modo foco), `TelaResumo` |
| 9 | `aula09_formulario.dart` | `TelaUltimaSessao`, `TelaFormulario` (tema, duração, observação; validação e retorno) |
| 10 | `aula10_lista.dart` | `TelaLista` (Minhas sessões: cadastrar, editar, excluir com confirmação) |

## Trocar de domínio (ex.: virar comércio)

As telas não têm texto, nome de campo nem limite escritos no código. Tudo vem de `lib/config/`:

- `strings.dart`: todos os textos.
- `campos.dart`: nomes dos campos do registro (`tema`, `minutos`, `observacao`). Ex.: `tema` → `nome`, `minutos` → `preco`.
- `regras.dart`: limites da validação (tamanho mínimo do tema, faixa da duração).
- `tema.dart`: cor-base, raios e espaçamentos (paletas clara e escura saem da cor-base).

## Rodar (container)

```
docker compose up -d dev
docker compose exec dev flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

Abra http://localhost:5000. Testes: `docker compose exec dev flutter test`.
Produção (nginx): `docker compose up --build web` → http://localhost:8080.

Os dados da lista ficam só em memória: reiniciar o app apaga tudo (é o que a Aula 10 pede).
