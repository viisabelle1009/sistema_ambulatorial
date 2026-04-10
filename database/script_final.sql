

-- ========================================
-- início do script 
-- ========================================


USE hospital_ambulatorial;
SELECT DATABASE();


CREATE TABLE perfis (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);
INSERT IGNORE INTO perfis (nome) VALUES
('ATENDENTE'),
('SUPERVISOR'),
('MEDICO');

CREATE TABLE pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    nome_social VARCHAR(150),
    cpf CHAR(11) NOT NULL UNIQUE,
    sexo_biologico ENUM('F','M') NOT NULL,
    genero VARCHAR(50),
    data_nascimento DATE NOT NULL,
    bloqueado_ate DATE NULL,
    faltas_consecutivas INT DEFAULT 0,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialidades (
    id_especialidade INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    permite_sexo ENUM('F','M','AMBOS') DEFAULT 'AMBOS',
    idade_minima INT NULL,
    idade_maxima INT NULL,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipos_exame (
    id_tipo_exame INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    id_perfil INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuarios_perfis
    FOREIGN KEY (id_perfil)
    REFERENCES perfis(id_perfil)
);

CREATE TABLE medicos (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,
    id_especialidade INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_medicos_especialidades
    FOREIGN KEY (id_especialidade)
    REFERENCES especialidades(id_especialidade)
);

CREATE TABLE agenda_medica (
    id_agenda INT AUTO_INCREMENT PRIMARY KEY,
    id_medico INT NOT NULL,
    data DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_medico)
        REFERENCES medicos(id_medico)
);

CREATE TABLE agendamentos (
    id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    tipo ENUM('consulta','exame') NOT NULL,
    id_medico INT NULL,
    id_tipo_exame INT NULL,
    data_hora DATETIME NOT NULL,
    status ENUM('marcado','cancelado','cancelamento_tardio','realizado','faltou') NOT NULL DEFAULT 'marcado',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_agendamentos_paciente_data_hora
    UNIQUE (id_paciente, data_hora),

    CONSTRAINT fk_agendamentos_pacientes
    FOREIGN KEY (id_paciente)
    REFERENCES pacientes(id_paciente),

    CONSTRAINT fk_agendamentos_medicos
    FOREIGN KEY (id_medico)
    REFERENCES medicos(id_medico),

    CONSTRAINT fk_agendamentos_tipos_exame
    FOREIGN KEY (id_tipo_exame)
    REFERENCES tipos_exame(id_tipo_exame)
);

CREATE TABLE consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_agendamento INT NOT NULL UNIQUE,
    observacoes TEXT,
    diagnostico TEXT,
    encerrada_em DATETIME NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_consultas_agendamentos
    FOREIGN KEY (id_agendamento)
    REFERENCES agendamentos(id_agendamento)
);

CREATE TABLE exames (
    id_exame INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    id_tipo_exame INT NOT NULL,
    resultado TEXT,
    data_exame DATETIME NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_exames_consultas
    FOREIGN KEY (id_consulta)
    REFERENCES consultas(id_consulta),

    CONSTRAINT fk_exames_tipos_exame
    FOREIGN KEY (id_tipo_exame)
    REFERENCES tipos_exame(id_tipo_exame)
);

CREATE TABLE historico_faltas (
    id_falta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_agendamento INT NOT NULL,
    data_falta DATETIME NOT NULL,
    registrada_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_historico_faltas_pacientes
    FOREIGN KEY (id_paciente)
    REFERENCES pacientes(id_paciente),

    CONSTRAINT fk_historico_faltas_agendamentos
    FOREIGN KEY (id_agendamento)
    REFERENCES agendamentos(id_agendamento)
);

CREATE TABLE alertas (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    tipo ENUM('informativo','advertencia','bloqueio') NOT NULL,
    mensagem TEXT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alertas_pacientes
    FOREIGN KEY (id_paciente)
    REFERENCES pacientes(id_paciente)
);

