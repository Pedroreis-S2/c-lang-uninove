# UninoVet

Clínica veterinária com quatro partes, todas em container:

- **Banco de dados** (MySQL) — tabelas e dados de exemplo criados sozinhos pelo `db/init.sql`.
- **Web** (Java, JSP/Servlet) — painel para gerenciar tutores, animais, veterinários e consultas, e a API dos agendamentos.
- **Mobile** (Flutter) — aplicativo de agendamentos, foco do projeto.
- **Proxy** (nginx) — junta tudo numa porta só, para funcionar igual no local e no Codespace.

## Como rodar

Só precisa de Docker. Na pasta `uninoVet`:

```
docker compose up
```

Abra **uma porta só**: http://localhost:3000

- `/` → aplicativo (Flutter)
- `/admin` → painel administrativo (Java)
- `/api/...` → API dos agendamentos (consumida pelo app)

Por que uma porta só: no Codespace cada porta vira um endereço diferente, então o app não acharia a API em `localhost:8080`. Com o proxy é tudo na mesma origem, sem CORS. As portas diretas continuam disponíveis se quiser (app em 5000, painel em 8080).

Para parar: `docker compose down`.

## Três aplicações

| Aplicação | Porta | Quem usa |
|---|---|---|
| **Porta única** (nginx) | `3000` | Entrada recomendada: `/` app do cliente, `/clinica/` clínica, `/api` API |
| **App do cliente** (Flutter) | `5000` | Tutor: login, pets, solicitar/cancelar consulta, documentos |
| **Aplicação da clínica** (Java) | `8080` | Veterinário, secretário e gerente: `/painel`, `/agenda`, `/solicitacoes`, `/usuarios`; o painel antigo virou o módulo **`/admin`** (só gerente) |

No Codespace use `make uninovet` (na raiz do repositório) e abra a porta **3000** pela aba PORTS: é a única em que app e API ficam na mesma origem. Se quiser ver as outras separadas, abra 5000 e 8080 (portas privadas do Codespace podem pedir login do GitHub).

### Contas de exemplo (só desenvolvimento)

Criadas pelo Java na primeira subida com o banco vazio. **Troque ou remova em produção.**

| Perfil | E-mail | Senha |
|---|---|---|
| Gerente | `gerente@uninovet.com` | `gerente123` |
| Secretário | `secretaria@uninovet.com` | `secretaria123` |
| Veterinário | `marina@uninovet.com` (também `paulo@`, `julia@`) | `vet12345` |
| Cliente | `ana.souza@email.com` (também `bruno.lima@`, `carla.mendes@`) | `cliente123` |

Qualquer pessoa pode criar conta de **cliente** pelo app; os demais perfis são criados pelo gerente em `/usuarios`.

### Regras da agenda

- Horários de 30 em 30 minutos, segunda a sábado, 08:00–18:00 (premissa; o conflito é por veterinário).
- Cada serviço tem duração (ex.: banho e tosa = 90 min) e ocupa os horários dessa duração.
- O cliente **solicita** (status `SOLICITADA`, não reserva nada); a secretaria/gerente **aceita** (`AGENDADA`, ocupa o horário) ou **recusa**. Ao aceitar, o conflito é conferido de novo.
- O cliente só cancela até 30 minutos antes; a clínica cancela sempre.
- Somente o veterinário da consulta a conclui e anexa documentos (PDF, JPG ou PNG, até 5 MB); o cliente baixa pelo app.
- `AGENDADA` equivale a "ACEITA" dos requisitos (nome mantido para não quebrar o app).

### Segurança (resumo)

Senha com PBKDF2 + sal; API por token (7 dias) e painel por sessão com token CSRF; tudo é conferido no servidor por perfil e por dono (cliente nunca vê dado de outro); SQL com `PreparedStatement`; saída HTML escapada; downloads por link assinado de 2 minutos. O token do app fica só na memória (recarregar a página pede login de novo). CORS: defina `CORS_ORIGEM` em produção.

## Estrutura

```
uninoVet/
  docker-compose.yml   sobe os quatro serviços
  db/init.sql          banco já pronto (tabelas + dados)
  web/                 painel em Java + API
  mobile/              aplicativo Flutter
  proxy/nginx.conf     junta /, /admin e /api numa porta só
```
