-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Alexandre Batista dos Santos
-- Matrícula: 2387623
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================
 
SET SQL_SAFE_UPDATES = 0;
 
-- =====================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================
 
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;
 
-- Tabela casa
CREATE TABLE casa (
    id_casa   INT          AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30)  NOT NULL UNIQUE,
    fundador  VARCHAR(60),
    pontos    INT          DEFAULT 0
);
 
-- Tabela professor
CREATE TABLE professor (
    id_prof          INT           AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100)  NOT NULL,
    salario          DECIMAL(10,2) NOT NULL CHECK (salario > 0),
    data_contratacao DATE,
    id_casa          INT,
    FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);
 
-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc    INT         AUTO_INCREMENT PRIMARY KEY,
    nome_disc  VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT         CHECK (ano_minimo BETWEEN 1 AND 7),
    id_prof    INT,
    FOREIGN KEY (id_prof) REFERENCES professor(id_prof)
);
 
-- Tabela aluno
CREATE TABLE aluno (
    id_aluno      INT            AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100)   NOT NULL,
    ano_escolar   INT            CHECK (ano_escolar BETWEEN 1 AND 7),
    id_casa       INT,
    saldo_galeoes DECIMAL(10,2)  DEFAULT 0 CHECK (saldo_galeoes >= 0),
    FOREIGN KEY (id_casa) REFERENCES casa(id_casa)
);
 
-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc  INT,
    nota     DECIMAL(4,2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (id_aluno, id_disc),
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_disc)  REFERENCES disciplina(id_disc)
);
 
-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro   INT          AUTO_INCREMENT PRIMARY KEY,
    id_aluno      INT          NOT NULL,
    id_prof       INT          NOT NULL,
    pontos        INT          NOT NULL,
    motivo        VARCHAR(150),
    data_registro DATE         NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_prof)  REFERENCES professor(id_prof)
);
 
-- Tabela produto
CREATE TABLE produto (
    id_produto   INT            AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100)   NOT NULL,
    loja         VARCHAR(50)    NOT NULL,
    preco        DECIMAL(10,2)  CHECK (preco > 0),
    estoque      INT            DEFAULT 0 CHECK (estoque >= 0)
);
 
-- Tabela compra
CREATE TABLE compra (
    id_compra   INT            AUTO_INCREMENT PRIMARY KEY,
    id_aluno    INT,
    id_produto  INT,
    quantidade  INT            CHECK (quantidade > 0),
    valor_total DECIMAL(10,2),
    data_compra DATE           NOT NULL,
    FOREIGN KEY (id_aluno)   REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);
 
-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log    INT          AUTO_INCREMENT PRIMARY KEY,
    tabela    VARCHAR(30),
    operacao  VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);
 
-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: A chave composta (id_aluno, id_disc) garante naturalmente que um aluno
-- não se matricule duas vezes na mesma disciplina. Se houvesse um id_matricula
-- auto_increment, o banco aceitaria linhas duplicadas de (id_aluno, id_disc) sem
-- reclamar, tornando necessária uma constraint UNIQUE adicional. A chave composta
-- é mais semântica e elimina esse problema na própria definição da PK.

-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
    ('Grifinória', 'Godric Gryffindor'),  -- 1
    ('Sonserina',  'Salazar Slytherin'),   -- 2
    ('Corvinal',   'Rowena Ravenclaw'),    -- 3
    ('Lufa-Lufa',  'Helga Hufflepuff');   -- 4

-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
    ('Minerva McGonagall', 9500.00, '1956-12-01', 1),   -- 1
    ('Severo Snape',       8800.00, '1981-09-01', 2),   -- 2
    ('Fílio Flitwick',     8200.00, '1974-09-01', 3),   -- 3
    ('Pomona Sprout',      7900.00, '1972-09-01', 4),   -- 4
    ('Rúbeo Hagrid',       4500.00, '1993-09-01', NULL), -- 5
    ('Remo Lupin',         6200.00, '1993-09-01', NULL), -- 6
    ('Sibila Trelawney',   5100.00, '1980-09-01', NULL), -- 7
    ('Gilderoy Lockhart',  7000.00, '1992-09-01', NULL), -- 8
    ('Horácio Slughorn',   8000.00, '1996-09-01', NULL); -- 9

