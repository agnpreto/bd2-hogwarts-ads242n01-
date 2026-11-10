-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Giovane Lucas Fonseca Dias
-- Matrícula: 2418010
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================================
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

-- Tabela professor
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) CHECK (salario > 0),
    data_contratacao DATE,
    id_casa INT,
    FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT CHECK (ano_minimo BETWEEN 1 AND 7),
    id_prof INT,
    FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT CHECK (ano_escolar BETWEEN 1 AND 7),
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0 CHECK (saldo_galeoes >= 0),
    FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (id_aluno, id_disc),
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_disc) REFERENCES disciplina(id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) CHECK (preco > 0),
    estoque INT DEFAULT 0 CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_produto INT,
    quantidade INT CHECK (quantidade > 0),
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: A chave composta (id_aluno, id_disc) garante que um mesmo aluno não seja
-- matriculado duas vezes na mesma disciplina. Se tivesse um id_matricula auto_increment
-- (sem uma restrição UNIQUE no par), o banco permitiria matrículas duplicadas para o mesmo aluno e matéria.


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),
('Sonserina', 'Salazar Slytherin'),
('Corvinal', 'Rowena Ravenclaw'),
('Lufa-Lufa', 'Helga Hufflepuff');

-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),
('Severo Snape', 8800.00, '1981-09-01', 2),
('Filio Flitwick', 8200.00, '1974-09-01', 3),
('Pomona Sprout', 7900.00, '1972-09-01', 4),
('Rúbeo Hagrid', 4500.00, '1993-09-01', NULL),
('Remo Lupin', 6200.00, '1993-09-01', NULL),
('Sibila Trelawney', 5100.00, '1980-09-01', NULL),
('Gilderoy Lockhart', 7000.00, '1992-09-01', NULL),
('Horácio Slughorn', 8000.00, '1996-09-01', NULL);

-- INSERT disciplina
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

-- INSERT aluno
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter', 5, 1, 120.00),
('Hermione Granger', 5, 1, 85.00),
('Rony Weasley', 5, 1, 12.00),
('Neville Longbottom', 5, 1, 30.00),
('Draco Malfoy', 5, 2, 500.00),
('Pansy Parkinson', 5, 2, 150.00),
('Vicente Crabbe', 5, 2, 40.00),
('Luna Lovegood', 4, 3, 45.00),
('Cho Chang', 6, 3, 200.00),
('Padma Patil', 5, 3, 60.00),
('Cedrico Diggory', 7, 4, 180.00),
('Ana Abbott', 5, 4, 25.00),
('Ernesto Macmillan', 5, 4, 70.00),
('Teddy Lupin', 1, NULL, 0.00);

-- INSERT matricula
INSERT INTO matricula (id_aluno, id_disc, nota) VALUES
(1,1,7.5), (1,2,5.0), (1,6,9.8), (1,5,8.0),
(2,1,10.0), (2,2,9.5), (2,3,10.0), (2,5,9.0), (2,9,9.5),
(3,1,6.0), (3,2,4.5), (3,7,5.5),
(4,2,3.0), (4,4,10.0), (4,6,7.0),
(5,2,9.0), (5,1,7.0), (5,5,4.0),
(6,2,7.5), (6,7,6.5),
(7,2,3.5), (7,6,2.0),
(8,5,8.5), (8,3,8.0), (8,4,9.0),
(9,3,8.5), (9,6,7.5),
(10,3,9.0), (10,7,6.0),
(11,4,8.5), (11,6,9.0), (11,1,8.0),
(12,4,8.0),
(13,4,7.0), (13,3,7.5);

-- INSERT produto
INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20),
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);

-- Confira: SELECT COUNT(*) de cada tabela
SELECT 
    (SELECT COUNT(*) FROM casa) AS casas,
    (SELECT COUNT(*) FROM professor) AS professores,
    (SELECT COUNT(*) FROM disciplina) AS disciplinas,
    (SELECT COUNT(*) FROM aluno) AS alunos,
    (SELECT COUNT(*) FROM matricula) AS matriculas,
    (SELECT COUNT(*) FROM produto) AS produtos;


