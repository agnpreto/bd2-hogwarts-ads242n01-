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

-- =====================================================
-- 5. TRANSAÇÕES (TCL) - BANCO GRINGOTES
-- =====================================================
-- Questão 5.26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');

-- Questão 5.27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;   -- tudo zerado
ROLLBACK;
SELECT nome_casa, pontos FROM casa;   -- placar voltou ao normal

-- Questão 5.28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;       -- 47.00
SELECT estoque FROM produto WHERE id_produto = 1;         -- 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;       -- 54.00
SELECT estoque FROM produto WHERE id_produto = 1;         -- 9
-- O que aconteceu: as alterações feitas pelo trigger (saldo e estoque) fazem parte da
-- mesma transação, então o ROLLBACK desfez tudo, inclusive o que o trigger fez.

-- Questão 5.29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

SELECT nome_casa, pontos FROM casa;
SELECT COUNT(*) AS linhas_registro_pontos FROM registro_pontos;   -- 17

-- Questão 5.30
SELECT @@autocommit;
-- Retorna 1 = autocommit LIGADO: cada comando é confirmado (COMMIT) sozinho,
-- a não ser que você abra uma transação com START TRANSACTION.
-- CREATE TABLE no meio de uma transação aberta faz COMMIT implícito: a transação é
-- confirmada automaticamente (comandos DDL não podem ser desfeitos com ROLLBACK).

-- =====================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================
-- Nível 1
-- Questão 6.1
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;

-- Questão 6.2
SELECT a.nome, a.ano_escolar
FROM aluno a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar;

-- Questão 6.3
SELECT a.nome
FROM aluno a
WHERE a.nome LIKE '_a%';

-- Questão 6.4
SELECT d.nome_disc
FROM disciplina d
WHERE d.id_prof IS NULL;

-- Questão 6.5
SELECT p.nome_produto, p.preco
FROM produto p
WHERE p.preco NOT BETWEEN 5 AND 20
ORDER BY p.preco;

-- Questão 6.6
SELECT DISTINCT p.loja
FROM produto p
ORDER BY p.loja;

-- Nível 2
-- Questão 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- Aparecem 12 alunos, e não 13: o Teddy Lupin não tem casa (id_casa NULL).
-- O INNER JOIN só traz quem tem par nas duas tabelas.

-- Questão 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- Questão 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- Questão 6.10
SELECT a.nome AS aluno,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM aluno a
JOIN casa c       ON c.id_casa = a.id_casa
JOIN matricula m  ON m.id_aluno = a.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- Questão 6.11
SELECT c.id_compra AS numero_compra,
       a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       c.quantidade,
       c.valor_total,
       c.data_compra
FROM compra c
JOIN aluno a   ON a.id_aluno = c.id_aluno
JOIN produto p ON p.id_produto = c.id_produto
ORDER BY c.data_compra, c.id_compra;

-- Nível 3
-- Questão 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS qtd_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- Questão 6.13
SELECT c.nome_casa AS casa,
       COUNT(*) AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       SUM(r.pontos) AS saldo
FROM registro_pontos r
JOIN aluno a ON a.id_aluno = r.id_aluno
JOIN casa c  ON c.id_casa = a.id_casa
GROUP BY c.id_casa, c.nome_casa;

-- Questão 6.14
SELECT p.loja,
       COUNT(*) AS qtd_compras,
       SUM(c.valor_total) AS faturamento
FROM compra c
JOIN produto p ON p.id_produto = c.id_produto
GROUP BY p.loja
HAVING SUM(c.valor_total) > 20
ORDER BY faturamento DESC;

-- Questão 6.15
SELECT MONTH(r.data_registro) AS mes,
       COUNT(*) AS qtd_registros,
       SUM(r.pontos) AS total_pontos
FROM registro_pontos r
GROUP BY MONTH(r.data_registro)
ORDER BY mes;

-- Questão 6.16
SELECT p.nome AS professor,
       COUNT(*) AS qtd_registros,
       SUM(r.pontos) AS total_concedido
FROM registro_pontos r
JOIN professor p ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
ORDER BY total_concedido DESC;

-- Nível 4
-- Questão 6.17
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (
    SELECT c.id_aluno FROM compra c
    WHERE c.id_produto IN (
        SELECT p.id_produto FROM produto p WHERE p.loja = 'Dedosdemel'
    )
);

-- Questão 6.18
SELECT p.nome_produto, p.estoque
FROM produto p
WHERE p.id_produto NOT IN (SELECT c.id_produto FROM compra c);

-- Questão 6.19
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- Questão 6.20
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario > ALL (
    SELECT p2.salario FROM professor p2 WHERE p2.id_casa IS NULL
);