CREATE TABLE log_acoes (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    acao VARCHAR(100) NOT NULL,
    tabela_afetada VARCHAR(100) NOT NULL,
    registro_id INT,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalhes TEXT,

    CONSTRAINT fk_log_acoes_usuarios
    FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario)
);


-- ========================================
-- indices
-- ========================================

CREATE INDEX idx_agendamento_data
ON agendamentos(data_hora);

CREATE INDEX idx_agendamento_status
ON agendamentos(status);

CREATE INDEX idx_agendamento_medico
ON agendamentos(id_medico);

CREATE INDEX idx_exame_consulta
ON exames(id_consulta);

CREATE INDEX idx_historico_paciente
ON historico_faltas(id_paciente);

CREATE INDEX idx_historico_agendamento
ON historico_faltas(id_agendamento);

CREATE INDEX idx_log_acoes_usuario
ON log_acoes(id_usuario);

CREATE INDEX idx_log_acoes_data_hora
ON log_acoes(data_hora);

-- ========================================
-- fim do script
-- ========================================



-- ========================================
-- bora povoar
-- ========================================

INSERT INTO especialidades (nome, permite_sexo, idade_minima, idade_maxima)
VALUES
('Clínico Geral', 'AMBOS', 0, NULL),
('Pediatria', 'AMBOS', 0, 12),
('Ginecologia', 'F', 12, NULL),
('Urologia', 'M', 18, NULL),
('Cardiologia', 'AMBOS', 18, NULL),
('Ortopedia', 'AMBOS', 0, NULL);

SELECT * FROM especialidades;

INSERT INTO tipos_exame (nome, descricao)
VALUES
('Hemograma', 'Exame de sangue para avaliação geral'),
('Raio-X', 'Exame de imagem para avaliação óssea'),
('Ultrassonografia', 'Exame de imagem por ultrassom'),
('Eletrocardiograma', 'Avaliação da atividade elétrica do coração'),
('Tomografia', 'Exame de imagem detalhado por camadas'),
('Ressonância Magnética', 'Exame de imagem de alta precisão'),
('Ecocardiograma', 'Exame de ultrassom do coração'),
('PSA', 'Exame de rastreamento, (Antígeno Prostático Específico)');

SELECT * FROM tipos_exame;

INSERT INTO usuarios (nome, email, senha_hash, id_perfil)
VALUES
('Ana Souza', 'anarecep@hospital.com', '123456', 1),
('Dr. Carlos Lima', 'drcarlos@hospital.com', '123456', 2),
('João Silva', 'joaosup@hospital.com', '123456', 3);

SELECT * FROM usuarios;

INSERT INTO medicos (nome, crm, id_especialidade)
VALUES
('Carlos Lima', 'CRM1001', 1),
('Marina Alves', 'CRM1002', 2),
('Fernanda Rocha', 'CRM1003', 3),
('Ricardo Souza', 'CRM1004', 4),
('Patrícia Gomes', 'CRM1005', 5),
('André Martins', 'CRM1006', 6);

SELECT * FROM medicos;

INSERT INTO pacientes (nome, nome_social, cpf, sexo_biologico, genero, data_nascimento)
VALUES