-- INSERT disciplina
INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
    ('Transfiguração',                    1, 1),    -- 1
    ('Poções',                            1, 2),    -- 2
    ('Feitiços',                          1, 3),    -- 3
    ('Herbologia',                        1, 4),    -- 4
    ('Trato das Criaturas Mágicas',       3, 5),    -- 5
    ('Defesa Contra as Artes das Trevas', 1, 6),    -- 6
    ('Adivinhação',                       3, 7),    -- 7
    ('Estudo dos Trouxas',                3, NULL), -- 8
    ('Runas Antigas',                     3, NULL); -- 9

-- INSERT aluno
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
    ('Harry Potter',       5, 1, 120.00), -- 1
    ('Hermione Granger',   5, 1,  85.00), -- 2
    ('Rony Weasley',       5, 1,  12.00), -- 3
    ('Neville Longbottom', 5, 1,  30.00), -- 4
    ('Draco Malfoy',       5, 2, 500.00), -- 5
    ('Pansy Parkinson',    5, 2, 150.00), -- 6
    ('Vicente Crabbe',     5, 2,  40.00), -- 7
    ('Luna Lovegood',      4, 3,  45.00), -- 8
    ('Cho Chang',          6, 3, 200.00), -- 9
    ('Padma Patil',        5, 3,  60.00), -- 10
    ('Cedrico Diggory',    7, 4, 180.00), -- 11
    ('Ana Abbott',         5, 4,  25.00), -- 12
    ('Ernesto Macmillan',  5, 4,  70.00), -- 13
    ('Teddy Lupin',        1, NULL, 0.00); -- 14

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
    ('Varinha de Azevinho',              'Olivaras',              7.00,  10), -- 1
    ('Vassoura Nimbus 2001',             'Artigos de Quadribol', 300.00,  3), -- 2
    ('Sapo de Chocolate',                'Dedosdemel',            2.00, 200), -- 3
    ('Feijõezinhos de Todos os Sabores', 'Dedosdemel',            1.50, 150), -- 4
    ('Livro Monstruoso dos Monstros',    'Floreios e Borrões',   12.00,  20), -- 5
    ('Caldeirão de Estanho',             'Caldeirões Potage',     9.00,   0), -- 6
    ('Kit de Logros',                    'Gemialidades Weasley', 25.00,  40), -- 7
    ('Pena de Repetição Rápida',         'Escribbulus',          15.00,   5); -- 8

-- Confira: SELECT COUNT(*) de cada tabela
SELECT COUNT(*) AS qtd_casas       FROM casa;        -- 4
SELECT COUNT(*) AS qtd_professores FROM professor;   -- 9
SELECT COUNT(*) AS qtd_disciplinas FROM disciplina;  -- 9
SELECT COUNT(*) AS qtd_alunos      FROM aluno;       -- 14
SELECT COUNT(*) AS qtd_matriculas  FROM matricula;   -- 35
SELECT COUNT(*) AS qtd_produtos    FROM produto;     -- 8

