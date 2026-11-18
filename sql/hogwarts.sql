-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno:Guilherme Manoel Bezerra Santos
-- Matrícula:2387020
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
    id_casa INT AUTO_INCREMENT,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0,

    PRIMARY KEY (id_casa)
);

-- Tabela professor
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    data_contratacao DATE,
    id_casa INT,

    PRIMARY KEY (id_prof),

    CONSTRAINT chk_salario
        CHECK (salario > 0),

    CONSTRAINT fk_professor_casa
        FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);


-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof INT,

    PRIMARY KEY (id_disc),

    CONSTRAINT chk_ano_minimo
        CHECK (ano_minimo BETWEEN 1 AND 7),

    CONSTRAINT fk_disciplina_professor
        FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);


-- Tabela aluno
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT,
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,

    PRIMARY KEY (id_aluno),

    CONSTRAINT chk_ano_escolar
        CHECK (ano_escolar BETWEEN 1 AND 7),

    CONSTRAINT chk_saldo_galeoes
        CHECK (saldo_galeoes >= 0),

    CONSTRAINT fk_aluno_casa
        FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);


-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2),

    PRIMARY KEY (id_aluno, id_disc),

    CONSTRAINT chk_nota
        CHECK (nota BETWEEN 0 AND 10),

    CONSTRAINT fk_matricula_aluno
        FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),

    CONSTRAINT fk_matricula_disciplina
        FOREIGN KEY (id_disc)
        REFERENCES disciplina(id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,

    PRIMARY KEY (id_registro),

    CONSTRAINT fk_registro_aluno
        FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),

    CONSTRAINT fk_registro_professor
        FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);
-- Tabela produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,

    PRIMARY KEY (id_produto),

    CONSTRAINT chk_preco
        CHECK (preco > 0),

    CONSTRAINT chk_estoque
        CHECK (estoque >= 0)
);
-- Tabela compra
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT,
    id_aluno INT,
    id_produto INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,

    PRIMARY KEY (id_compra),

    CONSTRAINT chk_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT fk_compra_aluno
        FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),

    CONSTRAINT fk_compra_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto)
);


-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_log)
);
-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta:porque sim


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
USE hogwarts;
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),
('Sonserina', 'Salazar Slytherin'),
('Corvinal', 'Rowena Ravenclaw'),
('Lufa-Lufa', 'Helga Hufflepuff');
-- INSERT professor
INSERT INTO professor
(nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),
('Severo Snape', 8800.00, '1981-09-01', 2),
('Fílio Flitwick', 8200.00, '1974-09-01', 3),
('Pomona Sprout', 7900.00, '1972-09-01', 4),
('Rúbeo Hagrid', 4500.00, '1993-09-01', NULL),
('Remo Lupin', 6200.00, '1993-09-01', NULL),
('Sibila Trelawney', 5100.00, '1980-09-01', NULL),
('Gilderoy Lockhart', 7000.00, '1992-09-01', NULL),
('Horácio Slughorn', 8000.00, '1996-09-01', NULL);
-- INSERT disciplina
INSERT INTO disciplina
(nome_disc, ano_minimo, id_prof) VALUES
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
INSERT INTO aluno
(nome, ano_escolar, id_casa, saldo_galeoes) VALUES
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
(1, 1, 7.5),
(1, 2, 5.0),
(1, 6, 9.8),
(1, 5, 8.0),
(2, 1, 10.0),
(2, 2, 9.5),
(2, 3, 10.0),
(2, 5, 9.0),
(2, 9, 9.5),
(3, 1, 6.0),
(3, 2, 4.5),
(3, 7, 5.5),
(4, 2, 3.0),
(4, 4, 10.0),
(4, 6, 7.0),
(5, 2, 9.0),
(5, 1, 7.0),
(5, 5, 4.0),
(6, 2, 7.5),
(6, 7, 6.5),
(7, 2, 3.5),
(7, 6, 2.0),
(8, 5, 8.5),
(8, 3, 8.0),
(8, 4, 9.0),
(9, 3, 8.5),
(9, 6, 7.5),
(10, 3, 9.0),
(10, 7, 6.0),
(11, 4, 8.5),
(11, 6, 9.0),
(11, 1, 8.0),
(12, 4, 8.0),
(13, 4, 7.0),
(13, 3, 7.5);
-- INSERT produto
INSERT INTO produto
(nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20),
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);
-- Confira: SELECT COUNT(*) de cada tabela
SELECT 'casa' AS tabela, COUNT(*) AS total FROM casa
UNION ALL
SELECT 'professor', COUNT(*) FROM professor
UNION ALL
SELECT 'disciplina', COUNT(*) FROM disciplina
UNION ALL
SELECT 'aluno', COUNT(*) FROM aluno
UNION ALL
SELECT 'matricula', COUNT(*) FROM matricula
UNION ALL
SELECT 'produto', COUNT(*) FROM produto
UNION ALL
SELECT 'registro_pontos', COUNT(*) FROM registro_pontos
UNION ALL
SELECT 'compra', COUNT(*) FROM compra
UNION ALL
SELECT 'log_auditoria', COUNT(*) FROM log_auditoria;