('Lucas Andrade', NULL, '11111111101', 'M', 'Masculino', '2015-03-10'),
('Mariana Souza', NULL, '11111111102', 'F', 'Feminino', '2012-07-22'),
('Pedro Lima', NULL, '11111111103', 'M', 'Masculino', '2000-05-15'),
('Juliana Alves', NULL, '11111111104', 'F', 'Feminino', '1998-11-03'),
('Carlos Mendes', NULL, '11111111105', 'M', 'Masculino', '1985-01-20'),
('Fernanda Rocha', NULL, '11111111106', 'F', 'Feminino', '1990-09-12'),
('José Oliveira', NULL, '11111111107', 'M', 'Masculino', '1950-04-18'),
('Maria Fernandes', NULL, '11111111108', 'F', 'Feminino', '1948-06-25'),
('Bruno Carvalho', NULL, '11111111111', 'M', 'Masculino', '2002-10-01'),
('Camila Ribeiro', NULL, '11111111112', 'F', 'Feminino', '1988-12-05'),
('Rafael Martins', NULL, '11111111113', 'M', 'Masculino', '1975-03-27'),
('Patrícia Gomes', NULL, '11111111114', 'F', 'Feminino', '1982-07-19'),
('Eduardo Nunes', NULL, '11111111115', 'M', 'Masculino', '1999-01-11'),
('Larissa Teixeira', NULL, '11111111116', 'F', 'Feminino', '2005-06-21'),
('Fernando Barros', NULL, '11111111117', 'M', 'Masculino', '1965-09-09'),
('Sônia Batista', NULL, '11111111118', 'F', 'Feminino', '1970-11-30'),
('Igor Freitas', NULL, '11111111119', 'M', 'Masculino', '2008-04-02'),
('Beatriz Moraes', NULL, '11111111120', 'F', 'Feminino', '2010-02-17'),
('Thiago Pinto', NULL, '11111111121', 'M', 'Masculino', '2014-05-12'),
('Isabela Moura', NULL, '11111111122', 'F', 'Feminino', '2013-09-08'),
('Lucas Ferreira', NULL, '11111111123', 'M', 'Masculino', '2001-03-19'),
('Amanda Duarte', NULL, '11111111124', 'F', 'Feminino', '1999-11-27'),
('Renato Barros', NULL, '11111111125', 'M', 'Masculino', '1987-02-10'),
('Carla Mendes', NULL, '11111111126', 'F', 'Feminino', '1992-06-14'),
('Antônio Ribeiro', NULL, '11111111127', 'M', 'Masculino', '1955-08-03'),
('Helena Costa', NULL, '11111111128', 'F', 'Feminino', '1952-01-22'),
('Diego Alves', NULL, '11111111131', 'M', 'Masculino', '2003-10-25'),
('Natália Rocha', NULL, '11111111132', 'F', 'Feminino', '1989-12-30'),
('Fábio Martins', NULL, '11111111133', 'M', 'Masculino', '1978-05-06'),
('Simone Teixeira', NULL, '11111111134', 'F', 'Feminino', '1983-03-21'),
('Gustavo Nunes', NULL, '11111111135', 'M', 'Masculino', '2000-08-17'),
('Larissa Freitas', NULL, '11111111136', 'F', 'Feminino', '2006-02-11'),
('Marcos Vinícius', NULL, '11111111137', 'M', 'Masculino', '1968-09-29'),
('Vera Lúcia', NULL, '11111111138', 'F', 'Feminino', '1972-11-13'),
('Caio Rodrigues', NULL, '11111111139', 'M', 'Masculino', '2007-01-05'),
('Bianca Cardoso', NULL, '11111111140', 'F', 'Feminino', '2011-06-23'),
('Gabriel Santos', 'Gabriela Santos', '11111111109', 'M', 'Feminino', '1995-02-14'),
('Aline Costa', 'Alan Costa', '11111111110', 'F', 'Masculino', '1993-08-30'),
('Bruno Santos', 'Bruna Santos', '11111111129', 'M', 'Feminino', '1996-04-18'),
('Juliana Lima', 'Juliano Lima', '11111111130', 'F', 'Masculino', '1994-07-09');

SELECT * FROM pacientes;

INSERT INTO agenda_medica (id_medico, data, hora_inicio, hora_fim, disponivel)
VALUES
-- 22/06 (segunda)
(1, '2026-06-22', '08:00:00', '10:00:00', TRUE),
(2, '2026-06-22', '08:00:00', '10:00:00', TRUE),
(3, '2026-06-22', '08:00:00', '10:00:00', TRUE),
(4, '2026-06-22', '14:00:00', '16:00:00', TRUE),
(5, '2026-06-22', '14:00:00', '16:00:00', TRUE),
(6, '2026-06-22', '14:00:00', '16:00:00', TRUE),

