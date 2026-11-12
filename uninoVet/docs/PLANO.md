# UninoVet - Plano do produto

Documento de referência para as próximas etapas. A ideia: sempre que uma fase terminar, marcar aqui e seguir para a próxima, sem perder o desenho final.

## 1. Onde estamos

- Painel Java (JSP/Servlet) em `:8080` + API JSON `/api/agendamentos`.
- App Flutter (web e Android) em `:5000`: Início, Agenda, Pets, modo escuro, layout adaptativo.
- MySQL 8 com `db/init.sql` (tutor, veterinario, animal, consulta) e dados de exemplo.
- Tudo em containers; `make uninovet` sobe Java primeiro e passa a URL dele ao Flutter (`API_BASE`).
- Hot reload automático do Flutter (`mobile/scripts/dev.py`), local e Codespace.

## 2. Visão final

Clínica com três tipos de acesso, cada um com o seu login:

| Perfil | O que faz |
|---|---|
| **Tutor** (dono) | Cria conta, cadastra um ou mais pets com foto, solicita consultas, acompanha o status e o histórico. Vê **somente** os próprios pets. |
| **Veterinário** | Tem acesso próprio. Vê os pedidos destinados a ele (ou sem veterinário definido), aceita, recusa, remarca, conclui e registra o atendimento. |
| **Gerente** | Vê tudo: todas as consultas, veterinários, tutores e pets. Cadastra veterinários, tipos de consulta e define quem atende o quê. |

Fluxo principal:

```
Tutor solicita  ->  SOLICITADA  ->  veterinário aceita  ->  AGENDADA  ->  CONCLUIDA
                        |                  |
                        v                  v
                    RECUSADA           CANCELADA (tutor ou clínica)
```

## 3. Decisões já tomadas

- **Foco no Flutter.** O Java só expõe API JSON e acessa o banco; sem regra de interface nele.
- **Duas aplicações, duas portas** (Java 8080, Flutter 5000), pensadas para apresentação.
- **O back devolve dado cru**; label e formatação (data, status, moeda) são do front.
- **Payload por chave de campo**, não lista de objetos.
- **Tudo containerizado**; só Docker, VS Code ou Codespace.
- **Migrations versionadas** para termos o histórico de tudo que mudou no banco (seção 5).

## 4. Modelo de dados alvo

```
usuario            id, nome, email (único), senha_hash, perfil (TUTOR|VETERINARIO|GERENTE),
                   ativo, criado_em
tutor              id, usuario_id -> usuario, telefone
veterinario        id, usuario_id -> usuario, crmv, especialidade_id
especialidade      id, nome
tipo_consulta      id, nome, duracao_minutos, preco, ativo
pet                id, tutor_id -> tutor, nome, especie, raca, nascimento, observacoes
foto_pet           id, pet_id -> pet, arquivo, criado_em
consulta           id, pet_id, tipo_consulta_id, veterinario_id (pode ser nulo no pedido),
                   data_hora_desejada, data_hora_confirmada, motivo,
                   status (SOLICITADA|AGENDADA|CONCLUIDA|RECUSADA|CANCELADA),
                   justificativa, criado_em, atualizado_em
atendimento        id, consulta_id, diagnostico, prescricao, retorno_em
auditoria          id, usuario_id, acao, entidade, entidade_id, antes, depois, criado_em
```

Regras de dono:
- Toda consulta de tutor passa por `pet.tutor_id = tutor logado`.
- Veterinário vê consultas onde `veterinario_id = ele` ou `veterinario_id IS NULL` (fila de pedidos).
- Gerente não tem filtro.

## 5. Migrations (histórico do banco)

- Ferramenta: **Flyway** rodando no container do Java (ou container próprio de migração) na subida.
- Arquivos em `uninoVet/db/migrations/`, nome `V001__estrutura_inicial.sql`, `V002__usuarios_e_perfis.sql`, ...
- Regras: nunca editar uma migration já aplicada; mudança nova = arquivo novo.
- A tabela `flyway_schema_history` registra o que rodou, quando e o checksum.
- `V001` = o `init.sql` atual convertido. Dados de exemplo ficam em `R__dados_exemplo.sql` (repetível) ou em perfil de desenvolvimento.
- Além do histórico de estrutura, a tabela `auditoria` guarda o histórico de **dados** importantes (aceitar, recusar, cancelar, mudar de veterinário).