-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno
ADD COLUMN email VARCHAR(100);
-- Questão 2
ALTER TABLE matricula
ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';
-- Questão 3
ALTER TABLE produto
ADD COLUMN ativo CHAR(1) DEFAULT 'S';
-- Questão 4
ALTER TABLE casa
MODIFY COLUMN fundador VARCHAR(100);
-- Questão 5
ALTER TABLE professor
RENAME COLUMN data_contratacao TO data_admissao;
-- Questão 6
UPDATE aluno
SET email = CONCAT(
    LOWER(REPLACE(nome, ' ', '.')),
    '@hogwarts.edu'
);
-- Questão 7
ALTER TABLE aluno
ADD CONSTRAINT uq_aluno_email UNIQUE (email);
-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc
    FROM disciplina
    WHERE id_prof IN (
        SELECT id_prof
        FROM professor
        WHERE nome = 'Remo Lupin'
    )
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
WHERE id_casa IS NOT NULL
AND data_admissao < '1980-01-01';
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
DELETE FROM casa
WHERE nome_casa = 'Sonserina';
-- Erro:Erro 1451:Cannot delete or update a parent row: a foreign key constraint fails.
-- Explicação:o banco não permite excluir Sonserina porque existem professores e alunos vinculados a essa casa. A chave estrangeira impede excluir um registro que está sendo referenciado por outras tabelas.

-- Questão 14
INSERT INTO aluno
(nome, ano_escolar, id_casa, saldo_galeoes, email)
VALUES
('Dobby', 8, 1, 0.00, 'dobby@hogwarts.edu');
-- Erro:Erro 3819:Check constraint is violated.
-- Explicação:a tabela aluno possui uma restrição CHECK que permite somente anos escolares entre 1 e 7. Como Dobby está sendo cadastrado no 8º ano, o banco rejeita a operação.

-- Questão 15
INSERT INTO aluno
(nome, ano_escolar, id_casa, saldo_galeoes, email)
VALUES
('Harry Potter (Polissuco)', 5, 1, 0.00,
 'harry.potter@hogwarts.edu');
-- Erro:Erro 1062:Duplicate entry for key 'uq_aluno_email'.
-- Explicação:o e-mail harry.potter@hogwarts.edu já pertence ao Harry Potter original. Como criamos uma restrição UNIQUE na coluna email, não é permitido cadastrar outro aluno utilizando o mesmo endereço.

-- Questão 16
DELETE FROM professor
WHERE nome = 'Severo Snape';
-- Erro: Erro 1451:Cannot delete or update a parent row: a foreign key constraint fails.
-- Explicação:o banco não permite excluir Severo Snape porque ele está associado à disciplina Poções. A tabela disciplina possui uma chave estrangeira (id_prof) que referencia o professor. Para evitar deixar uma referência inválida, o banco bloqueia a exclusão.

-- Questão 17
DELETE FROM professor
WHERE nome = 'Gilderoy Lockhart';
Explicação: esse comando funciona porque Gilderoy Lockhart não possui disciplinas vinculadas a ele nem registros dependentes nas outras tabelas. Portanto, não existe nenhuma chave estrangeira impedindo sua exclusão.
-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (
    SELECT id_aluno
    FROM aluno
    WHERE nome = 'Vicente Crabbe'
);

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';
-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (
    SELECT id_disc
    FROM matricula
);

