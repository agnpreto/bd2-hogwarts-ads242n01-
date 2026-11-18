-- =============================================================================
-- SEÇÃO 1 e 1.1: DDL (Criação do Banco e 10 Tabelas) e Carga Inicial (INSERT)
-- =============================================================================

DROP DATABASE IF EXISTS hogwarts_db;
CREATE DATABASE hogwarts_db;
\c hogwarts_db;

-- 1. Tabela Casa
CREATE TABLE Casa (
    id_casa SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    fundador VARCHAR(100) NOT NULL,
    pontos INT DEFAULT 0
);

-- 2. Tabela Aluno
CREATE TABLE Aluno (
    id_aluno SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano INT CHECK (ano BETWEEN 1 AND 7),
    id_casa INT REFERENCES Casa(id_casa),
    situacao VARCHAR(30) DEFAULT 'Ativo'
);

-- 3. Tabela Professor
CREATE TABLE Professor (
    id_professor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100)
);

-- 4. Tabela Disciplina
CREATE TABLE Disciplina (
    id_disciplina SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    id_professor INT REFERENCES Professor(id_professor)
);

-- 5. Tabela Matricula
CREATE TABLE Matricula (
    id_aluno INT REFERENCES Aluno(id_aluno),
    id_disciplina INT REFERENCES Disciplina(id_disciplina),
    PRIMARY KEY (id_aluno, id_disciplina)
);

-- 6. Tabela Pocoes / Ingredientes
CREATE TABLE Pocao (
    id_pocao SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    efeito TEXT,
    preco NUMERIC(10,2)
);

-- 7. Tabela Estoque / Ingrediente
CREATE TABLE Ingrediente (
    id_ingrediente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade INT CHECK (quantidade >= 0)
);

-- 8. Tabela Venda / Transação
CREATE TABLE Venda (
    id_venda SERIAL PRIMARY KEY,
    id_aluno INT REFERENCES Aluno(id_aluno),
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_total NUMERIC(10,2)
);

-- 9. Tabela Auditoria
CREATE TABLE Auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    tabela_afetada VARCHAR(50),
    operacao VARCHAR(20),
    usuario VARCHAR(50),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Tabela Taça das Casas (Histórico/Log de Pontos)
CREATE TABLE TacaCasas_Log (
    id_log SERIAL PRIMARY KEY,
    id_casa INT REFERENCES Casa(id_casa),
    pontos_alteracao INT,
    motivo TEXT,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Carga Inicial (INSERTs) de Exemplo
INSERT INTO Casa (nome, fundador, pontos) VALUES 
('Grifinória', 'Godric Gryffindor', 150),
('Sonserina', 'Salazar Slytherin', 140),
('Corvinal', 'Rowena Ravenclaw', 130),
('Lufa-Lufa', 'Helga Hufflepuff', 120);

INSERT INTO Aluno (nome, ano, id_casa, situacao) VALUES 
('Harry Potter', 5, 1, 'Ativo'),
('Draco Malfoy', 5, 2, 'Ativo'),
('Luna Lovegood', 4, 3, 'Ativo'),
('Cedrico Diggory', 6, 4, 'Ativo');

-- =============================================================================
-- SEÇÃO 2: ALTER TABLE e UPDATE (CONCAT, LEAST, CASE, subconsulta com IN)
-- Questões 1 a 12
-- =============================================================================

-- Exemplo ALTER TABLE
ALTER TABLE Aluno ADD COLUMN email VARCHAR(100);

-- Exemplo UPDATE utilizando CONCAT, CASE e subconsulta com IN
UPDATE Aluno 
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu')
WHERE id_casa IN (SELECT id_casa FROM Casa WHERE nome = 'Grifinória');

-- Exemplo usando LEAST ou regras condicionais (CASE)
UPDATE Aluno 
SET ano = LEAST(ano + 1, 7);


-- =============================================================================
-- SEÇÃO 3: DELETE e Testes de Restrições (FK, CHECK, UNIQUE)
-- Questões 13 a 19
-- =============================================================================

-- Teste de restrição de integridade referencial (FK) e CHECK
-- Tentativa de remoção restrita por FK ou testes de validação de exclusão
DELETE FROM Aluno WHERE id_aluno = 999; -- Aluno inexistente / teste de restrição

-- =============================================================================
-- SEÇÃO 4: Triggers (Taça das Casas, Validação, Baixa de Estoque, Auditoria)
-- Questões 20 a 25
-- =============================================================================

CREATE OR REPLACE FUNCTION func_auditoria_geral()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Auditoria (tabela_afetada, operacao, usuario)
    VALUES (TG_TABLE_NAME, TG_OP, current_user);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_aluno
AFTER INSERT OR UPDATE OR DELETE ON Aluno
FOR EACH ROW EXECUTE FUNCTION func_auditoria_geral();


-- =============================================================================
-- SEÇÃO 5: TCL (COMMIT, ROLLBACK, SAVEPOINT, autocommit)
-- Questões 26 a 30
-- =============================================================================

BEGIN;
SAVEPOINT sp_inicio;
UPDATE Casa SET pontos = pontos + 10 WHERE nome = 'Grifinória';
-- ROLLBACK TO SAVEPOINT sp_inicio;
COMMIT;