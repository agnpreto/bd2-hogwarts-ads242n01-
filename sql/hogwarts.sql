-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Damião Barbosa Nunes
-- Matrícula: 2422736
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
CREATE DATABASE hogwarts DEFAULT CHARACTER SET utf8mb4;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa   INT AUTO_INCREMENT,
    nome_casa VARCHAR(30) NOT NULL,
    fundador  VARCHAR(60),
    pontos    INT DEFAULT 0,
    CONSTRAINT pk_casa PRIMARY KEY (id_casa),
    CONSTRAINT uq_casa_nome UNIQUE (nome_casa)
);

-- Tabela professor
CREATE TABLE professor (
    id_prof          INT AUTO_INCREMENT,
    nome             VARCHAR(100) NOT NULL,
    salario          DECIMAL(10,2),
    data_contratacao DATE,
    id_casa          INT NULL,  -- casa que o professor dirige (NULL se não for diretor)
    CONSTRAINT pk_professor PRIMARY KEY (id_prof),
    CONSTRAINT chk_professor_salario CHECK (salario > 0),
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc    INT AUTO_INCREMENT,
    nome_disc  VARCHAR(60) NOT NULL,
    ano_minimo INT,
    id_prof    INT NULL,
    CONSTRAINT pk_disciplina PRIMARY KEY (id_disc),
    CONSTRAINT uq_disciplina_nome UNIQUE (nome_disc),
    CONSTRAINT chk_disciplina_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno      INT AUTO_INCREMENT,
    nome          VARCHAR(100) NOT NULL,
    ano_escolar   INT,
    id_casa       INT NULL,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT pk_aluno PRIMARY KEY (id_aluno),
    CONSTRAINT chk_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT chk_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc  INT,
    nota     DECIMAL(4,2),
    CONSTRAINT pk_matricula PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT chk_matricula_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (id_disc) REFERENCES disciplina (id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro   INT AUTO_INCREMENT,
    id_aluno      INT NOT NULL,
    id_prof       INT NOT NULL,
    pontos        INT NOT NULL,
    motivo        VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT pk_registro_pontos PRIMARY KEY (id_registro),
    CONSTRAINT fk_registro_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_registro_professor FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto   INT AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    loja         VARCHAR(50) NOT NULL,
    preco        DECIMAL(10,2),
    estoque      INT DEFAULT 0,
    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT chk_produto_preco CHECK (preco > 0),
    CONSTRAINT chk_produto_estoque CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra   INT AUTO_INCREMENT,
    id_aluno    INT,
    id_produto  INT,
    quantidade  INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT chk_compra_quantidade CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log    INT AUTO_INCREMENT,
    tabela    VARCHAR(30),
    operacao  VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log)
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: porque uma matrícula é identificada pelo par (aluno, disciplina):
-- o mesmo aluno não pode se matricular duas vezes na mesma disciplina, e a PK
-- composta garante isso. Com um id_matricula auto_increment, cada linha teria
-- um id diferente e o banco aceitaria matrículas duplicadas (ex.: Harry em
-- Poções duas vezes, com notas diferentes), a menos que se criasse um UNIQUE
-- extra em (id_aluno, id_disc).


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
    ('Grifinória', 'Godric Gryffindor'),   -- 1
    ('Sonserina',  'Salazar Slytherin'),   -- 2
    ('Corvinal',   'Rowena Ravenclaw'),    -- 3
    ('Lufa-Lufa',  'Helga Hufflepuff');    -- 4

-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
    ('Minerva McGonagall', 9500.00, '1956-12-01', 1),    -- 1
    ('Severo Snape',       8800.00, '1981-09-01', 2),    -- 2
    ('Fílio Flitwick',     8200.00, '1974-09-01', 3),    -- 3
    ('Pomona Sprout',      7900.00, '1972-09-01', 4),    -- 4
    ('Rúbeo Hagrid',       4500.00, '1993-09-01', NULL), -- 5
    ('Remo Lupin',         6200.00, '1993-09-01', NULL), -- 6
    ('Sibila Trelawney',   5100.00, '1980-09-01', NULL), -- 7
    ('Gilderoy Lockhart',  7000.00, '1992-09-01', NULL), -- 8
    ('Horácio Slughorn',   8000.00, '1996-09-01', NULL); -- 9

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
    ('Harry Potter',       5, 1, 120.00),  -- 1
    ('Hermione Granger',   5, 1,  85.00),  -- 2
    ('Rony Weasley',       5, 1,  12.00),  -- 3
    ('Neville Longbottom', 5, 1,  30.00),  -- 4
    ('Draco Malfoy',       5, 2, 500.00),  -- 5
    ('Pansy Parkinson',    5, 2, 150.00),  -- 6
    ('Vicente Crabbe',     5, 2,  40.00),  -- 7
    ('Luna Lovegood',      4, 3,  45.00),  -- 8
    ('Cho Chang',          6, 3, 200.00),  -- 9
    ('Padma Patil',        5, 3,  60.00),  -- 10
    ('Cedrico Diggory',    7, 4, 180.00),  -- 11
    ('Ana Abbott',         5, 4,  25.00),  -- 12
    ('Ernesto Macmillan',  5, 4,  70.00),  -- 13
    ('Teddy Lupin',        1, NULL, 0.00); -- 14 (ainda não passou pelo Chapéu Seletor)

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
    ('Varinha de Azevinho',              'Olivaras',               7.00,  10), -- 1
    ('Vassoura Nimbus 2001',             'Artigos de Quadribol', 300.00,   3), -- 2
    ('Sapo de Chocolate',                'Dedosdemel',             2.00, 200), -- 3
    ('Feijõezinhos de Todos os Sabores', 'Dedosdemel',             1.50, 150), -- 4
    ('Livro Monstruoso dos Monstros',    'Floreios e Borrões',    12.00,  20), -- 5
    ('Caldeirão de Estanho',             'Caldeirões Potage',      9.00,   0), -- 6
    ('Kit de Logros',                    'Gemialidades Weasley',  25.00,  40), -- 7
    ('Pena de Repetição Rápida',         'Escribbulus',           15.00,   5); -- 8

-- Confira: SELECT COUNT(*) de cada tabela
-- Esperado: 4 casas, 9 professores, 9 disciplinas, 14 alunos, 35 matrículas, 8 produtos
SELECT 'casa' AS tabela, COUNT(*) AS total FROM casa
UNION ALL SELECT 'professor',  COUNT(*) FROM professor
UNION ALL SELECT 'disciplina', COUNT(*) FROM disciplina
UNION ALL SELECT 'aluno',      COUNT(*) FROM aluno
UNION ALL SELECT 'matricula',  COUNT(*) FROM matricula
UNION ALL SELECT 'produto',    COUNT(*) FROM produto;


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

-- Confira (DESC de cada tabela alterada)
DESC aluno;
DESC matricula;
DESC produto;
DESC casa;
DESC professor;

-- Questão 6
UPDATE aluno
   SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
   SET nota = LEAST(nota + 0.5, 10)
 WHERE id_disc IN (SELECT id_disc
                     FROM disciplina
                    WHERE id_prof IN (SELECT id_prof
                                        FROM professor
                                       WHERE nome = 'Remo Lupin'));

-- Confira: Harry tem 10.00 em Defesa Contra as Artes das Trevas
SELECT a.nome, d.nome_disc, m.nota
  FROM matricula m
  JOIN aluno a      ON a.id_aluno = m.id_aluno
  JOIN disciplina d ON d.id_disc  = m.id_disc
 WHERE a.nome = 'Harry Potter' AND d.nome_disc = 'Defesa Contra as Artes das Trevas';

-- Questão 9
UPDATE matricula
   SET situacao = CASE
                      WHEN nota >= 6 THEN 'Aprovado'
                      ELSE 'Reprovado'
                  END;

-- Confira: 7 matrículas reprovadas
SELECT COUNT(*) AS reprovadas FROM matricula WHERE situacao = 'Reprovado';

-- Questão 10
UPDATE professor
   SET salario = salario * 1.10
 WHERE id_casa IS NOT NULL
   AND data_admissao < '1980-01-01';

-- Confira: Minerva McGonagall ganha 10450.00
SELECT nome, salario FROM professor WHERE nome = 'Minerva McGonagall';

-- Questão 11
UPDATE produto SET ativo = 'N' WHERE estoque = 0;

-- Questão 12
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';

-- Confira: Sapo de Chocolate custa 1.60
SELECT nome_produto, preco FROM produto WHERE nome_produto = 'Sapo de Chocolate';


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key
--       constraint fails (`hogwarts`.`aluno`, CONSTRAINT `fk_aluno_casa`
--       FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: a Sonserina (id 2) é referenciada por outras tabelas: o Snape é
-- diretor dela (professor.id_casa) e Draco e Pansy são alunos dela
-- (aluno.id_casa). Apagar a casa deixaria essas linhas apontando para uma casa
-- que não existe, então a chave estrangeira bloqueia a exclusão.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro: Error Code: 3819. Check constraint 'chk_aluno_ano' is violated.
-- Explicação: a restrição CHECK só aceita ano_escolar entre 1 e 7. Como Hogwarts
-- não tem 8º ano, o banco recusa a linha.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key
--       'aluno.uq_aluno_email'
-- Explicação: a restrição UNIQUE uq_aluno_email (questão 7) impede dois alunos
-- com o mesmo e-mail. O e-mail já pertence ao Harry Potter verdadeiro.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key
--       constraint fails (`hogwarts`.`disciplina`, CONSTRAINT
--       `fk_disciplina_professor` FOREIGN KEY (`id_prof`) REFERENCES
--       `professor` (`id_prof`))
-- Explicação: o Snape ministra a disciplina Poções (disciplina.id_prof = 2).
-- Excluir o professor deixaria a disciplina apontando para um professor
-- inexistente, então a FK bloqueia (integridade referencial).

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Por que funciona: o Lockhart (id 8) não ministra nenhuma disciplina, não é
-- diretor de casa e não tem registros de pontos. Nenhuma linha de outra tabela
-- aponta para ele, então não há chave estrangeira a violar. O Snape, ao
-- contrário, é referenciado pela disciplina Poções.

-- Questão 18
DELETE FROM matricula
 WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
 WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Confira: 8 professores, 13 alunos, 8 disciplinas e 33 matrículas
SELECT 'professor' AS tabela, COUNT(*) AS total FROM professor
UNION ALL SELECT 'aluno',      COUNT(*) FROM aluno
UNION ALL SELECT 'disciplina', COUNT(*) FROM disciplina
UNION ALL SELECT 'matricula',  COUNT(*) FROM matricula;


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
    DECLARE v_estoque INT;
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_saldo   DECIMAL(10,2);

    SELECT estoque, preco INTO v_estoque, v_preco
      FROM produto
     WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
      FROM aluno
     WHERE id_aluno = NEW.id_aluno;

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
    IF NOT (NEW.nota <=> OLD.nota) THEN
        SET NEW.situacao = CASE
                               WHEN NEW.nota >= 6 THEN 'Aprovado'
                               ELSE 'Reprovado'
                           END;
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
        VALUES ('professor', 'UPDATE',
                CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: a validação precisa acontecer ANTES da gravação para poder impedir
-- a compra (com SIGNAL) e para preencher NEW.valor_total; num trigger AFTER a
-- linha já foi gravada e NEW não pode mais ser alterado. Já a baixa de estoque
-- e de saldo só deve acontecer DEPOIS que a compra foi de fato gravada: se
-- fosse BEFORE e a inserção falhasse por outro motivo (ex.: uma FK ou CHECK),
-- teríamos descontado estoque/saldo de uma compra que não existe. No AFTER
-- também já temos o valor_total calculado pelo trigger BEFORE.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
    ( 2, 3,  20, 'Feitiço de levitação perfeito',         '2026-09-10'),
    ( 1, 2, -10, 'Atraso na aula de Poções',              '2026-09-12'),
    ( 5, 2,  15, 'Poção do Morto-Vivo impecável',         '2026-09-12'),
    ( 8, 5,  10, 'Cuidou de um testrálio ferido',         '2026-09-20'),
    (11, 4,  25, 'Ajudou os alunos do 1º ano',            '2026-09-25'),
    ( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia',  '2026-10-02'),
    ( 6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
    ( 1, 6,  50, 'Conjurou um Patrono corpóreo',          '2026-10-15'),
    ( 9, 3,  15, 'Duelo exemplar no Clube de Duelos',     '2026-10-18'),
    ( 5, 1, -30, 'Duelo proibido no corredor',            '2026-10-31'),
    (10, 7,   5, 'Interpretação da bola de cristal',      '2026-11-03'),
    (13, 4,  10, 'Colheita de mandrágoras',               '2026-11-05'),
    ( 3, 9,  10, 'Identificou um bezoar',                 '2026-11-06'),
    ( 8, 3,  20, 'Resposta brilhante sobre o Diadema',    '2026-11-08'),
    ( 6, 2,  25, 'Antídoto para venenos comuns',          '2026-11-09'),
    ( 5, 9,  40, 'Melhor poção do Clube do Slugue',       '2026-11-09');

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
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Galeões insuficientes no cofre do aluno
-- A Nimbus ainda tem estoque (2), mas custa 300.00 e o Rony só tem 6.00
-- galeões (12.00 - 6.00 dos feijõezinhos). O trigger trg_valida_compra
-- dispara o SIGNAL e a compra não é gravada.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Estoque insuficiente no Beco Diagonal
-- O Caldeirão de Estanho tem estoque 0 (menor que a quantidade 1). A
-- Hermione tem saldo, mas o estoque é verificado primeiro e a compra é bloqueada.

-- Questão 25 - Recuperação do Rony em Poções
SELECT m.nota, m.situacao
  FROM matricula m
 WHERE m.id_aluno = 3
   AND m.id_disc = (SELECT id_disc FROM disciplina WHERE nome_disc = 'Poções');
-- Antes: 4.50 / Reprovado

UPDATE matricula
   SET nota = 6.5
 WHERE id_aluno = 3
   AND id_disc = (SELECT id_disc FROM disciplina WHERE nome_disc = 'Poções');

SELECT m.nota, m.situacao
  FROM matricula m
 WHERE m.id_aluno = 3
   AND m.id_disc = (SELECT id_disc FROM disciplina WHERE nome_disc = 'Poções');
-- Depois: 6.50 / Aprovado. O trigger trg_situacao_nota recalculou a situação
-- sozinho, sem que o UPDATE mexesse na coluna situacao.

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';

SELECT * FROM log_auditoria;
-- Linhas em log_auditoria: 1 ('Rúbeo Hagrid: salário de 4500.00 para 5000.00').
-- O segundo UPDATE também disparou o trigger, mas como OLD.salario = NEW.salario
-- o IF não gravou nada.
-- Por que o reajuste da questão 10 não aparece: o trigger trg_audita_salario
-- foi criado depois da questão 10. Um trigger só age sobre operações feitas
-- após a sua criação; ele não processa alterações passadas.

-- Confira: placar Grifinória 100, Corvinal 50, Lufa-Lufa 35, Sonserina 30;
-- Draco 200.00, Harry 54.00; Nimbus estoque 2, Sapo de Chocolate 170;
-- soma de valor_total 474.00; log_auditoria com 1 linha
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno IN (1, 5);
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) AS soma_compras FROM compra;
SELECT COUNT(*) AS linhas_log FROM log_auditoria;


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Confira: Draco 150.00 e Pansy 168.00
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;   -- todas as casas com 0
ROLLBACK;
SELECT nome_casa, pontos FROM casa;   -- placar original de volta
-- Sim, o placar voltou: o ROLLBACK desfez o UPDATE porque ele não tinha sido
-- confirmado (COMMIT).

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;    -- 47.00
SELECT estoque FROM produto WHERE id_produto = 1;      -- 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;    -- 54.00
SELECT estoque FROM produto WHERE id_produto = 1;      -- 9
-- As alterações feitas pelo trigger (baixa de saldo e de estoque) também foram
-- desfeitas. O trigger roda dentro da mesma transação do INSERT que o
-- disparou, então o ROLLBACK desfaz tudo junto: a compra e os efeitos do trigger.

-- Questão 29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Confira: Grifinória 100, Corvinal 50, Lufa-Lufa 50, Sonserina 30;
-- registro_pontos com 17 linhas
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT COUNT(*) AS registros FROM registro_pontos;

-- Questão 30
SELECT @@autocommit;
-- Resposta: o valor 1 significa que o autocommit está ligado: cada comando
-- executado fora de um START TRANSACTION é confirmado automaticamente, como se
-- tivesse um COMMIT logo depois (0 significaria que é preciso dar COMMIT
-- manualmente). Se for executado um CREATE TABLE (ou outro comando DDL) no
-- meio de uma transação aberta, o MySQL faz um COMMIT implícito: tudo o que
-- estava pendente é confirmado e a transação termina. Um ROLLBACK depois disso
-- não desfaz mais nada.


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT p.nome, p.salario
  FROM professor p
 WHERE p.salario BETWEEN 6000.00 AND 9000.00
 ORDER BY p.salario DESC;

-- 6.2
SELECT a.nome, a.ano_escolar
  FROM aluno a
 WHERE a.ano_escolar IN (1, 4, 6, 7)
 ORDER BY a.ano_escolar;

-- 6.3
SELECT a.nome
  FROM aluno a
 WHERE a.nome LIKE '_a%';

-- 6.4
SELECT d.nome_disc
  FROM disciplina d
 WHERE d.id_prof IS NULL;

-- 6.5
SELECT p.nome_produto, p.preco
  FROM produto p
 WHERE p.preco NOT BETWEEN 5 AND 20
 ORDER BY p.preco;

-- 6.6
SELECT DISTINCT p.loja
  FROM produto p
 ORDER BY p.loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
  FROM aluno a
 INNER JOIN casa c ON c.id_casa = a.id_casa
 ORDER BY c.nome_casa, a.nome;
-- Quantos alunos e por quê: aparecem 12 alunos. Existem 13 alunos, mas o
-- INNER JOIN só traz as linhas que têm correspondência nas duas tabelas. O
-- Teddy Lupin tem id_casa NULL (ainda não passou pelo Chapéu Seletor), então
-- não casa com nenhuma linha de casa e fica de fora.

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
SELECT a.nome      AS aluno,
       d.nome_disc AS disciplina,
       p.nome      AS professor,
       m.nota,
       m.situacao
  FROM aluno a
 INNER JOIN casa c       ON c.id_casa  = a.id_casa
 INNER JOIN matricula m  ON m.id_aluno = a.id_aluno
 INNER JOIN disciplina d ON d.id_disc  = m.id_disc
  LEFT JOIN professor p  ON p.id_prof  = d.id_prof   -- LEFT: Runas Antigas não tem professor
 WHERE c.nome_casa = 'Grifinória'
 ORDER BY a.nome, d.nome_disc;

-- 6.11
SELECT co.id_compra    AS numero_compra,
       a.nome          AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
  FROM compra co
 INNER JOIN aluno a    ON a.id_aluno    = co.id_aluno
 INNER JOIN produto pr ON pr.id_produto = co.id_produto
 ORDER BY co.data_compra, co.id_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc            AS disciplina,
       COUNT(m.id_aluno)      AS qtd_alunos,
       ROUND(AVG(m.nota), 2)  AS media,
       MAX(m.nota)            AS maior_nota,
       MIN(m.nota)            AS menor_nota
  FROM disciplina d
 INNER JOIN matricula m ON m.id_disc = d.id_disc
 GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
 ORDER BY media DESC;

-- 6.13
SELECT c.nome_casa                                             AS casa,
       COUNT(rp.id_registro)                                   AS qtd_registros,
       SUM(CASE WHEN rp.pontos > 0 THEN rp.pontos ELSE 0 END)  AS pontos_ganhos,
       SUM(CASE WHEN rp.pontos < 0 THEN rp.pontos ELSE 0 END)  AS pontos_perdidos,
       COALESCE(SUM(rp.pontos), 0)                             AS saldo
  FROM casa c
  LEFT JOIN aluno a           ON a.id_casa  = c.id_casa
  LEFT JOIN registro_pontos rp ON rp.id_aluno = a.id_aluno
 GROUP BY c.id_casa, c.nome_casa
 ORDER BY saldo DESC;

-- 6.14
SELECT pr.loja,
       COUNT(co.id_compra) AS qtd_compras,
       SUM(co.valor_total) AS faturamento
  FROM compra co
 INNER JOIN produto pr ON pr.id_produto = co.id_produto
 GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
 ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(rp.data_registro) AS mes,
       COUNT(*)                AS qtd_registros,
       SUM(rp.pontos)          AS total_pontos
  FROM registro_pontos rp
 GROUP BY MONTH(rp.data_registro)
 ORDER BY mes;

-- 6.16
SELECT p.nome           AS professor,
       COUNT(*)         AS qtd_registros,
       SUM(rp.pontos)   AS total_concedido
  FROM registro_pontos rp
 INNER JOIN professor p ON p.id_prof = rp.id_prof
 GROUP BY p.id_prof, p.nome
HAVING COUNT(*) >= 2
 ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT a.nome
  FROM aluno a
 WHERE a.id_aluno IN (SELECT co.id_aluno
                        FROM compra co
                       WHERE co.id_produto IN (SELECT pr.id_produto
                                                 FROM produto pr
                                                WHERE pr.loja = 'Dedosdemel'));

-- 6.18
SELECT pr.nome_produto, pr.estoque
  FROM produto pr
 WHERE pr.id_produto NOT IN (SELECT co.id_produto FROM compra co);

-- 6.19
SELECT a.nome, a.saldo_galeoes
  FROM aluno a
 WHERE a.saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20
SELECT p.nome, p.salario
  FROM professor p
 WHERE p.salario > ALL (SELECT p2.salario
                          FROM professor p2
                         WHERE p2.id_casa IS NULL);

-- 6.21
SELECT a.nome, a.saldo_galeoes
  FROM aluno a
 WHERE a.id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
   AND a.saldo_galeoes > ANY (SELECT a2.saldo_galeoes
                                FROM aluno a2
                               WHERE a2.id_casa = (SELECT id_casa FROM casa
                                                    WHERE nome_casa = 'Sonserina'));
-- > ANY equivale a: comparar com o MENOR valor da subconsulta. Basta o saldo
-- ser maior que o de pelo menos um sonserino, e isso acontece sempre que ele é
-- maior que o menor saldo da Sonserina (aqui, 150.00 do Draco).
-- (> ALL, ao contrário, equivale a comparar com o maior valor.)

-- 6.22
SELECT c.nome_casa
  FROM casa c
 WHERE EXISTS (SELECT 1
                 FROM aluno a
                INNER JOIN matricula m ON m.id_aluno = a.id_aluno
                WHERE a.id_casa = c.id_casa
                  AND m.nota = 10);

-- 6.23
SELECT a.nome
  FROM aluno a
 WHERE NOT EXISTS (SELECT 1
                     FROM compra co
                    WHERE co.id_aluno = a.id_aluno);

-- 6.24
SELECT c.nome_casa                    AS casa,
       ROUND(AVG(ma.media_aluno), 2)  AS media_casa
  FROM (SELECT m.id_aluno, AVG(m.nota) AS media_aluno
          FROM matricula m
         GROUP BY m.id_aluno) AS ma
 INNER JOIN aluno a ON a.id_aluno = ma.id_aluno
 INNER JOIN casa c  ON c.id_casa  = a.id_casa
 GROUP BY c.id_casa, c.nome_casa
 ORDER BY media_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT a.nome, 'Aluno' AS vinculo FROM aluno a
UNION ALL
SELECT p.nome, 'Professor' AS vinculo FROM professor p
ORDER BY nome;

-- 6.26
SELECT a.nome
  FROM aluno a
 INNER JOIN compra co ON co.id_aluno = a.id_aluno
UNION ALL
SELECT a.nome
  FROM aluno a
 INNER JOIN registro_pontos rp ON rp.id_aluno = a.id_aluno;

SELECT a.nome
  FROM aluno a
 INNER JOIN compra co ON co.id_aluno = a.id_aluno
UNION
SELECT a.nome
  FROM aluno a
 INNER JOIN registro_pontos rp ON rp.id_aluno = a.id_aluno;
-- Linhas com UNION ALL: 27
-- Linhas com UNION: 12
-- Explicação: o UNION ALL junta os dois resultados como estão, mantendo as
-- repetições (10 linhas de compras + 17 de registros de pontos = 27; o Harry,
-- por exemplo, aparece várias vezes). O UNION elimina as linhas duplicadas e
-- devolve cada nome uma única vez: são 12 alunos diferentes que compraram ou
-- receberam pontos. Por precisar eliminar duplicatas, o UNION é mais custoso.

-- 6.27
SELECT 'Total de pontos distribuídos'  AS indicador, SUM(pontos)        AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja',            SUM(valor_total)            FROM compra
UNION ALL
SELECT 'Folha salarial dos professores',             SUM(salario)                FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos',     SUM(saldo_galeoes)          FROM aluno;