SELECT 'professor' AS tabela, COUNT(*) AS total FROM professor
UNION ALL
SELECT 'aluno', COUNT(*) FROM aluno
UNION ALL
SELECT 'disciplina', COUNT(*) FROM disciplina
UNION ALL
SELECT 'matricula', COUNT(*) FROM matricula;
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
    WHERE id_casa = (
        SELECT id_casa
        FROM aluno
        WHERE id_aluno = NEW.id_aluno
    );
END $$

DELIMITER ;
-- Questão 21 - trg_valida_compra
DELIMITER $$

CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);

    SELECT estoque, preco
    INTO v_estoque, v_preco
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes
    INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';

    ELSEIF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';

    ELSE
        SET NEW.valor_total = v_preco * NEW.quantidade;
    END IF;

END $$

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

END $$

DELIMITER ;
-- Questão 23 - trg_situacao_nota
DELIMITER $$

CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN

    IF NEW.nota >= 6 THEN
        SET NEW.situacao = 'Aprovado';
    ELSE
        SET NEW.situacao = 'Reprovado';
    END IF;

END $$

DELIMITER ;
-- Questão 24 - trg_audita_salario
DELIMITER $$

CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN

    IF OLD.salario <> NEW.salario THEN

        INSERT INTO log_auditoria
        (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(
                OLD.nome,
                ': salário de ',
                OLD.salario,
                ' para ',
                NEW.salario
            )
        );

    END IF;

END $$

DELIMITER ;
-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta:A validação precisa ser BEFORE porque o sistema deve verificar se há estoque e saldo suficientes antes de permitir o registro da compra. Já a baixa do estoque precisa ser AFTER porque o desconto dos produtos e dos galeões só deve acontecer depois que a compra for registrada com sucesso, evitando alterações indevidas quando uma compra não puder ser realizada.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
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
INSERT INTO compra
(id_aluno, id_produto, quantidade, data_compra)
VALUES
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
INSERT INTO compra
(id_aluno, id_produto, quantidade, data_compra)
VALUES
(3, 2, 1, '2026-11-10');
-- Resultado:
a compra é recusada. Rony começou com 12 galeões e gastou 6 na compra de Feijõezinhos, ficando com 6 galeões. A Nimbus custa 300 galeões. O trigger trg_valida_compra identifica que o saldo é insuficiente e gera uma mensagem de erro. Nenhuma compra é registrada e nenhum estoque ou saldo é alterado.
-- Questão 25 - Hermione tenta comprar o caldeirão
    INSERT INTO compra
(id_aluno, id_produto, quantidade, data_compra)
VALUES
(2, 6, 1, '2026-11-10');
-- Resultado:
a compra é recusada porque o Caldeirão de Estanho está com estoque zero. O trigger trg_valida_compra verifica primeiro o estoque e gera a mensagem de estoque insuficiente. A compra não é registrada.
-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3
AND id_disc = 2;

SELECT
    a.nome,
    d.nome_disc,
    m.nota,
    m.situacao
FROM matricula m
JOIN aluno a ON a.id_aluno = m.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
WHERE a.id_aluno = 3
AND d.id_disc = 2;
-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor
SET salario = 5000.00
WHERE nome = 'Rúbeo Hagrid';
UPDATE professor
SET data_admissao = '1993-08-15'
WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Linhas em log_auditoria:
aparece apenas 1 linha no log_auditoria.

Isso acontece porque o trigger trg_audita_salario registra alterações no salário. A primeira atualização modificou o salário de Hagrid, gerando um registro. A segunda alterou somente a data de admissão, portanto não gerou outro registro.
-- Por que o reajuste da questão 10 não aparece:
Porque o reajuste da questão 10 foi executado antes da criação do trigger trg_audita_salario. Naquele momento, o trigger ainda não existia para registrar a alteração.

    SELECT nome_casa, pontos
FROM casa
ORDER BY nome_casa;
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno IN (1, 5);
SELECT nome_produto, estoque
FROM produto
WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) AS total_compras
FROM compra;
SELECT COUNT(*) AS total_logs
FROM log_auditoria;

-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;

UPDATE aluno
SET saldo_galeoes = saldo_galeoes - 50
WHERE id_aluno = 5;

UPDATE aluno
SET saldo_galeoes = saldo_galeoes + 50
WHERE id_aluno = 6;

COMMIT;
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno IN (5, 6);
-- Questão 27
START TRANSACTION;

UPDATE casa
SET pontos = 0;

SELECT nome_casa, pontos
FROM casa;
ROLLBACK;

