# Status dos requisitos futuros (v2)

Referência: `docs/uninovet-requisitos.patch` (requisitos v2). Verificado em 12/11/2026 com Docker local (API por curl, painel por curl/cookies, app Flutter no navegador). **Não** foi testado dentro de um Codespace de verdade.

## Feito

| Requisito | Como ficou |
|---|---|
| RF01 Login/logout nas duas pontas | Painel Java: sessão por cookie + CSRF. App: token (`/api/login`). Senha PBKDF2 com sal. |
| RF02 Cadastro | Cliente se cadastra no app (`/api/cadastro`); funcionários criados pelo gerente em `/usuarios`. |
| RF03 Vínculo usuário ↔ pessoa | `tutor.usuario_id` e `veterinario.usuario_id`. |
| RF05 Acesso por papel | Filtro de API e de painel; dono conferido no servidor (cliente nunca vê dado de outro). |
| RF10 Pets do tutor | Lista e cadastro de pet no app. Edição de pet: não. |
| RF11 Lista/detalhe de consultas | App, com filtros por status. |
| RF12 Solicitar agendamento | Pet, serviço, veterinário, dia e horários **livres** vindos do servidor; nasce `SOLICITADA`. |
| RF13 Acompanhar status | `SOLICITADA`, `AGENDADA` (= ACEITA), `RECUSADA`, `CONCLUIDA`, `CANCELADA`. |
| RF14 Cancelar até 30 min antes | Servidor recusa depois disso; app só mostra o botão quando permitido. |
| RF15 Ver/baixar documentos | Link assinado de 2 minutos. |
| RF20 Aplicação da clínica | `/painel`, `/agenda`, `/solicitacoes`, `/usuarios`, `/login`; `/admin` (JSP antigo) é módulo dentro dela, só gerente. |
| RF21 Fila de solicitações | Aceitar (revalida conflito) / recusar com motivo. |
| RF22 Agenda | Por dia e por veterinário; secretaria agenda direto (nasce aceita). |
| RF23 Conclusão | Somente o veterinário da consulta. |
| RF24 Documentos | Veterinário anexa PDF/JPG/PNG até 5 MB (confere extensão e bytes). |
| RF25 Tipos de serviço | Tabela `tipo_servico` (cadastro pelo `/admin`). |
| RN01–RN08 | Slots de 30 min, duração do serviço, só aceita ocupa horário, sem sobreposição por veterinário, cancelada/recusada liberam, fluxo de status, sem passado/fora do expediente. |
| RNF01 Regras no servidor | Revalida ao solicitar e ao aceitar, com trava por veterinário. |
| RNF02 Segurança básica | PreparedStatement, saída HTML escapada, tokens com expiração; `CORS_ORIGEM` configurável. |
| RNF04 Uma porta só | `make uninovet`: 3000 (proxy), 5000 (app), 8080 (clínica). |

## Não feito / pendente

- **RF04 Preferências** (opcional) e **RF26** listas de seleção no CRUD `/admin` (o formulário ainda pede ids).
- Fotos de pet, auditoria, notificações, remarcar consulta (cliente só cancela e solicita de novo).
- Veterinário/secretário **no app Flutter**: eles entram, mas só veem listas; as ações ficam no painel da clínica.
- Token do app só na memória (recarregar a página pede login de novo).
- **Testes automatizados novos: nenhum foi criado** (combinado: não mexer em testes sem perguntar). Os 3 testes existentes (`mobile/test/widget_test.dart`) continuam passando sem alteração.
- Teste real no Codespace e HTTPS/cookie `Secure` em produção.
- Premissas assumidas nas questões em aberto: conflito por veterinário; expediente seg–sáb 08:00–18:00; cliente escolhe o veterinário; arquivos em disco (volume `uploads`).
