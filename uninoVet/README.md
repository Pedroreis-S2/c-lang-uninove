# UninoVet

Clínica veterinária com três partes, todas em container:

- **Banco de dados** (MySQL) — tabelas e dados de exemplo criados sozinhos pelo `db/init.sql`.
- **Web** (Java, JSP/Servlet) — painel para gerenciar tutores, animais, veterinários e consultas.
- **Mobile** (Flutter) — aplicativo de agendamentos, foco do projeto.

## Como rodar

Só precisa de Docker. Na pasta `uninoVet`:

```
docker compose up
```

Depois abra:

- Mobile (Flutter): http://localhost:5000
- Web (painel): http://localhost:8080

Para parar: `docker compose down`.

## Estrutura

```
uninoVet/
  docker-compose.yml   sobe os três serviços
  db/init.sql          banco já pronto (tabelas + dados)
  web/                 painel em Java
  mobile/              aplicativo Flutter
```