SELECT nome_casa, pontos
FROM casa;
Explicação: sim, o placar voltou. O ROLLBACK desfez o UPDATE, restaurando os valores que existiam antes da transação.
-- Questão 28
START TRANSACTION;

INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno = 1;

SELECT nome_produto, estoque
FROM produto
WHERE id_produto = 1;
ROLLBACK;
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno = 1;

SELECT nome_produto, estoque
FROM produto
WHERE id_produto = 1;
Explicação: as alterações feitas pelo trigger também foram desfeitas. Como o trigger executou atualizações dentro da mesma transação, o ROLLBACK desfez tanto a compra quanto a baixa do saldo e do estoque.
-- Questão 29
START TRANSACTION;

-- a) Ana Abbott recebe 15 pontos
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

-- b) Cria o ponto de salvamento
SAVEPOINT sp_pontos_legitimos;

-- c) Pansy recebe 100 pontos indevidos
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(6, 2, 100, 'Favoritismo descarado', '2026-11-10');

-- d) Desfaz somente o que aconteceu depois do SAVEPOINT
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;

-- Confirma o que restou da transação
COMMIT;
SELECT nome_casa, pontos
FROM casa;
SELECT COUNT(*) AS total_registros
FROM registro_pontos;
-- Questão 30
SELECT @@autocommit;
-- Resposta:
O que significa o valor retornado?
- 1: o MySQL está com o autocommit ativado. Cada comando executado fora de uma transação explícita é confirmado automaticamente.
- 0: o autocommit está desativado. As alterações precisam ser confirmadas manualmente com COMMIT ou desfeitas com ROLLBACK.

    O que acontece se executar um CREATE TABLE no meio de uma transação?

No MySQL, comandos DDL como CREATE TABLE provocam um COMMIT implícito. Isso significa que a transação aberta é confirmada antes da execução do comando. Portanto, não será possível desfazer as alterações anteriores usando ROLLBACK.

SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno IN (5, 6);
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_aluno = 1;

SELECT nome_produto, estoque
FROM produto
WHERE id_produto = 1;
SELECT nome_casa, pontos
FROM casa;
SELECT COUNT(*) AS total_registros
FROM registro_pontos;
SELECT COUNT(*) AS total_logs
FROM log_auditoria;

-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT
    p.nome AS nome_professor,
    p.salario AS salario
FROM professor AS p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;
-- 6.2
SELECT
    a.nome AS nome_aluno,
    a.ano_escolar AS ano_escolar
FROM aluno AS a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar;
-- 6.3
SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE a.nome LIKE '_a%';
-- 6.4
SELECT
    d.nome_disc AS nome_disciplina
FROM disciplina AS d
WHERE d.id_prof IS NULL;
-- 6.5
SELECT
    pr.nome_produto AS nome_produto,
    pr.preco AS preco_galeoes
FROM produto AS pr
WHERE pr.preco NOT BETWEEN 5.00 AND 20.00
ORDER BY pr.preco ASC;
-- 6.6
SELECT DISTINCT
    pr.loja AS nome_loja
FROM produto AS pr
ORDER BY pr.loja ASC;
-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT
    a.nome AS nome_aluno,
    c.nome_casa AS nome_casa
FROM aluno AS a
INNER JOIN casa AS c
    ON a.id_casa = c.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê:
A consulta retorna só 12 alunos porque o aluno teddy lupin não possui casa
-- 6.8
SELECT
    a.nome AS nome_aluno,
    COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa_aluno
FROM aluno AS a
LEFT JOIN casa AS c
    ON a.id_casa = c.id_casa
ORDER BY a.nome;
-- 6.9
SELECT
    p.nome AS nome_professor
FROM disciplina AS d
RIGHT JOIN professor AS p
    ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;
-- 6.10
SELECT
    a.nome AS nome_aluno,
    d.nome_disc AS nome_disciplina,
    COALESCE(p.nome, 'Sem professor') AS nome_professor,
    m.nota AS nota,
    m.situacao AS situacao
FROM aluno AS a
INNER JOIN casa AS c
    ON a.id_casa = c.id_casa
INNER JOIN matricula AS m
    ON a.id_aluno = m.id_aluno
INNER JOIN disciplina AS d
    ON m.id_disc = d.id_disc
LEFT JOIN professor AS p
    ON d.id_prof = p.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;