-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100) DEFAULT NULL;

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
ALTER TABLE aluno
    ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc FROM disciplina WHERE id_prof = (
        SELECT id_prof FROM professor WHERE nome = 'Remo Lupin'
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
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: 1451 - Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: Alunos (Draco, Pansy, Crabbe) e o professor Snape têm id_casa = 2
-- (Sonserina). Como outras tabelas referenciam essa linha via FK, o banco bloqueia
-- a exclusão para manter a integridade referencial.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro: 3819 - Check constraint 'aluno_chk_1' is violated
-- Explicação: A coluna ano_escolar tem CHECK (ano_escolar BETWEEN 1 AND 7).
-- O valor 8 está fora dessa faixa, portanto o banco rejeita o INSERT.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro: 1062 - Duplicate entry 'harry.potter@hogwarts.edu' for key 'uq_aluno_email'
-- Explicação: A constraint UNIQUE adicionada na questão 7 impede dois alunos com
-- o mesmo e-mail. Harry Potter (id 1) já possui esse endereço cadastrado.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: 1451 - Cannot delete or update a parent row: a foreign key constraint fails
-- Explicação: A disciplina 'Poções' (id_prof = 2) referencia Snape. Enquanto essa
-- disciplina existir, o banco não permite excluir o professor referenciado.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Funciona porque nenhuma disciplina aponta para Lockhart (id_prof = 8): após a
-- carga inicial, 'Estudo dos Trouxas' e 'Runas Antigas' têm id_prof NULL, então
-- a remoção não viola nenhuma FK.

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (
    SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe'
);
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (
    SELECT DISTINCT id_disc FROM matricula
);

-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
DELIMITER $$

-- Questão 20 - trg_pontos_casa
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa c
    INNER JOIN aluno a ON a.id_casa = c.id_casa
    SET c.pontos = c.pontos + NEW.pontos
    WHERE a.id_aluno = NEW.id_aluno;
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
    END IF;

    IF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
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
    IF NEW.nota >= 6 THEN
        SET NEW.situacao = 'Aprovado';
    ELSE
        SET NEW.situacao = 'Reprovado';
    END IF;
END$$

-- Questão 24 - trg_audita_salario
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(NEW.nome, ': salário de ',
                   FORMAT(OLD.salario, 2), ' para ',
                   FORMAT(NEW.salario, 2))
        );
    END IF;
END$$

DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: O trigger BEFORE roda antes de o registro ser gravado no banco, o que
-- permite cancelar a operação com SIGNAL se houver problema (estoque insuficiente
-- ou saldo baixo) e também preencher NEW.valor_total antes da inserção. Se fosse
-- AFTER, a linha já teria sido inserida e não seria mais possível bloqueá-la nem
-- alterar seus campos. Já a baixa de estoque e saldo precisa ser AFTER porque só
-- faz sentido descontar os valores depois que a compra foi confirmada e gravada
-- com sucesso — se algo falhar no INSERT, o AFTER não dispara, evitando descontos
-- sem compra registrada.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
    ( 2, 3,  20, 'Feitiço de levitação perfeito',             '2026-09-10'),
    ( 1, 2, -10, 'Atraso na aula de Poções',                  '2026-09-12'),
    ( 5, 2,  15, 'Poção do Morto-Vivo impecável',             '2026-09-12'),
    ( 8, 5,  10, 'Cuidou de um testrálio ferido',             '2026-09-20'),
    (11, 4,  25, 'Ajudou os alunos do 1º ano',                '2026-09-25'),
    ( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia',      '2026-10-02'),
    ( 6, 1, -20, 'Fora da cama após o toque de recolher',     '2026-10-05'),
    ( 1, 6,  50, 'Conjurou um Patrono corpóreo',              '2026-10-15'),
    ( 9, 3,  15, 'Duelo exemplar no Clube de Duelos',         '2026-10-18'),
    ( 5, 1, -30, 'Duelo proibido no corredor',                '2026-10-31'),
    (10, 7,   5, 'Interpretação da bola de cristal',          '2026-11-03'),
    (13, 4,  10, 'Colheita de mandrágoras',                   '2026-11-05'),
    ( 3, 9,  10, 'Identificou um bezoar',                     '2026-11-06'),
    ( 8, 3,  20, 'Resposta brilhante sobre o Diadema',        '2026-11-08'),
    ( 6, 2,  25, 'Antídoto para venenos comuns',              '2026-11-09'),
    ( 5, 9,  40, 'Melhor poção do Clube do Slugue',           '2026-11-09');

-- Questão 25 - INSERT compra
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
    ( 5, 2,  1, '2026-09-01'),
    ( 2, 5,  2, '2026-09-02'),
    ( 1, 3, 10, '2026-09-03'),
    ( 3, 4,  5, '2026-09-03'),
    ( 9, 8,  1, '2026-09-15'),
    ( 8, 5,  1, '2026-09-20'),
    (11, 1,  1, '2026-10-01'),
    ( 6, 3, 20, '2026-10-10'),
    ( 1, 7,  2, '2026-10-20'),
    (13, 4, 10, '2026-11-02');

-- Questão 25 - Rony tenta comprar a Nimbus
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-01');
-- Resultado: Erro 1644 - Galeões insuficientes no cofre do aluno
-- Rony tem apenas 12.00 galeões e a Nimbus 2001 custa 300.00.
-- O trigger trg_valida_compra detecta que saldo_galeoes < preco * quantidade
-- e aborta a operação com SIGNAL antes de gravar a compra.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-01');
-- Resultado: Erro 1644 - Estoque insuficiente no Beco Diagonal
-- O Caldeirão de Estanho (id 6) tem estoque = 0 (produto inativo).
-- O trigger trg_valida_compra detecta estoque < quantidade e aborta.

-- Questão 25 - Recuperação do Rony em Poções
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3 AND id_disc = 2;
-- O trigger trg_situacao_nota recalcula automaticamente: nota 6.5 >= 6 → 'Aprovado'
-- SELECT situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2; → Aprovado

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario    = 5000.00       WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
-- Linhas em log_auditoria: 1
-- Por que o reajuste da questão 10 não aparece: O trigger trg_audita_salario só
-- existia a partir da questão 24. O UPDATE da questão 10 foi executado antes de
-- o trigger ser criado, portanto não havia código para interceptá-lo e gravar
-- o registro de auditoria.

-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
    UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE id_aluno = 5; -- Draco
    UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE id_aluno = 6; -- Pansy
COMMIT;

-- Questão 27
START TRANSACTION;
    UPDATE casa SET pontos = 0;
    SELECT nome_casa, pontos FROM casa; -- todos em 0
ROLLBACK;
SELECT nome_casa, pontos FROM casa;    -- placar restaurado

-- Questão 28
START TRANSACTION;
    INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
    VALUES (1, 1, 1, '2026-11-10');
    SELECT saldo_galeoes FROM aluno   WHERE id_aluno   = 1; -- 47.00
    SELECT estoque       FROM produto WHERE id_produto = 1; -- 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno   WHERE id_aluno   = 1; -- volta a 54.00
SELECT estoque       FROM produto WHERE id_produto = 1; -- volta a 9

-- Questão 29
START TRANSACTION;
    INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
    VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

    SAVEPOINT sp_pontos_legitimos;

    INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
    VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');

    ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Questão 30
SELECT @@autocommit;
-- Resposta: O valor 1 indica que o autocommit está ativado: cada instrução SQL
-- avulsa é confirmada automaticamente como uma transação própria, sem necessidade
-- de COMMIT explícito. Quando se executa um comando DDL (como CREATE TABLE) dentro
-- de uma transação aberta, o MySQL emite um COMMIT implícito antes de processar o
-- DDL, tornando irretornáveis todas as alterações feitas até aquele ponto na
-- transação.

-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT nome AS professor, salario
FROM professor
WHERE salario BETWEEN 6000.00 AND 9000.00
ORDER BY salario DESC;

-- 6.2
SELECT nome AS aluno, ano_escolar
FROM aluno
WHERE ano_escolar IN (1, 4, 6, 7)
ORDER BY ano_escolar;

-- 6.3
SELECT nome AS aluno
FROM aluno
WHERE nome LIKE '_a%' OR nome LIKE '_A%';

-- 6.4
SELECT nome_disc AS disciplina
FROM disciplina
WHERE id_prof IS NULL;

-- 6.5
SELECT nome_produto AS produto, preco
FROM produto
WHERE preco NOT BETWEEN 5.00 AND 20.00
ORDER BY preco;

-- 6.6
SELECT DISTINCT loja
FROM produto
ORDER BY loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê: retorna 12 alunos. O INNER JOIN exige correspondência
-- em ambos os lados: Teddy Lupin tem id_casa NULL e portanto não encontra par na
-- tabela casa, sendo excluído do resultado.

-- 6.8
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT  a.nome                              AS aluno,
        d.nome_disc                         AS disciplina,
        COALESCE(p.nome, 'Sem professor')   AS professor,
        m.nota,
        m.situacao
FROM aluno a
INNER JOIN casa        c  ON c.id_casa  = a.id_casa
INNER JOIN matricula   m  ON m.id_aluno = a.id_aluno
INNER JOIN disciplina  d  ON d.id_disc  = m.id_disc
LEFT  JOIN professor   p  ON p.id_prof  = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT  co.id_compra    AS numero_compra,
        a.nome          AS aluno,
        pr.nome_produto AS produto,
        pr.loja,
        co.quantidade,
        co.valor_total,
        co.data_compra
FROM compra co
INNER JOIN aluno   a  ON a.id_aluno    = co.id_aluno
INNER JOIN produto pr ON pr.id_produto = co.id_produto
ORDER BY co.data_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT  d.nome_disc               AS disciplina,
        COUNT(m.id_aluno)         AS qtd_alunos,
        ROUND(AVG(m.nota), 2)     AS media,
        MAX(m.nota)               AS maior_nota,
        MIN(m.nota)               AS menor_nota
FROM disciplina d
INNER JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13
SELECT  c.nome_casa                                                AS casa,
        COUNT(rp.id_registro)                                      AS qtd_registros,
        SUM(CASE WHEN rp.pontos > 0 THEN rp.pontos  ELSE 0 END)   AS pontos_ganhos,
        SUM(CASE WHEN rp.pontos < 0 THEN rp.pontos  ELSE 0 END)   AS pontos_perdidos,
        SUM(rp.pontos)                                             AS saldo
FROM casa c
INNER JOIN aluno           a  ON a.id_casa    = c.id_casa
INNER JOIN registro_pontos rp ON rp.id_aluno  = a.id_aluno
GROUP BY c.id_casa, c.nome_casa;

-- 6.14
SELECT  pr.loja,
        COUNT(co.id_compra)  AS qtd_compras,
        SUM(co.valor_total)  AS faturamento
FROM compra co
INNER JOIN produto pr ON pr.id_produto = co.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15
SELECT  MONTH(data_registro) AS mes,
        COUNT(*)             AS qtd_registros,
        SUM(pontos)          AS total_pontos
FROM registro_pontos
GROUP BY MONTH(data_registro)
ORDER BY mes;

-- 6.16
SELECT  p.nome          AS professor,
        COUNT(*)        AS qtd_registros,
        SUM(rp.pontos)  AS total_pontos
FROM registro_pontos rp
INNER JOIN professor p ON p.id_prof = rp.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
ORDER BY total_pontos DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT nome AS aluno
FROM aluno
WHERE id_aluno IN (
    SELECT id_aluno FROM compra
    WHERE id_produto IN (
        SELECT id_produto FROM produto WHERE loja = 'Dedosdemel'
    )
);

-- 6.18
SELECT nome_produto AS produto, estoque
FROM produto
WHERE id_produto NOT IN (
    SELECT DISTINCT id_produto FROM compra
);

-- 6.19
SELECT nome AS aluno, saldo_galeoes AS saldo
FROM aluno
WHERE saldo_galeoes > (
    SELECT AVG(saldo_galeoes) FROM aluno
);

-- 6.20
SELECT nome AS professor, salario
FROM professor
WHERE salario > ALL (
    SELECT salario FROM professor WHERE id_casa IS NULL
);

-- 6.21
SELECT a.nome AS aluno, a.saldo_galeoes AS saldo
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
WHERE c.nome_casa <> 'Sonserina'
  AND a.saldo_galeoes > ANY (
      SELECT al.saldo_galeoes
      FROM aluno al
      INNER JOIN casa cs ON cs.id_casa = al.id_casa
      WHERE cs.nome_casa = 'Sonserina'
  );
-- > ANY equivale a: comparar com o MENOR valor da subconsulta. Um aluno passa no
-- filtro se seu saldo for maior que pelo menos um dos valores retornados, ou seja,
-- maior que o menor saldo da Sonserina.

-- 6.22
SELECT c.nome_casa AS casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa AND m.nota = 10
);

