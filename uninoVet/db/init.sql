-- Banco da clinica UninoVet.
-- Este arquivo roda sozinho quando o container do MySQL sobe pela primeira vez
-- (fica em /docker-entrypoint-initdb.d). Cria as tabelas e ja deixa alguns
-- dados de exemplo, entao nao precisa rodar nada a mao.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------------

CREATE TABLE tutor (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  nome     VARCHAR(120) NOT NULL,
  telefone VARCHAR(20)  NOT NULL,
  email    VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE veterinario (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(120) NOT NULL,
  crmv          VARCHAR(20)  NOT NULL,
  especialidade VARCHAR(80)  NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE animal (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nome      VARCHAR(80) NOT NULL,
  especie   VARCHAR(40) NOT NULL,
  raca      VARCHAR(60),
  tutor_id  INT NOT NULL,
  CONSTRAINT fk_animal_tutor FOREIGN KEY (tutor_id) REFERENCES tutor (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE consulta (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  animal_id      INT NOT NULL,
  veterinario_id INT NOT NULL,
  data_hora      DATETIME NOT NULL,
  motivo         VARCHAR(160) NOT NULL,
  status         ENUM('AGENDADA', 'CONCLUIDA', 'CANCELADA') NOT NULL DEFAULT 'AGENDADA',
  CONSTRAINT fk_consulta_animal FOREIGN KEY (animal_id) REFERENCES animal (id),
  CONSTRAINT fk_consulta_vet    FOREIGN KEY (veterinario_id) REFERENCES veterinario (id)
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

INSERT INTO consulta (animal_id, veterinario_id, data_hora, motivo, status) VALUES
  (1, 1, '2026-10-20 09:00:00', 'Vacina anual',          'AGENDADA'),
  (2, 2, '2026-10-20 10:30:00', 'Coceira na pele',       'AGENDADA'),
  (3, 3, '2026-10-21 14:00:00', 'Mancando da pata',      'AGENDADA'),
  (4, 1, '2026-10-19 16:00:00', 'Retorno de rotina',     'CONCLUIDA');