-- 23/06 (terça)
(1, '2026-06-23', '14:00:00', '16:00:00', TRUE),
(2, '2026-06-23', '14:00:00', '16:00:00', TRUE),
(3, '2026-06-23', '14:00:00', '16:00:00', TRUE),
(4, '2026-06-23', '08:00:00', '10:00:00', TRUE),
(5, '2026-06-23', '08:00:00', '10:00:00', TRUE),
(6, '2026-06-23', '08:00:00', '10:00:00', TRUE),

-- 24/06 (quarta)
(1, '2026-06-24', '08:00:00', '10:00:00', TRUE),
(2, '2026-06-24', '08:00:00', '10:00:00', TRUE),
(3, '2026-06-24', '08:00:00', '10:00:00', TRUE),
(4, '2026-06-24', '14:00:00', '16:00:00', TRUE),
(5, '2026-06-24', '14:00:00', '16:00:00', TRUE),
(6, '2026-06-24', '14:00:00', '16:00:00', TRUE),

-- 25/06 (quinta)
(1, '2026-06-25', '14:00:00', '16:00:00', TRUE),
(2, '2026-06-25', '14:00:00', '16:00:00', TRUE),
(3, '2026-06-25', '14:00:00', '16:00:00', TRUE),
(4, '2026-06-25', '08:00:00', '10:00:00', TRUE),
(5, '2026-06-25', '08:00:00', '10:00:00', TRUE),
(6, '2026-06-25', '08:00:00', '10:00:00', TRUE),

-- 26/06 (sexta)
(1, '2026-06-26', '08:00:00', '10:00:00', TRUE),
(2, '2026-06-26', '08:00:00', '10:00:00', TRUE),
(3, '2026-06-26', '08:00:00', '10:00:00', TRUE),
(4, '2026-06-26', '14:00:00', '16:00:00', TRUE),
(5, '2026-06-26', '14:00:00', '16:00:00', TRUE),
(6, '2026-06-26', '14:00:00', '16:00:00', TRUE);

SELECT * FROM agenda_medica;

INSERT INTO agendamentos (id_paciente, tipo, id_medico, id_tipo_exame, data_hora, status)
VALUES
-- SEG 22/06
(1, 'consulta', 1, NULL, '2026-06-22 08:00:00', 'marcado'),
(2, 'consulta', 1, NULL, '2026-06-22 09:00:00', 'marcado'),
(3, 'consulta', 1, NULL, '2026-06-22 10:00:00', 'marcado'),

(4, 'consulta', 2, NULL, '2026-06-22 08:00:00', 'marcado'),
(5, 'consulta', 2, NULL, '2026-06-22 09:00:00', 'marcado'),
(6, 'consulta', 2, NULL, '2026-06-22 10:00:00', 'marcado'),

-- TER 23/06
(7, 'consulta', 3, NULL, '2026-06-23 08:00:00', 'marcado'),
(8, 'consulta', 3, NULL, '2026-06-23 09:00:00', 'marcado'),
(9, 'consulta', 3, NULL, '2026-06-23 10:00:00', 'marcado'),

(10, 'consulta', 1, NULL, '2026-06-23 13:00:00', 'marcado'),
(11, 'consulta', 1, NULL, '2026-06-23 14:00:00', 'marcado'),
(12, 'consulta', 1, NULL, '2026-06-23 15:00:00', 'marcado'),

-- QUA 24/06
(13, 'consulta', 2, NULL, '2026-06-24 08:00:00', 'marcado'),
(14, 'consulta', 2, NULL, '2026-06-24 09:00:00', 'marcado'),
(15, 'consulta', 2, NULL, '2026-06-24 10:00:00', 'marcado'),

