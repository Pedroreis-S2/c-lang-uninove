# c-lang-uninove

Repositório com três projetos independentes:

- **`estudae/`** — plataforma de aulas em Flutter (Computação Móvel).
- **`uninoVet/`** — clínica veterinária (Flutter + API Java + MySQL).
- **`c-lang/`** — exercícios antigos em C.

Mexemos nos dois primeiros (`estudae` e `uninoVet`).

## Rodar no Codespace (ou local com Docker)

`estudae` e `uninoVet` usam as mesmas portas, então roda-se **um por vez**:

```
make estudae     # Estudae: app Flutter na porta 5000
make uninovet    # UninoVet: tudo na porta 3000 (/ app, /admin painel, /api)
make down        # desliga os dois
```

No Codespace, depois de rodar o alvo, abra a porta pela aba **PORTS**.

- **Estudae** → porta **5000**.
- **UninoVet** → porta **3000** (uma só): `/` é o app, `/admin` é o painel e `/api` é a API.

O ambiente do Codespace fica em `.devcontainer/` (Docker + Node + extensão do Claude). Rodar no Codespace não muda em nada o uso local: dentro de cada pasta, `docker compose up` continua funcionando como antes.
