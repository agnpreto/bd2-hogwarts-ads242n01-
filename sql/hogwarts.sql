-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Cauã da Silva Gomes
-- Matrícula: 2404119
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================================
CREATE DATABASE hogwarts;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa   INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador  VARCHAR(60),
    pontos    INT DEFAULT 0
);
-- Tabela professor
CREATE TABLE professor (
    id_prof          INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    salario          DECIMAL(10,2),
    data_contratacao DATE,
    id_casa          INT,
    CONSTRAINT ck_prof_salario CHECK (salario > 0),
    CONSTRAINT fk_prof_casa FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);
-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc    INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc  VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof    INT,
    CONSTRAINT ck_disc_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disc_prof FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);
-- Tabela aluno
CREATE TABLE aluno (
    id_aluno      INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    ano_escolar   INT,
    id_casa       INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT ck_aluno_ano   CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT ck_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa  FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);
-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc  INT,
    nota     DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT ck_mat_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_mat_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_mat_disc  FOREIGN KEY (id_disc)  REFERENCES disciplina(id_disc)
);
-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro   INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno      INT NOT NULL,
    id_prof       INT NOT NULL,
    pontos        INT NOT NULL,
    motivo        VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_reg_aluno FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    CONSTRAINT fk_reg_prof  FOREIGN KEY (id_prof)  REFERENCES professor(id_prof)
);
-- Tabela produto
CREATE TABLE produto (
    id_produto   INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja         VARCHAR(50) NOT NULL,
    preco        DECIMAL(10,2),
    estoque      INT DEFAULT 0,
    CONSTRAINT ck_prod_preco   CHECK (preco > 0),
    CONSTRAINT ck_prod_estoque CHECK (estoque >= 0)
);
-- Tabela compra
CREATE TABLE compra (
    id_compra    INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno     INT,
    id_produto   INT,
    quantidade   INT,
    valor_total  DECIMAL(10,2),
    data_compra  DATE NOT NULL,
    CONSTRAINT ck_compra_qtd CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno   FOREIGN KEY (id_aluno)   REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);
-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log    INT AUTO_INCREMENT PRIMARY KEY,
    tabela    VARCHAR(30),
    operacao  VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: A PK composta (id_aluno, id_disc) já garante que o mesmo aluno
-- não se matricule duas vezes na mesma disciplina. Com um id_matricula
-- auto_increment, o banco aceitaria a mesma dupla repetida (duplicada),
-- a não ser que criássemos um UNIQUE (id_aluno, id_disc) à parte.
 
-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),   -- 1
('Sonserina', 'Salazar Slytherin'),    -- 2
('Corvinal', 'Rowena Ravenclaw'),      -- 3
('Lufa-Lufa', 'Helga Hufflepuff');     -- 4
-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1), -- 1
('Severo Snape', 8800.00, '1981-09-01', 2),       -- 2
('Fílio Flitwick', 8200.00, '1974-09-01', 3),     -- 3
('Pomona Sprout', 7900.00, '1972-09-01', 4),      -- 4
('Rúbeo Hagrid', 4500.00, '1993-09-01', NULL),    -- 5
('Remo Lupin', 6200.00, '1993-09-01', NULL),      -- 6
('Sibila Trelawney', 5100.00, '1980-09-01', NULL),-- 7
('Gilderoy Lockhart', 7000.00, '1992-09-01', NULL),-- 8
('Horácio Slughorn', 8000.00, '1996-09-01', NULL);-- 9
-- INSERT disciplina
INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguração', 1, 1),                    -- 1
('Poções', 1, 2),                            -- 2
('Feitiços', 1, 3),                          -- 3
('Herbologia', 1, 4),                        -- 4
('Trato das Criaturas Mágicas', 3, 5),       -- 5
('Defesa Contra as Artes das Trevas', 1, 6), -- 6
('Adivinhação', 3, 7),                       -- 7
('Estudo dos Trouxas', 3, NULL),             -- 8
('Runas Antigas', 3, NULL);                  -- 9
-- INSERT aluno
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter', 5, 1, 120.00),       -- 1
('Hermione Granger', 5, 1, 85.00),    -- 2
('Rony Weasley', 5, 1, 12.00),        -- 3
('Neville Longbottom', 5, 1, 30.00),  -- 4
('Draco Malfoy', 5, 2, 500.00),       -- 5
('Pansy Parkinson', 5, 2, 150.00),    -- 6
('Vicente Crabbe', 5, 2, 40.00),      -- 7
('Luna Lovegood', 4, 3, 45.00),       -- 8
('Cho Chang', 6, 3, 200.00),          -- 9
('Padma Patil', 5, 3, 60.00),         -- 10
('Cedrico Diggory', 7, 4, 180.00),    -- 11
('Ana Abbott', 5, 4, 25.00),          -- 12
('Ernesto Macmillan', 5, 4, 70.00),   -- 13
('Teddy Lupin', 1, NULL, 0.00);       -- 14 (ainda não passou pelo Chapéu Seletor)
-- INSERT matricula
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
-- INSERT produto
INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),                 -- 1
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),   -- 2
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),                -- 3
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150), -- 4
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20), -- 5
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),        -- 6
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),          -- 7
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);         -- 8
-- Confira: 4, 9, 9, 14, 35, 8
SELECT (SELECT COUNT(*) FROM casa) AS casas,
       (SELECT COUNT(*) FROM professor) AS professores,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM aluno) AS alunos,
       (SELECT COUNT(*) FROM matricula) AS matriculas,
       (SELECT COUNT(*) FROM produto) AS produtos;

