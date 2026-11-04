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

### Preparar o Docker no Codespace

O devcontainer instala o **Docker CLI, o daemon (Docker-in-Docker) e o
Compose v2** durante a criação do ambiente. A feature inicia o daemon junto
com o container; `make check-docker` verifica CLI, Compose e acesso ao daemon
a cada início do Codespace e antes dos alvos que sobem/desligam os projetos.

A imagem base está fixada em **Ubuntu 24.04**, compatível com o Moby usado
pela feature. Não troque pela tag móvel `base:ubuntu`: ela pode apontar para
uma distribuição ainda sem os pacotes necessários. Nesse caso, o build
falha e o Codespace abre um container de recuperação sem o daemon Docker.

Se o Codespace já existia antes dessa configuração, execute **Codespaces:
Rebuild Container** pela paleta de comandos do VS Code. Apenas reabrir o
terminal ou instalar o CLI não instala/inicia o daemon. O erro
`/var/run/docker.sock: no such file or directory` indica que o socket do
daemon não está disponível.

Depois da reconstrução, valide e inicie o Estudae:

```sh
make check-docker
make estudae
docker compose -f estudae/docker-compose.yml exec dev flutter test
curl --fail http://localhost:5000
```

Na primeira execução, aguarde o download/build da imagem e a compilação do
Flutter antes de testar a porta 5000. `make estudae` inicia o Flutter em
segundo plano; o retorno do alvo não significa que a página já está pronta.
Se a verificação do Docker ou a parada de um projeto falhar, o Makefile
interrompe a execução sem tentar subir o próximo projeto.

No Codespace, depois de rodar o alvo, abra a porta pela aba **PORTS**.

No Estudae, o próprio container observa os arquivos e recompila ao salvar;
a página aberta recarrega automaticamente após uma compilação bem-sucedida.
Não é necessário botão de hot reload nem executar `flutter run` à parte.
O Flutter web 3.24 usa hot restart, reiniciando o estado em memória.
Veja o progresso/erros com `docker compose -f estudae/docker-compose.yml logs -f dev`.

- **Estudae** → porta **5000**.
- **UninoVet** → porta **3000** (uma só): `/` é o app, `/admin` é o painel e `/api` é a API.

O ambiente do Codespace fica em `.devcontainer/` (Docker + Node + extensão do Claude). Rodar no Codespace não muda em nada o uso local: dentro de cada pasta, `docker compose up` continua funcionando como antes.