-- 6.11
SELECT
    cp.id_compra AS numero_compra,
    a.nome AS nome_aluno,
    pr.nome_produto AS produto,
    pr.loja AS loja,
    cp.quantidade AS quantidade,
    cp.valor_total AS valor_total,
    cp.data_compra AS data_compra
FROM compra AS cp
INNER JOIN aluno AS a
    ON cp.id_aluno = a.id_aluno
INNER JOIN produto AS pr
    ON cp.id_produto = pr.id_produto
ORDER BY cp.data_compra ASC, cp.id_compra ASC;
-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT
    d.nome_disc AS nome_disciplina,
    COUNT(m.id_aluno) AS quantidade_alunos,
    ROUND(AVG(m.nota), 2) AS media_notas,
    MAX(m.nota) AS maior_nota,
    MIN(m.nota) AS menor_nota
FROM disciplina AS d
INNER JOIN matricula AS m
    ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media_notas DESC;
-- 6.13
SELECT
    c.nome_casa AS nome_casa,
    COUNT(r.id_registro) AS quantidade_registros,
    SUM(CASE
        WHEN r.pontos > 0 THEN r.pontos
        ELSE 0
    END) AS total_pontos_ganhos,
    SUM(CASE
        WHEN r.pontos < 0 THEN ABS(r.pontos)
        ELSE 0
    END) AS total_pontos_perdidos,
    COALESCE(SUM(r.pontos), 0) AS saldo_pontos
FROM casa AS c
LEFT JOIN aluno AS a
    ON c.id_casa = a.id_casa
LEFT JOIN registro_pontos AS r
    ON a.id_aluno = r.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY c.nome_casa;
-- 6.14
SELECT
    pr.loja AS nome_loja,
    COUNT(cp.id_compra) AS quantidade_compras,
    SUM(cp.valor_total) AS faturamento_total
FROM produto AS pr
INNER JOIN compra AS cp
    ON pr.id_produto = cp.id_produto
GROUP BY pr.loja
HAVING SUM(cp.valor_total) > 20
ORDER BY faturamento_total DESC;
-- 6.15
SELECT
    MONTH(r.data_registro) AS numero_mes,
    COUNT(r.id_registro) AS quantidade_registros,
    SUM(r.pontos) AS total_pontos
FROM registro_pontos AS r
GROUP BY MONTH(r.data_registro)
ORDER BY numero_mes ASC;
-- 6.16
SELECT
    p.nome AS nome_professor,
    COUNT(r.id_registro) AS quantidade_registros,
    SUM(r.pontos) AS total_pontos
FROM professor AS p
INNER JOIN registro_pontos AS r
    ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_pontos DESC;
-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE a.id_aluno IN (
    SELECT cp.id_aluno
    FROM compra AS cp
    WHERE cp.id_produto IN (
        SELECT pr.id_produto
        FROM produto AS pr
        WHERE pr.loja = 'Dedosdemel'
    )
);
-- 6.18
SELECT
    pr.nome_produto AS nome_produto,
    pr.estoque AS quantidade_estoque
FROM produto AS pr
WHERE pr.id_produto NOT IN (
    SELECT cp.id_produto
    FROM compra AS cp
);
-- 6.19
SELECT
    a.nome AS nome_aluno,
    a.saldo_galeoes AS saldo_galeoes
FROM aluno AS a
WHERE a.saldo_galeoes > (
    SELECT AVG(a2.saldo_galeoes)
    FROM aluno AS a2
)
ORDER BY a.saldo_galeoes DESC;
-- 6.20
SELECT
    p.nome AS nome_professor,
    p.salario AS salario
FROM professor AS p
WHERE p.salario > ALL (
    SELECT p2.salario
    FROM professor AS p2
    WHERE p2.id_casa IS NULL
)
ORDER BY p.salario DESC;
-- 6.21
SELECT
    a.nome AS nome_aluno,
    a.saldo_galeoes AS saldo_galeoes
FROM aluno AS a
WHERE a.id_casa <> 2
AND a.saldo_galeoes > ANY (
    SELECT a2.saldo_galeoes
    FROM aluno AS a2
    WHERE a2.id_casa = 2
)
ORDER BY a.saldo_galeoes DESC;
-- > ANY equivale a:
equivale a comparar com o menor valor da subconsulta: basta ser maior que pelo menos um dos valores.
-- 6.22
SELECT
    c.nome_casa AS nome_casa