-- 6.23
SELECT a.nome AS aluno
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1 FROM compra co WHERE co.id_aluno = a.id_aluno
);

-- 6.24
SELECT  c.nome_casa                      AS casa,
        ROUND(AVG(media_aluno.media), 2) AS media_casa
FROM (
    SELECT a.id_aluno, a.id_casa, AVG(m.nota) AS media
    FROM aluno a
    INNER JOIN matricula m ON m.id_aluno = a.id_aluno
    GROUP BY a.id_aluno, a.id_casa
) AS media_aluno
INNER JOIN casa c ON c.id_casa = media_aluno.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT nome, 'Aluno'     AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- 6.26
SELECT a.nome FROM aluno a INNER JOIN compra          co ON co.id_aluno = a.id_aluno
UNION ALL
SELECT a.nome FROM aluno a INNER JOIN registro_pontos rp ON rp.id_aluno = a.id_aluno;

SELECT a.nome FROM aluno a INNER JOIN compra          co ON co.id_aluno = a.id_aluno
UNION
SELECT a.nome FROM aluno a INNER JOIN registro_pontos rp ON rp.id_aluno = a.id_aluno;
-- Linhas com UNION ALL: 27
-- Linhas com UNION: 12
-- Explicação: UNION ALL empilha todos os resultados sem eliminar repetições, por
-- isso aparece um nome para cada ocorrência em compra e outro para cada ocorrência
-- em registro_pontos. UNION aplica um DISTINCT implícito sobre o conjunto final,
-- mantendo apenas nomes únicos.