-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- 2.1 ALTER TABLE
-- Questão 2.1.1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Questão 2.1.2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questão 2.1.3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questão 2.1.4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Questão 2.1.5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- 2.2 UPDATE
-- Questão 2.2.6
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Questão 2.2.7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 2.2.8 (bônus do Lupin, nota máxima 10)
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc FROM disciplina
    WHERE id_prof = (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin')
);

-- Questão 2.2.9
UPDATE matricula
SET situacao = CASE WHEN nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;

-- Questão 2.2.10
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

-- Questão 2.2.11
UPDATE produto SET ativo = 'N' WHERE estoque = 0;

-- Questão 2.2.12
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';

-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- Erro: 1451 - Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: a Sonserina é "pai" de alunos e professor (FK id_casa). O banco não deixa
-- apagar um registro que ainda é usado por outras tabelas.
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';

-- Questão 14
-- Erro: 3819 - Check constraint 'ck_aluno_ano' is violated
-- Explicação: o CHECK só aceita ano_escolar entre 1 e 7, e o Dobby está no 8º.
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES ('Dobby', 8, 1, 0);

-- Questão 15
-- Erro: 1062 - Duplicate entry 'harry.potter@hogwarts.edu' for key 'uq_aluno_email'
-- Explicação: a restrição UNIQUE não deixa repetir e-mail.
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0, 'harry.potter@hogwarts.edu');

-- Questão 16
-- Erro: 1451 - Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: o Snape é professor da disciplina Poções (disciplina.id_prof aponta para ele).
-- DELETE FROM professor WHERE nome = 'Severo Snape';

-- Questão 17
-- Funciona porque nenhuma outra tabela referencia o Lockhart (ele não tem disciplina
-- nem registro de pontos). Sem filhos, a FK não é quebrada.
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Confira: 8 professores, 13 alunos, 8 disciplinas, 33 matrículas
SELECT (SELECT COUNT(*) FROM professor) AS professores,
       (SELECT COUNT(*) FROM aluno) AS alunos,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM matricula) AS matriculas;

-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
DELIMITER $$

-- Questão 20 - trg_pontos_casa
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$

-- Questão 21 - trg_valida_compra
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_saldo   DECIMAL(10,2);

    SELECT estoque, preco INTO v_estoque, v_preco
    FROM produto WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    ELSEIF v_saldo < v_preco * NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    ELSE
        SET NEW.valor_total = v_preco * NEW.quantidade;
    END IF;
END$$

-- Questão 22 - trg_baixa_compra
CREATE TRIGGER trg_baixa_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    UPDATE aluno
    SET saldo_galeoes = saldo_galeoes - NEW.valor_total
    WHERE id_aluno = NEW.id_aluno;
