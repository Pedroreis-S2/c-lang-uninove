-- Banco da clinica UninoVet.
-- Este arquivo roda sozinho quando o container do MySQL sobe pela primeira vez
-- (fica em /docker-entrypoint-initdb.d). Cria as tabelas e ja deixa alguns
-- dados de exemplo, entao nao precisa rodar nada a mao.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------------

-- Quem entra no sistema. A senha nunca e guardada pura: so o hash (PBKDF2).
-- Os usuarios de demonstracao sao criados pelo proprio Java na primeira subida.
CREATE TABLE usuario (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  nome       VARCHAR(120) NOT NULL,
  email      VARCHAR(120) NOT NULL UNIQUE,
  senha_hash VARCHAR(255) NOT NULL,
  perfil     ENUM('CLIENTE', 'VETERINARIO', 'SECRETARIO', 'GERENTE') NOT NULL,
  ativo      TINYINT(1) NOT NULL DEFAULT 1,
  criado_em  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sessao do aplicativo (token enviado no cabecalho Authorization: Bearer).
CREATE TABLE sessao (
  token      CHAR(64) PRIMARY KEY,
  usuario_id INT NOT NULL,
  expira_em  DATETIME NOT NULL,
  CONSTRAINT fk_sessao_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tutor (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  nome     VARCHAR(120) NOT NULL,
  telefone VARCHAR(20)  NOT NULL,
  email    VARCHAR(120),
  usuario_id INT NULL UNIQUE,
  CONSTRAINT fk_tutor_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE veterinario (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(120) NOT NULL,
  crmv          VARCHAR(20)  NOT NULL,
  especialidade VARCHAR(80)  NOT NULL,
  usuario_id    INT NULL UNIQUE,
  CONSTRAINT fk_veterinario_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE animal (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nome      VARCHAR(80) NOT NULL,
  especie   VARCHAR(40) NOT NULL,
  raca      VARCHAR(60),
  tutor_id  INT NOT NULL,
  CONSTRAINT fk_animal_tutor FOREIGN KEY (tutor_id) REFERENCES tutor (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- O que a clinica oferece. A duracao define quantos slots de 30 min ocupa.
CREATE TABLE tipo_servico (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  nome            VARCHAR(80) NOT NULL,
  categoria       ENUM('CONSULTA', 'BANHO_TOSA', 'OUTRO') NOT NULL,
  duracao_minutos INT NOT NULL,
  ativo           TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Status: SOLICITADA (pedido do cliente, nao reserva nada), AGENDADA (aceita,
-- ocupa o horario), RECUSADA, CONCLUIDA e CANCELADA. AGENDADA = "ACEITA" dos
-- requisitos; o nome foi mantido para nao quebrar o app e o painel.
CREATE TABLE consulta (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  animal_id       INT NOT NULL,
  veterinario_id  INT NOT NULL,
  tipo_servico_id INT NULL,
  data_hora       DATETIME NOT NULL,
  fim             DATETIME NULL,
  motivo          VARCHAR(160) NOT NULL,
  status          ENUM('SOLICITADA', 'AGENDADA', 'RECUSADA', 'CONCLUIDA', 'CANCELADA') NOT NULL DEFAULT 'AGENDADA',
  motivo_recusa   VARCHAR(160) NULL,
  solicitada_em   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_consulta_animal FOREIGN KEY (animal_id) REFERENCES animal (id),
  CONSTRAINT fk_consulta_vet    FOREIGN KEY (veterinario_id) REFERENCES veterinario (id),
  CONSTRAINT fk_consulta_servico FOREIGN KEY (tipo_servico_id) REFERENCES tipo_servico (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Receitas, laudos e outros arquivos anexados pelo veterinario a uma consulta.
CREATE TABLE documento (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  consulta_id  INT NOT NULL,
  tipo         ENUM('RECEITA', 'LAUDO', 'OUTRO') NOT NULL,
  nome_arquivo VARCHAR(160) NOT NULL,
  arquivo      VARCHAR(80)  NOT NULL,
  enviado_por  INT NOT NULL,
  criado_em    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_documento_consulta FOREIGN KEY (consulta_id) REFERENCES consulta (id) ON DELETE CASCADE,
  CONSTRAINT fk_documento_usuario  FOREIGN KEY (enviado_por) REFERENCES usuario (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Dados de exemplo
-- ---------------------------------------------------------------------------

INSERT INTO tutor (nome, telefone, email) VALUES
  ('Ana Souza',     '11 98888-0001', 'ana.souza@email.com'),
  ('Bruno Lima',    '11 98888-0002', 'bruno.lima@email.com'),
  ('Carla Mendes',  '11 98888-0003', 'carla.mendes@email.com');

INSERT INTO veterinario (nome, crmv, especialidade) VALUES
  ('Dra. Marina Reis', 'SP-12345', 'Clinica geral'),
  ('Dr. Paulo Nunes',  'SP-23456', 'Dermatologia'),
  ('Dra. Julia Castro','SP-34567', 'Ortopedia');

INSERT INTO animal (nome, especie, raca, tutor_id) VALUES
  ('Thor',   'Cachorro', 'Golden Retriever', 1),
  ('Mel',    'Gato',     'Siames',           1),
  ('Rex',    'Cachorro', 'Vira-lata',        2),
  ('Nina',   'Gato',     'Persa',            3);

INSERT INTO tipo_servico (nome, categoria, duracao_minutos) VALUES
  ('Consulta geral', 'CONSULTA',   30),
  ('Vacinacao',      'CONSULTA',   30),
  ('Retorno',        'CONSULTA',   30),
  ('Banho e tosa',   'BANHO_TOSA', 90);

INSERT INTO consulta (animal_id, veterinario_id, tipo_servico_id, data_hora, fim, motivo, status) VALUES
  (1, 1, 2, '2026-10-20 09:00:00', '2026-10-20 09:30:00', 'Vacina anual',      'AGENDADA'),
  (2, 2, 1, '2026-10-20 10:30:00', '2026-10-20 11:00:00', 'Coceira na pele',   'AGENDADA'),
  (3, 3, 1, '2026-10-21 14:00:00', '2026-10-21 14:30:00', 'Mancando da pata',  'AGENDADA'),
  (4, 1, 3, '2026-10-19 16:00:00', '2026-10-19 16:30:00', 'Retorno de rotina', 'CONCLUIDA'),
  (1, 1, 4, '2026-12-01 13:00:00', '2026-12-01 14:30:00', 'Banho e tosa',      'AGENDADA'),
  (2, 1, 1, '2026-12-01 15:00:00', '2026-12-01 15:30:00', 'Check-up',          'SOLICITADA');