-- 6.27
SELECT 'Total de pontos distribuídos'   AS indicador, CAST(SUM(pontos)        AS CHAR) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja',              CAST(SUM(valor_total)   AS CHAR)         FROM compra
UNION ALL
SELECT 'Folha salarial dos professores',               CAST(SUM(salario)       AS CHAR)         FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres',                  CAST(SUM(saldo_galeoes) AS CHAR)         FROM aluno;


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 32
CREATE OR REPLACE VIEW vw_boletim AS
SELECT  a.nome                                    AS aluno,
        COALESCE(c.nome_casa, 'Sem casa')         AS casa,
        d.nome_disc                               AS disciplina,
        COALESCE(p.nome, 'Sem professor')         AS professor,
        m.nota,
        m.situacao
FROM matricula m
INNER JOIN aluno      a ON a.id_aluno = m.id_aluno
LEFT  JOIN casa       c ON c.id_casa  = a.id_casa
INNER JOIN disciplina d ON d.id_disc  = m.id_disc
LEFT  JOIN professor  p ON p.id_prof  = d.id_prof;

-- Questão 33
CREATE OR REPLACE VIEW vw_extrato_loja AS
SELECT  a.nome          AS aluno,
        pr.nome_produto AS produto,
        pr.loja,
        co.quantidade,
        co.valor_total,
        co.data_compra
FROM compra co
INNER JOIN aluno   a  ON a.id_aluno    = co.id_aluno
INNER JOIN produto pr ON pr.id_produto = co.id_produto;

-- Questão 34
CREATE OR REPLACE VIEW vw_alunos_destaque AS
SELECT  a.nome                           AS aluno,
        COALESCE(c.nome_casa, 'Sem casa') AS casa,
        ROUND(AVG(m.nota), 2)            AS media_notas