END$$

-- Questão 23 - trg_situacao_nota
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF OLD.nota <> NEW.nota THEN
        SET NEW.situacao = IF(NEW.nota >= 6, 'Aprovado', 'Reprovado');
    END IF;
END$$

-- Questão 24 - trg_audita_salario
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE',
                CONCAT(OLD.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END$$

DELIMITER ;

-- Pergunta: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: BEFORE roda ANTES de gravar, então pode bloquear a compra (SIGNAL) e
-- preencher o valor_total antes de salvar. AFTER roda só depois que a compra foi
-- gravada com sucesso; assim o estoque e o saldo só mudam se a compra for válida.

-- Confira: devem aparecer 5 triggers
SHOW TRIGGERS FROM hogwarts;

-- =====================================================================
-- 4.1 Testando os triggers
-- Questão 4.25
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3, 20, 'Feitiço de levitação perfeito', '2026-09-10'),
( 1, 2, -10, 'Atraso na aula de Poções', '2026-09-12'),
( 5, 2, 15, 'Poção do Morto-Vivo impecável', '2026-09-12'),
( 8, 5, 10, 'Cuidou de um testrálio ferido', '2026-09-20'),
(11, 4, 25, 'Ajudou os alunos do 1º ano', '2026-09-25'),
( 4, 4, 30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
( 6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
( 1, 6, 50, 'Conjurou um Patrono corpóreo', '2026-10-15'),
( 9, 3, 15, 'Duelo exemplar no Clube de Duelos', '2026-10-18'),
( 5, 1, -30, 'Duelo proibido no corredor', '2026-10-31'),
(10, 7, 5, 'Interpretação da bola de cristal', '2026-11-03'),
(13, 4, 10, 'Colheita de mandrágoras', '2026-11-05'),
( 3, 9, 10, 'Identificou um bezoar', '2026-11-06'),
( 8, 3, 20, 'Resposta brilhante sobre o Diadema', '2026-11-08'),
( 6, 2, 25, 'Antídoto para venenos comuns', '2026-11-09'),
( 5, 9, 40, 'Melhor poção do Clube do Slugue', '2026-11-09');

INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
( 5, 2, 1, '2026-09-01'),
( 2, 5, 2, '2026-09-02'),
( 1, 3, 10, '2026-09-03'),
( 3, 4, 5, '2026-09-03'),
( 9, 8, 1, '2026-09-15'),
( 8, 5, 1, '2026-09-20'),
(11, 1, 1, '2026-10-01'),
( 6, 3, 20, '2026-10-10'),
( 1, 7, 2, '2026-10-20'),
(13, 4, 10, '2026-11-02');

-- Teste 1: Rony (id 3) tenta comprar 1 Nimbus 2001 (id 2)
-- ERRO ESPERADO: 1644 - Galeões insuficientes no cofre do aluno
-- (o estoque tem 2, mas o Rony só tem 6 galeões e a vassoura custa 300)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-10');

-- Teste 2: Hermione (id 2) tenta comprar 1 Caldeirão de Estanho (id 6)
-- ERRO ESPERADO: 1644 - Estoque insuficiente no Beco Diagonal
-- (o estoque do caldeirão é 0)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-10');

-- Teste 3: recuperação do Rony em Poções (id_disc 2), sem mexer em situacao
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
SELECT id_aluno, id_disc, nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;
-- Resultado: situacao virou 'Aprovado' sozinha (trigger trg_situacao_nota).

-- Teste 4: salário e data do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Resultado: 1 linha. O 1º UPDATE mudou o salário (trigger gravou); o 2º só mudou a data,
-- então OLD.salario = NEW.salario e o trigger não gravou nada.
-- O reajuste da questão 10 não aparece porque foi feito ANTES de o trigger existir.

-- Confira: placar 100/50/35/30, Draco 200, Harry 54, Nimbus 2, Sapo 170, soma 474, log 1 linha
SELECT nome_casa, pontos FROM casa;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno IN (1, 5);
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) AS soma_compras FROM compra;