(16, 'consulta', 3, NULL, '2026-06-24 13:00:00', 'marcado'),
(17, 'consulta', 3, NULL, '2026-06-24 14:00:00', 'marcado'),
(18, 'consulta', 3, NULL, '2026-06-24 15:00:00', 'marcado'),

-- QUI 25/06
(19, 'consulta', 1, NULL, '2026-06-25 08:00:00', 'marcado'),
(20, 'consulta', 1, NULL, '2026-06-25 09:00:00', 'marcado'),
(21, 'consulta', 1, NULL, '2026-06-25 10:00:00', 'marcado'),

(22, 'consulta', 2, NULL, '2026-06-25 13:00:00', 'marcado'),
(23, 'consulta', 2, NULL, '2026-06-25 14:00:00', 'marcado'),
(24, 'consulta', 2, NULL, '2026-06-25 15:00:00', 'marcado'),

-- SEX 26/06
(25, 'consulta', 3, NULL, '2026-06-26 08:00:00', 'marcado'),
(26, 'consulta', 3, NULL, '2026-06-26 09:00:00', 'marcado'),
(27, 'consulta', 3, NULL, '2026-06-26 10:00:00', 'marcado'),

(28, 'consulta', 1, NULL, '2026-06-26 13:00:00', 'marcado'),
(29, 'consulta', 1, NULL, '2026-06-26 14:00:00', 'marcado'),
(30, 'consulta', 1, NULL, '2026-06-26 15:00:00', 'marcado');

INSERT INTO agendamentos (id_paciente, tipo, id_medico, id_tipo_exame, data_hora, status)
VALUES
(31, 'consulta', 4, NULL, '2026-06-24 08:00:00', 'marcado'),
(32, 'consulta', 4, NULL, '2026-06-24 09:00:00', 'marcado'),
(33, 'consulta', 4, NULL, '2026-06-24 10:00:00', 'marcado'),

(34, 'consulta', 5, NULL, '2026-06-25 13:00:00', 'marcado'),
(35, 'consulta', 5, NULL, '2026-06-25 14:00:00', 'marcado'),
(36, 'consulta', 5, NULL, '2026-06-25 15:00:00', 'marcado'),

(37, 'consulta', 6, NULL, '2026-06-26 08:00:00', 'marcado'),
(38, 'consulta', 6, NULL, '2026-06-26 09:00:00', 'marcado'),
(39, 'consulta', 6, NULL, '2026-06-26 10:00:00', 'marcado');

INSERT INTO agendamentos (id_paciente, tipo, id_medico, id_tipo_exame, data_hora, status)
VALUES
(40, 'consulta', 4, NULL, '2026-06-23 08:00:00', 'marcado'),
(31, 'consulta', 5, NULL, '2026-06-23 09:00:00', 'marcado'),
(32, 'consulta', 6, NULL, '2026-06-23 10:00:00', 'marcado');


SELECT * FROM agendamentos;


-- ========================================
-- testes
-- ========================================

SELECT 
    u.id_usuario,
    u.nome AS usuario,
    p.nome AS perfil
FROM usuarios u
JOIN perfis p ON u.id_perfil = p.id_perfil;

SELECT
    m.id_medico,
    m.nome AS medico,
    e.nome AS especialidade
FROM medicos m
JOIN especialidades e ON m.id_especialidade = e.id_especialidade;

SELECT
    a.id_agendamento,
    p.nome AS paciente,
    m.nome AS medico,
    a.tipo,
    a.data_hora,
    a.status
FROM agendamentos a
JOIN pacientes p ON a.id_paciente = p.id_paciente
JOIN medicos m ON a.id_medico = m.id_medico
ORDER BY a.data_hora;

SELECT
    id_paciente,
    data_hora,
    COUNT(*) AS total
FROM agendamentos
GROUP BY id_paciente, data_hora
HAVING COUNT(*) > 1;

SELECT
    id_medico,
    COUNT(*) AS total_agendas
FROM agenda_medica
GROUP BY id_medico;