-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Questão 2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questão 3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questão 4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Questão 5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- Questão 6
UPDATE aluno 
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula 
SET nota = LEAST(nota + 0.5, 10.00)
WHERE id_disc IN (
    SELECT id_disc 
    FROM disciplina 
    WHERE id_prof = (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin')
);

-- Questão 9
UPDATE matricula 
SET situacao = CASE 
    WHEN nota >= 6 THEN 'Aprovado' 
    ELSE 'Reprovado' 
END;

-- Questão 10
UPDATE professor 
SET salario = salario * 1.10 
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';

-- Questão 11
UPDATE produto 
SET ativo = 'N' 
WHERE estoque = 0;

-- Questão 12
UPDATE produto 
SET preco = preco * 0.80 
WHERE loja = 'Dedosdemel';

-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: A casa 'Sonserina' está sendo referenciada por registros nas tabelas 'professor' e 'aluno'. O banco bloqueia a exclusão para manter a integridade referencial da chave estrangeira (FK).

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro: Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: A tabela 'aluno' possui uma restrição CHECK que permite apenas valores entre 1 e 7 para a coluna 'ano_escolar'. O valor 8 viola essa regra.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: A coluna 'email' possui a restrição UNIQUE (uq_aluno_email) criada na questão 7. Como esse e-mail já pertence ao aluno Harry Potter, o banco impede a duplicidade.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: O professor Severo Snape está vinculado à disciplina 'Poções' na tabela 'disciplina' (FK id_prof), impedindo sua exclusão direta.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Explicação: Este comando funciona porque Gilderoy Lockhart não possui vínculos (chaves estrangeiras) em nenhuma outra tabela (não ministra disciplinas e não tem registros de pontos), ao contrário de Severo Snape.

-- Questão 18
DELETE FROM matricula 
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno 
WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina 
WHERE id_disc NOT IN (SELECT DISTINCT id_disc FROM matricula);

SELECT 
    (SELECT COUNT(*) FROM professor) AS professores,
    (SELECT COUNT(*) FROM aluno) AS alunos,
    (SELECT COUNT(*) FROM disciplina) AS disciplinas,
    (SELECT COUNT(*) FROM matricula) AS matriculas;

-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$
DELIMITER ;

-- Questão 21 - trg_valida_compra
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo DECIMAL(10,2);

    SELECT preco, estoque INTO v_preco, v_estoque
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$
DELIMITER ;

-- Questão 22 - trg_baixa_compra
DELIMITER $$
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
DELIMITER ;

-- Questão 23 - trg_situacao_nota
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota <> OLD.nota THEN
        IF NEW.nota >= 6 THEN
            SET NEW.situacao = 'Aprovado';
        ELSE
            SET NEW.situacao = 'Reprovado';
        END IF;
    END IF;
END$$
DELIMITER ;

-- Questão 24 - trg_audita_salario
DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario)
        );
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: A validação precisa ser BEFORE INSERT para poder barrar a operação com SIGNAL antes que ela seja gravada no banco e também para conseguir preencher o valor de NEW.valor_total. A baixa precisa ser AFTER INSERT para garantir que a compra passou por todas as validações e foi efetivamente gravada antes de descontar o estoque e o saldo.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
(2, 3, 20, 'Feitiço de levitação perfeito', '2026-09-10'),
(1, 2, -10, 'Atraso na aula de Poções', '2026-09-12'),
(5, 2, 15, 'Poção do Morto-Vivo impecável', '2026-09-12'),
(8, 5, 10, 'Cuidou de um testrálio ferido', '2026-09-20'),
(11, 4, 25, 'Ajudou os alunos do 1º ano', '2026-09-25'),
(4, 4, 30, 'Identificou uma Mimbulus mimbletonia', '2026-10-02'),
(6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
(1, 6, 50, 'Conjurou um Patrono corpóreo', '2026-10-15'),
(9, 3, 15, 'Duelo exemplar no Clube de Duelos', '2026-10-18'),
(5, 1, -30, 'Duelo proibido no corredor', '2026-10-31'),
(10, 7, 5, 'Interpretação da bola de cristal', '2026-11-03'),
(13, 4, 10, 'Colheita de mandrágoras', '2026-11-05'),
(3, 9, 10, 'Identificou um bezoar', '2026-11-06'),
(8, 3, 20, 'Resposta brilhante sobre o Diadema', '2026-11-08'),
(6, 2, 25, 'Antídoto para venenos comuns', '2026-11-09'),
(5, 9, 40, 'Melhor poção do Clube do Slugue', '2026-11-09');

-- Questão 25 - INSERT compra
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
(5, 2, 1, '2026-09-01'),
(2, 5, 2, '2026-09-02'),
(1, 3, 10, '2026-09-03'),
(3, 4, 5, '2026-09-03'),
(9, 8, 1, '2026-09-15'),
(8, 5, 1, '2026-09-20'),
(11, 1, 1, '2026-10-01'),
(6, 3, 20, '2026-10-10'),
(1, 7, 2, '2026-10-20'),
(13, 4, 10, '2026-11-02');

-- Questão 25 - Rony tenta comprar a Nimbus
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-05');
-- Resultado: Error Code: 1644. Galeões insuficientes no cofre do aluno. O trigger trg_valida_compra bloqueou a compra porque o saldo de Rony é menor que 300.00 galeões.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-05');
-- Resultado: Error Code: 1644. Estoque insuficiente no Beco Diagonal. O trigger trg_valida_compra bloqueou a compra porque o estoque do Caldeirão de Estanho é 0.

-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
-- Linhas em log_auditoria: 1 linha (apenas a alteração de salário gerou registro; a alteração de data_admissao não disparou o INSERT no log porque o salário não mudou).
-- Por que o reajuste da questão 10 não aparece: Porque na questão 10 o trigger trg_audita_salario ainda não havia sido criado.


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