FROM casa AS c
WHERE EXISTS (
    SELECT 1
    FROM aluno AS a
    INNER JOIN matricula AS m
        ON a.id_aluno = m.id_aluno
    WHERE a.id_casa = c.id_casa
    AND m.nota = 10
);
-- 6.23
SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra AS cp
    WHERE cp.id_aluno = a.id_aluno
)
ORDER BY a.nome;
-- 6.24
SELECT
    c.nome_casa AS nome_casa,
    ROUND(AVG(boletim.media_aluno), 2) AS media_da_casa
FROM (
    SELECT
        m.id_aluno,
        AVG(m.nota) AS media_aluno
    FROM matricula AS m
    GROUP BY m.id_aluno
) AS boletim
INNER JOIN aluno AS a
    ON boletim.id_aluno = a.id_aluno
INNER JOIN casa AS c
    ON a.id_casa = c.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;
-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT
    a.nome AS nome,
    'Aluno' AS vinculo
FROM aluno AS a

UNION ALL

SELECT
    p.nome AS nome,
    'Professor' AS vinculo
FROM professor AS p

ORDER BY nome;
-- 6.26
-- Linhas com UNION ALL:
SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE a.id_aluno IN (
    SELECT cp.id_aluno
    FROM compra AS cp
)

UNION ALL

SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE a.id_aluno IN (
    SELECT r.id_aluno
    FROM registro_pontos AS r
);
-- Linhas com UNION:
SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE a.id_aluno IN (
    SELECT cp.id_aluno
    FROM compra AS cp
)

UNION

SELECT
    a.nome AS nome_aluno
FROM aluno AS a
WHERE a.id_aluno IN (
    SELECT r.id_aluno
    FROM registro_pontos AS r
);
-- Explicação:
- UNION ALL: junta os resultados e mantém as duplicatas. Se um aluno aparece nas duas consultas, seu nome aparece duas vezes.
- UNION: junta os resultados e elimina nomes repetidos.
Portanto, UNION ALL retorna 27 linhas, enquanto UNION retorna 12 linhas, conforme a conferência da atividade.
-- 6.27
SELECT
    'Total de pontos distribuídos' AS indicador,
    SUM(r.pontos) AS valor
FROM registro_pontos AS r

UNION ALL

SELECT
    'Total de galeões gastos na loja' AS indicador,
    SUM(cp.valor_total) AS valor
FROM compra AS cp

UNION ALL

SELECT
    'Folha salarial dos professores' AS indicador,
    SUM(p.salario) AS valor
FROM professor AS p

UNION ALL

SELECT
    'Total de galeões nos cofres dos alunos' AS indicador,
    SUM(a.saldo_galeoes) AS valor
FROM aluno AS a;

-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT
    c.nome_casa AS nome_casa,
    c.pontos AS pontos
FROM casa AS c
ORDER BY c.pontos DESC;
-- Questão 32
CREATE VIEW vw_boletim AS
SELECT
    a.nome AS aluno,
    COALESCE(c.nome_casa, 'Sem casa') AS casa,
    d.nome_disc AS disciplina,
    COALESCE(p.nome, 'Sem professor') AS professor,
    m.nota AS nota,
    m.situacao AS situacao
FROM matricula AS m
INNER JOIN aluno AS a
    ON m.id_aluno = a.id_aluno
LEFT JOIN casa AS c
    ON a.id_casa = c.id_casa
INNER JOIN disciplina AS d
    ON m.id_disc = d.id_disc
LEFT JOIN professor AS p
    ON d.id_prof = p.id_prof;
-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT
    a.nome AS aluno,
    pr.nome_produto AS produto,
    pr.loja AS loja,
    cp.quantidade AS quantidade,
    cp.valor_total AS valor_total,
    cp.data_compra AS data_compra
FROM compra AS cp
INNER JOIN aluno AS a
    ON cp.id_aluno = a.id_aluno
INNER JOIN produto AS pr
    ON cp.id_produto = pr.id_produto;
-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT
    a.nome AS aluno,
    c.nome_casa AS casa,
    ROUND(AVG(m.nota), 2) AS media_notas
FROM aluno AS a
INNER JOIN matricula AS m
    ON a.id_aluno = m.id_aluno
