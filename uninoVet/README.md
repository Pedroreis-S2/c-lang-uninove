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

## Estrutura

```
uninoVet/
  docker-compose.yml   sobe os quatro serviços
  db/init.sql          banco já pronto (tabelas + dados)
  web/                 painel em Java + API
  mobile/              aplicativo Flutter
  proxy/nginx.conf     junta /, /admin e /api numa porta só
```