FROM aluno a
INNER JOIN matricula m ON m.id_aluno = a.id_aluno
LEFT  JOIN casa      c ON c.id_casa  = a.id_casa
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35
CREATE OR REPLACE VIEW vw_quadro_professores AS
SELECT  p.nome                                     AS professor,
        COALESCE(c.nome_casa, 'Não é diretor')     AS casa_que_dirige,
        (SELECT COUNT(*) FROM disciplina d
         WHERE d.id_prof = p.id_prof)              AS qtd_disciplinas,
        COALESCE(
            (SELECT SUM(rp.pontos)
             FROM registro_pontos rp
             WHERE rp.id_prof = p.id_prof), 0)     AS total_pontos
FROM professor p
LEFT JOIN casa c ON c.id_casa = p.id_casa;

-- Questão 36
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS faturamento
FROM vw_extrato_loja
GROUP BY loja;

SELECT * FROM vw_alunos_destaque ORDER BY media_notas DESC;

SELECT * FROM vw_quadro_professores ORDER BY total_pontos DESC;

-- Questão 37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');
SELECT * FROM vw_placar_casas;
-- O que mudou e por quê: A Lufa-Lufa passou de 50 para 70 pontos. A view não
-- armazena dados — ela é apenas uma consulta salva que é reexecutada a cada
-- chamada. Por isso, qualquer alteração nas tabelas subjacentes é refletida
-- imediatamente, sem necessidade de recriar a view.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39
CREATE USER IF NOT EXISTS 'filch'@'localhost'      IDENTIFIED BY 'MadameNorra#1';
CREATE USER IF NOT EXISTS 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER IF NOT EXISTS 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 40
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 41
GRANT INSERT, SELECT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT         ON hogwarts.aluno           TO 'mcgonagall'@'localhost';
GRANT SELECT         ON hogwarts.vw_boletim      TO 'mcgonagall'@'localhost';

-- Questão 42
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Questão 43
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 44
-- SELECT * FROM vw_placar_casas; → retorna o placar normalmente (permissão concedida)
-- SELECT * FROM aluno;           → Erro 1142: SELECT command denied to user 'filch'@'localhost' for table 'aluno'
-- Resultado de cada comando: o primeiro funciona pois filch tem SELECT na view;
-- o segundo é bloqueado pois filch não tem permissão alguma sobre a tabela aluno.

-- Questão 45
-- (Executar como mcgonagall)
-- INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
-- VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- → Funciona: mcgonagall tem INSERT em registro_pontos e a Grifinória ganha os pontos.
-- UPDATE casa SET pontos = 1000 WHERE id_casa = 1;
-- → Erro 1142: UPDATE command denied to user 'mcgonagall'@'localhost' for table 'casa'
-- Como o trigger conseguiu atualizar a casa: Triggers no MySQL executam com os
-- privilégios do usuário DEFINER (quem criou o trigger, geralmente root), e não
-- com os privilégios de quem disparou a operação. Por isso o trigger pôde fazer
-- UPDATE em casa mesmo que a mcgonagall não tenha essa permissão diretamente.

-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47
CREATE ROLE IF NOT EXISTS 'monitor';
GRANT SELECT ON hogwarts.vw_boletim      TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

CREATE USER IF NOT EXISTS 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';
-- Vantagem dos papéis: centralização e facilidade de manutenção. Se as permissões
-- do papel 'monitor' precisarem mudar (adicionar ou revogar uma view, por exemplo),
-- basta alterar o papel uma única vez e todos os usuários que o possuem são
-- afetados automaticamente. Sem papéis seria necessário executar GRANT/REVOKE
-- individualmente para cada monitor, aumentando o risco de inconsistência.

-- Questão 48
DROP USER IF EXISTS 'filch'@'localhost';
DROP USER IF EXISTS 'mcgonagall'@'localhost';
DROP USER IF EXISTS 'dumbledore'@'localhost';
DROP USER IF EXISTS 'percy'@'localhost';
DROP ROLE IF EXISTS 'monitor';