-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: John Erik de Araujo Santos
-- Matrícula: 2422168
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================================
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    data_contratacao DATE,
    id_casa INT,
    CONSTRAINT chk_prof_salario CHECK (salario > 0),
    CONSTRAINT fk_prof_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof INT,
    CONSTRAINT chk_disc_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disc_prof FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT,
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT chk_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT chk_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT chk_mat_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_mat_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_mat_disc FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
);

CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_rp_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_rp_prof FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,
    CONSTRAINT chk_prod_preco CHECK (preco > 0),
    CONSTRAINT chk_prod_estoque CHECK (estoque >= 0)
);

CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_produto INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT chk_compra_qtd CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: Porque a combinação (id_aluno, id_disc) identifica unicamente
-- uma matrícula — um aluno só pode ter uma nota por disciplina. Um id
-- próprio permitiria duas linhas para o mesmo par aluno/disciplina,
-- gerando notas duplicadas e conflito no boletim.

-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),
('Sonserina', 'Salazar Slytherin'),
('Corvinal',  'Rowena Ravenclaw'),
('Lufa-Lufa', 'Helga Hufflepuff');

INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),
('Severo Snape',       8800.00, '1981-09-01', 2),
('Fílio Flitwick',     8200.00, '1974-09-01', 3),
('Pomona Sprout',      7900.00, '1972-09-01', 4),
('Rúbeo Hagrid',       4500.00, '1993-09-01', NULL),
('Remo Lupin',         6200.00, '1993-09-01', NULL),
('Sibila Trelawney',   5100.00, '1980-09-01', NULL),
('Gilderoy Lockhart',  7000.00, '1992-09-01', NULL),
('Horácio Slughorn',   8000.00, '1996-09-01', NULL);

INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguração', 1, 1),
('Poções', 1, 2),
('Feitiços', 1, 3),
('Herbologia', 1, 4),
('Trato das Criaturas Mágicas', 3, 5),
('Defesa Contra as Artes das Trevas', 1, 6),
('Adivinhação', 3, 7),
('Estudo dos Trouxas', 3, NULL),
('Runas Antigas', 3, NULL);

INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter',  5, 1, 120.00),
('Hermione Granger', 5, 1, 85.00),
('Rony Weasley',  5, 1, 12.00),
('Neville Longbottom', 5, 1, 30.00),
('Draco Malfoy',  5, 2, 500.00),
('Pansy Parkinson', 5, 2, 150.00),
('Vicente Crabbe', 5, 2, 40.00),
('Luna Lovegood',  4, 3, 45.00),
('Cho Chang',  6, 3, 200.00),
('Padma Patil',  5, 3, 60.00),
('Cedrico Diggory', 7, 4, 180.00),
('Ana Abbott',  5, 4, 25.00),
('Ernesto Macmillan', 5, 4, 70.00),
('Teddy Lupin',  1, NULL, 0.00);

INSERT INTO matricula (id_aluno, id_disc, nota) VALUES
(1,1,7.5),(1,2,5.0),(1,6,9.8),(1,5,8.0),
(2,1,10.0),(2,2,9.5),(2,3,10.0),(2,5,9.0),(2,9,9.5),
(3,1,6.0),(3,2,4.5),(3,7,5.5),
(4,2,3.0),(4,4,10.0),(4,6,7.0),
(5,2,9.0),(5,1,7.0),(5,5,4.0),
(6,2,7.5),(6,7,6.5),
(7,2,3.5),(7,6,2.0),
(8,5,8.5),(8,3,8.0),(8,4,9.0),
(9,3,8.5),(9,6,7.5),
(10,3,9.0),(10,7,6.0),
(11,4,8.5),(11,6,9.0),(11,1,8.0),
(12,4,8.0),
(13,4,7.0),(13,3,7.5);

INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20),
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);