-- Questão 6.21
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  AND a.saldo_galeoes > ANY (
      SELECT a2.saldo_galeoes FROM aluno a2
      WHERE a2.id_casa = (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  );
-- > ANY equivale a comparar com o MENOR valor da subconsulta (basta ser maior que
-- pelo menos um). Já > ALL compara com o MAIOR valor.

-- Questão 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    JOIN matricula m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa AND m.nota = 10
);

-- Questão 6.23
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1 FROM compra c WHERE c.id_aluno = a.id_aluno
);

-- Questão 6.24
SELECT c.nome_casa AS casa,
       ROUND(AVG(t.media_aluno), 2) AS media_da_casa
FROM (
    SELECT m.id_aluno, AVG(m.nota) AS media_aluno
    FROM matricula m
    GROUP BY m.id_aluno
) t
JOIN aluno a ON a.id_aluno = t.id_aluno
JOIN casa c  ON c.id_casa = a.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- Nível 5
-- Questão 6.25
SELECT a.nome, 'Aluno' AS vinculo FROM aluno a
UNION ALL
SELECT p.nome, 'Professor' AS vinculo FROM professor p
ORDER BY nome;

-- Questão 6.26 (primeiro UNION ALL: 27 linhas)
SELECT a.nome
FROM compra c JOIN aluno a ON a.id_aluno = c.id_aluno
UNION ALL
SELECT a.nome
FROM registro_pontos r JOIN aluno a ON a.id_aluno = r.id_aluno;

-- Depois UNION: 12 linhas
SELECT a.nome
FROM compra c JOIN aluno a ON a.id_aluno = c.id_aluno
UNION
SELECT a.nome
FROM registro_pontos r JOIN aluno a ON a.id_aluno = r.id_aluno;
-- Diferença: UNION ALL junta tudo e mantém as repetições (27 linhas).
-- UNION remove linhas repetidas (12 nomes diferentes), por isso é um pouco mais lento.

-- Questão 6.27
SELECT 'Total de pontos distribuídos' AS indicador, SUM(pontos) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;

-- =====================================================
-- 7. VIEWS
-- =====================================================
-- Questão 7.31
CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 7.32
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula m
JOIN aluno a       ON a.id_aluno = m.id_aluno
LEFT JOIN casa c   ON c.id_casa = a.id_casa
JOIN disciplina d  ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questão 7.33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       c.quantidade,
       c.valor_total,
       c.data_compra
FROM compra c
JOIN aluno a   ON a.id_aluno = c.id_aluno
JOIN produto p ON p.id_produto = c.id_produto;

-- Questão 7.34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno a
JOIN casa c      ON c.id_casa = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 7.35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE((SELECT c.nome_casa FROM casa c WHERE c.id_casa = p.id_casa),
                'Não é diretor') AS casa_dirigida,
       (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
       COALESCE((SELECT SUM(r.pontos) FROM registro_pontos r WHERE r.id_prof = p.id_prof),
                0) AS total_pontos_concedidos
FROM professor p;

-- Questão 7.36
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja;

SELECT * FROM vw_alunos_destaque ORDER BY media DESC;

SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Questão 7.37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');
SELECT * FROM vw_placar_casas;
-- Mudou: a Lufa-Lufa passou de 50 para 70 pontos. A view não guarda dados, ela só
-- guarda a consulta; cada vez que é usada, roda de novo sobre a tabela casa, que o
-- trigger já tinha atualizado.

-- Questão 7.38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;

-- =====================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================
-- Questão 8.39
CREATE USER 'filch'@'localhost'       IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost'  IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost'  IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 8.40
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 8.41
GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim TO 'mcgonagall'@'localhost';

-- Questão 8.42
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Questão 8.43
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 8.44 (rodar em uma conexão nova, logado como filch)
-- SELECT * FROM hogwarts.vw_placar_casas;   -- funciona
-- SELECT * FROM hogwarts.aluno;             -- ERRO 1142: SELECT command denied to user 'filch'
--                                           -- (ele só tem permissão na view, não na tabela)

-- Questão 8.45 (rodar logado como mcgonagall)
-- a) INSERT INTO hogwarts.registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
--    VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- b) UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;   -- ERRO 1142: UPDATE command denied
-- Como o trigger conseguiu? Triggers rodam com os privilégios do DEFINER (quem criou o
-- trigger, aqui o usuário admin), e não com os de quem disparou o INSERT. Por isso o
-- UPDATE em casa funciona dentro do trigger, mesmo a McGonagall não tendo esse privilégio.

-- Questão 8.46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 8.47
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';
CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Vantagem do papel: as permissões ficam em um lugar só. Se mudar a regra, altera o
-- papel uma vez e vale para todos os monitores; para um monitor novo, basta atribuir o papel.

-- Questão 8.48
DROP USER 'filch'@'localhost', 'mcgonagall'@'localhost', 'dumbledore'@'localhost', 'percy'@'localhost';
DROP ROLE 'monitor';