LEFT JOIN casa AS c
    ON a.id_casa = c.id_casa
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;
-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT
    p.nome AS nome_professor,

    COALESCE(c.nome_casa, 'Não é diretor') AS casa_dirigida,

    (
        SELECT COUNT(*)
        FROM disciplina AS d
        WHERE d.id_prof = p.id_prof
    ) AS quantidade_disciplinas,

    COALESCE((
        SELECT SUM(r.pontos)
        FROM registro_pontos AS r
        WHERE r.id_prof = p.id_prof
    ), 0) AS total_pontos_concedidos

FROM professor AS p
LEFT JOIN casa AS c
    ON p.id_casa = c.id_casa;
-- Questão 36
SELECT *
FROM vw_placar_casas
ORDER BY pontos DESC;
SELECT *
FROM vw_boletim
WHERE casa = 'Corvinal'
ORDER BY aluno, disciplina;
SELECT
    vl.loja AS nome_loja,
    SUM(vl.valor_total) AS faturamento_total
FROM vw_extrato_loja AS vl
GROUP BY vl.loja
ORDER BY faturamento_total DESC;
SELECT *
FROM vw_alunos_destaque
ORDER BY media_notas DESC;
SELECT *
FROM vw_quadro_professores
ORDER BY total_pontos_concedidos DESC;
-- Questão 37
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');
SELECT *
FROM vw_placar_casas
ORDER BY pontos DESC;
-- O que mudou e por quê:
A Lufa-Lufa passa de 50 para 70 pontos Porque Cedrico Diggory pertence à Lufa-Lufa. Ao inserir o registro, o trigger trg_pontos_casa atualiza automaticamente a pontuação da casa. Como a view consulta diretamente a tabela casa, ela apresenta os valores atualizados sem precisar ser recriada.
-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT
    c.nome_casa AS nome_casa,
    c.fundador AS fundador,
    c.pontos AS pontos
FROM casa AS c
ORDER BY c.pontos DESC;
SELECT *
FROM vw_placar_casas
ORDER BY pontos DESC;

-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39
CREATE USER 'filch'@'localhost'
IDENTIFIED BY 'MadameNorra#1';

CREATE USER 'mcgonagall'@'localhost'
IDENTIFIED BY 'Animago#Gato1';

CREATE USER 'dumbledore'@'localhost'
IDENTIFIED BY 'Fenix#Fawkes1';
-- Questão 40
GRANT SELECT ON hogwarts.vw_placar_casas
TO 'filch'@'localhost';
-- Questão 41
GRANT SELECT, INSERT ON hogwarts.registro_pontos
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.aluno
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.vw_boletim
TO 'mcgonagall'@'localhost';
-- Questão 42
GRANT ALL PRIVILEGES ON hogwarts.*
TO 'dumbledore'@'localhost'
WITH GRANT OPTION;
-- Questão 43
SHOW GRANTS FOR 'filch'@'localhost';

SHOW GRANTS FOR 'mcgonagall'@'localhost';
-- Questão 44
SELECT * FROM hogwarts.vw_placar_casas;
SELECT * FROM hogwarts.aluno;
-- Resultado de cada comando:
Filch tem permissão SELECT nessa view.
ERROR 1142: Command denied to user

-- Questão 45
INSERT INTO hogwarts.registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
UPDATE hogwarts.casa
SET pontos = 1000
WHERE id_casa = 1;
-- Como o trigger conseguiu atualizar a casa:
Porque o trigger é executado com os privilégios do usuário que o criou (por padrão, DEFINER), e não com os privilégios de quem executou o INSERT. Assim, ele consegue atualizar a tabela casa mesmo que McGonagall não tenha essa permissão.
-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos
FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';
-- Questão 47
CREATE ROLE 'monitor';
GRANT SELECT ON hogwarts.vw_boletim
TO 'monitor';

GRANT SELECT ON hogwarts.vw_placar_casas
TO 'monitor';
CREATE USER 'percy'@'localhost'
IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor'
TO 'percy'@'localhost';
-- Vantagem dos papéis:
Os papéis facilitam o gerenciamento de permissões. Em vez de conceder os mesmos privilégios individualmente para cada monitor, basta atribuir o papel monitor. Se as permissões do papel forem alteradas, todos os usuários que o utilizam recebem essas alterações automaticamente.
-- Questão 48
DROP USER 'filch'@'localhost';

DROP USER 'mcgonagall'@'localhost';

DROP USER 'dumbledore'@'localhost';

DROP USER 'percy'@'localhost';

DROP ROLE 'monitor';