-- Confira: 4 casas, 9 professores, 9 disciplinas, 14 alunos, 35 matrículas, 8 produtos
SELECT
  (SELECT COUNT(*) FROM casa)      AS casas,
  (SELECT COUNT(*) FROM professor) AS professores,
  (SELECT COUNT(*) FROM disciplina) AS disciplinas,
  (SELECT COUNT(*) FROM aluno)     AS alunos,
  (SELECT COUNT(*) FROM matricula) AS matriculas,
  (SELECT COUNT(*) FROM produto)   AS produtos;


-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- 2.1 ALTERAÇÕES DE ESTRUTURA

-- Questão 1: adiciona email em aluno
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Questão 2: adiciona situacao em matricula
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questão 3: adiciona ativo em produto
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questão 4: aumenta fundador para VARCHAR(100)
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Questão 5: renomeia data_contratacao -> data_admissao
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- 2.2 ATUALIZAÇÕES DE DADOS

-- Questão 6: preenche e-mail de todos os alunos
UPDATE aluno
SET email = CONCAT(
    LOWER(REPLACE(SUBSTRING_INDEX(nome, ' ', 1), ' ', '.')),
    '.',
    LOWER(REPLACE(SUBSTRING_INDEX(nome, ' ', -1), ' ', '.')),
    '@hogwarts.edu'
);

-- Questão 7: adiciona UNIQUE em email
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8: bônus de 0.5 na nota da disciplina do Lupin (id_prof = 6), limitado a 10
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (SELECT id_disc FROM disciplina WHERE id_prof = 6);

-- Questão 9: situacao conforme nota
UPDATE matricula
SET situacao = CASE WHEN nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;

-- Questão 10: reajuste 10% para diretores de casa admitidos antes de 1980
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

-- Questão 11: produtos com estoque zerado ficam inativos
UPDATE produto SET ativo = 'N' WHERE estoque = 0;

-- Questão 12: promoção Dedosdemel -20%
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- Erro:
-- Explicação:

-- Questão 14
-- Erro:
-- Explicação:

-- Questão 15
-- Erro:
-- Explicação:

-- Questão 16
-- Erro:
-- Explicação:

-- Questão 17

-- Questão 18

-- Questão 19


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa

-- Questão 21 - trg_valida_compra

-- Questão 22 - trg_baixa_compra

-- Questão 23 - trg_situacao_nota

-- Questão 24 - trg_audita_salario

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta:

-- Questão 25 - INSERT registro_pontos

-- Questão 25 - INSERT compra

-- Questão 25 - Rony tenta comprar a Nimbus
-- Resultado:

-- Questão 25 - Hermione tenta comprar o caldeirão
-- Resultado:

-- Questão 25 - Recuperação do Rony em Poções

-- Questão 25 - Salário e data de admissão do Hagrid
-- Linhas em log_auditoria:
-- Por que o reajuste da questão 10 não aparece:


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26

-- Questão 27

-- Questão 28

-- Questão 29

-- Questão 30
-- Resposta:


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------
-- 6.1

-- 6.2

-- 6.3

-- 6.4

-- 6.5

-- 6.6

-- ---------- Nível 2: JOINs ----------
-- 6.7
-- Quantos alunos e por quê:

-- 6.8

-- 6.9

-- 6.10

-- 6.11

-- ---------- Nível 3: agrupamento e agregação ----------
-- 6.12

-- 6.13

-- 6.14

-- 6.15

-- 6.16

-- ---------- Nível 4: subconsultas ----------
-- 6.17

-- 6.18

-- 6.19

-- 6.20

-- 6.21
-- > ANY equivale a:

-- 6.22

-- 6.23

-- 6.24

-- ---------- Nível 5: UNION ALL ----------
-- 6.25

-- 6.26
-- Linhas com UNION ALL:
-- Linhas com UNION:
-- Explicação:

-- 6.27


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31

-- Questão 32

-- Questão 33

-- Questão 34

-- Questão 35

-- Questão 36

-- Questão 37
-- O que mudou e por quê:

-- Questão 38


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39

-- Questão 40

-- Questão 41

-- Questão 42

-- Questão 43

-- Questão 44
-- Resultado de cada comando:

-- Questão 45
-- Como o trigger conseguiu atualizar a casa:

-- Questão 46

-- Questão 47
-- Vantagem dos papéis:

-- Questão 48