## 6. Autenticação e acesso

- Login por e-mail e senha; senha com **BCrypt** (nunca em texto).
- Resposta do login: token de sessão (JWT curto ou token opaco guardado em tabela `sessao`).
- Flutter guarda o token (secure storage no Android, memória/`localStorage` no web) e envia em `Authorization: Bearer`.
- O Java valida o token em um filtro único e injeta usuário e perfil na requisição; os servlets só consultam.
- Cadastro público cria apenas `TUTOR`. Veterinário e gerente são criados pelo gerente (ou seed do primeiro gerente).
- Recuperação de senha: fase posterior.

## 7. API (rascunho)

| Método | Rota | Quem |
|---|---|---|
| POST | `/api/login`, `/api/cadastro` | público |
| GET/POST | `/api/pets` | tutor |
| POST | `/api/pets/{id}/foto` | tutor (dono do pet) |
| GET | `/api/pets/{id}/foto` | dono do pet, veterinário, gerente |
| GET/POST | `/api/consultas` | tutor (as dele), vet (as dele + fila), gerente (todas) |
| POST | `/api/consultas/{id}/aceitar` `/recusar` `/concluir` `/cancelar` | vet, gerente |
| GET/POST | `/api/tipos-consulta` | leitura todos, escrita gerente |
| GET/POST | `/api/veterinarios` | leitura todos, escrita gerente |
| GET | `/api/auditoria` | gerente |

## 8. Telas (Flutter)

Comum: Login, Cadastro, Perfil, modo claro/escuro.

- **Tutor:** Meus pets (galeria com foto), Novo pet, Solicitar consulta (pet, tipo, data, motivo), Minhas consultas (com status), Histórico por pet.
- **Veterinário:** Pedidos pendentes (aceitar/recusar/remarcar), Minha agenda, Registrar atendimento, Pets que atendi.
- **Gerente:** Painel geral (números, consultas de todos), Veterinários (cadastro e agenda), Tipos de consulta, Tutores e pets, Auditoria.
- O menu muda conforme o perfil; layout continua adaptativo (lateral no web, inferior no celular).

## 9. Imagens de pets

- Hoje: retrato ilustrado gerado pelo app (`AvatarPet`) enquanto não há foto.
- Alvo: upload de foto pelo tutor (galeria/câmera no Android, arquivo no web).
- Armazenamento: volume Docker `uploads/` no container Java; no banco só o nome do arquivo.
- Acesso: nunca servir a pasta direto; rota `/api/pets/{id}/foto` confere dono, veterinário ou gerente.
- Limites: tipo (jpg/png/webp), tamanho máximo (ex.: 5 MB), nome do arquivo gerado (não o do usuário).

## 10. Fases

| # | Entrega | Situação |
|---|---|---|
| 0 | Base: painel Java, API, app Flutter, Docker, Codespace, hot reload | feito |
| 1 | Visual moderno: barra, logo, avatares de pets, cartões, modo escuro | em andamento |
| 2 | Migrations (Flyway) + estrutura de usuários e perfis | a fazer |
| 3 | Login/cadastro (tutor) + filtro de acesso na API | a fazer |
| 4 | Pets do tutor + foto + "ver só o meu" | a fazer |
| 5 | Solicitar consulta + tipos de consulta | a fazer |
| 6 | Perfil veterinário: fila de pedidos, aceitar/recusar/concluir | a fazer |
| 7 | Perfil gerente: veterinários, tipos, visão geral, auditoria | a fazer |
| 8 | Notificações (e-mail ou push), recuperação de senha, relatórios | opcional |

Cada fase fecha com: testes do que foi criado, migration registrada, documentação atualizada aqui e PDF `UninoVet-Documentacao.pdf` regenerado.

## 11. Cuidados

- **Privacidade:** tutor nunca enxerga pet ou consulta de outro; teste automatizado para isso em cada rota.
- **Segredos:** chave do token e senha do banco em variável de ambiente, nunca no repositório.
- **Codespace:** portas privadas por padrão; se o app não alcançar a API, avaliar liberar apenas a 8080 conscientemente.
- **CORS:** hoje `*`; com login, restringir ao endereço do app.
- **Demonstração:** manter usuários de exemplo (um tutor, um veterinário, um gerente) no seed de desenvolvimento.