SELECT
    id_medico,
    COUNT(*) AS total_agendamentos
FROM agendamentos
GROUP BY id_medico;

SELECT
    DATE(data_hora) AS data_agendamento,
    COUNT(*) AS total
FROM agendamentos
GROUP BY DATE(data_hora)
ORDER BY data_agendamento;

SELECT
    m.nome AS medico,
    COUNT(a.id_agendamento) AS total_pacientes
FROM agendamentos a
JOIN medicos m ON a.id_medico = m.id_medico
GROUP BY m.nome
ORDER BY total_pacientes DESC;

SELECT
    e.nome AS especialidade,
    COUNT(a.id_agendamento) AS total_agendamentos
FROM agendamentos a
JOIN medicos m ON a.id_medico = m.id_medico
JOIN especialidades e ON m.id_especialidade = e.id_especialidade
GROUP BY e.nome
ORDER BY total_agendamentos DESC;

SELECT
    DATE(data_hora) AS data,
    COUNT(*) AS total
FROM agendamentos
GROUP BY DATE(data_hora)
ORDER BY data;


-- horarios ocupados
SELECT
    id_medico,
    DATE(data_hora) AS data,
    TIME(data_hora) AS horario
FROM agendamentos
ORDER BY id_medico, data_hora;

SELECT
    id_paciente,
    COUNT(*) AS total
FROM agendamentos
GROUP BY id_paciente
HAVING COUNT(*) > 1;


-- ocupados por especialidade
SELECT
    e.nome,
    COUNT(*) AS total
FROM agendamentos a
JOIN medicos m ON a.id_medico = m.id_medico
JOIN especialidades e ON m.id_especialidade = e.id_especialidade
GROUP BY e.nome;


SELECT
    COUNT(*) AS vagas_ocupadas
FROM agendamentos;


-- vagas livres
SELECT
    am.id_medico,
    am.data,
    am.hora_inicio,
    am.hora_fim
FROM agenda_medica am
LEFT JOIN agendamentos a 
    ON am.id_medico = a.id_medico 
    AND DATE(am.data) = DATE(a.data_hora)
WHERE a.id_agendamento IS NULL;

SELECT
    status,
    COUNT(*) AS total
FROM agendamentos
GROUP BY status;

-- vaga livre por medico+espec por horarios disponiveis

WITH RECURSIVE slots AS (
    SELECT
        am.id_agenda,
        am.id_medico,
        am.data,
        am.hora_inicio AS horario_slot,
        am.hora_fim
    FROM agenda_medica am

    UNION ALL

    SELECT
        s.id_agenda,
        s.id_medico,
        s.data,
        ADDTIME(s.horario_slot, '00:30:00') AS horario_slot,
        s.hora_fim
    FROM slots s
    WHERE ADDTIME(s.horario_slot, '00:30:00') <= s.hora_fim
)


SELECT
    m.nome AS medico,
    e.nome AS especialidade,
    s.data,
    s.horario_slot AS horario_livre
FROM slots s
JOIN medicos m ON s.id_medico = m.id_medico
JOIN especialidades e ON m.id_especialidade = e.id_especialidade
LEFT JOIN agendamentos a
    ON a.id_medico = s.id_medico
   AND DATE(a.data_hora) = s.data
   AND TIME(a.data_hora) = s.horario_slot
WHERE a.id_agendamento IS NULL
ORDER BY s.data, m.nome, s.horario_slot;

-- mais simples por turno
SELECT
    m.nome AS medico,
    e.nome AS especialidade,
    am.data,
    am.hora_inicio,
    am.hora_fim
FROM agenda_medica am
JOIN medicos m ON am.id_medico = m.id_medico
JOIN especialidades e ON m.id_especialidade = e.id_especialidade
LEFT JOIN agendamentos a
    ON a.id_medico = am.id_medico
   AND DATE(a.data_hora) = am.data
WHERE a.id_agendamento IS NULL
ORDER BY am.data, m.nome;
