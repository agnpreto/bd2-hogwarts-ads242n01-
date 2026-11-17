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

-- Questão 13 - tentar excluir a casa 'Sonserina' (deve FALHAR)
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro esperado: ERROR 1451 (23000): Cannot delete or update a parent row:
-- a foreign key constraint fails (`hogwarts`.`professor`, CONSTRAINT
-- `fk_prof_casa` FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: a casa é referenciada por professores e alunos (FK), então o
-- banco impede a exclusão para não deixar registros órfãos.

-- Questão 14 - aluno 'Dobby' no 8º ano (deve FALHAR)
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes)
-- VALUES ('Dobby', 8, 1, 0.00);
-- Erro esperado: ERROR 3819 (HY000): Check constraint 'chk_aluno_ano' is violated.
-- Explicação: a CHECK garante ano_escolar entre 1 e 7; 8 viola a regra.

-- Questão 15 - e-mail duplicado 'harry.potter@hogwarts.edu' (deve FALHAR)
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0.00, 'harry.potter@hogwarts.edu');
-- Erro esperado: ERROR 1062 (23000): Duplicate entry 'harry.potter@hogwarts.edu'
-- for key 'aluno.uq_aluno_email'
-- Explicação: a UNIQUE uq_aluno_email impede dois alunos com o mesmo e-mail.

-- Questão 16 - tentar excluir o professor 'Severo Snape' (deve FALHAR)
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro esperado: ERROR 1451 (23000): Cannot delete or update a parent row:
-- a foreign key constraint fails (`hogwarts`.`disciplina`, CONSTRAINT
-- `fk_disc_prof` FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`))
-- Explicação: Snape é referenciado por disciplinas e registros de pontos.

-- Questão 17 - excluir Gilderoy Lockhart (FUNCIONA)
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Por que funciona: Lockhart não dirige casa, não ministra disciplina
-- (a disciplina 6 é do Lupin) e não tem registros de pontos. Nenhuma FK aponta para ele.

-- Questão 18 - remover Vicente Crabbe (primeiro matrículas, depois aluno)
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19 - excluir disciplinas sem alunos matriculados
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT DISTINCT id_disc FROM matricula);


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================

-- Questão 20 - trg_pontos_casa: soma/subtrai pontos na casa do aluno
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

-- Questão 21 - trg_valida_compra: valida estoque e saldo, calcula valor_total
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);

    SELECT estoque, preco INTO v_estoque, v_preco
    FROM produto WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < v_preco * NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$
DELIMITER ;

-- Questão 22 - trg_baixa_compra: baixa estoque e desconta saldo
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

-- Questão 23 - trg_situacao_nota: recalcula situacao quando a nota muda
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NEW.nota <> OLD.nota THEN
        SET NEW.situacao = CASE WHEN NEW.nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;
    END IF;
END$$
DELIMITER ;

-- Questão 24 - trg_audita_salario: registra mudança de salário
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
-- Resposta: A validação precisa ser BEFORE porque ela pode bloquear a operação
-- (SIGNAL) e precisa calcular NEW.valor_total antes da linha ser gravada.
-- A baixa é AFTER porque só deve acontecer depois que a compra foi aceita
-- e gravada — se fosse BEFORE e a validação falhasse, o estoque já teria
-- sido alterado indevidamente.


-- =====================================================================
-- 4.1 TESTANDO OS TRIGGERS (Questão 25)
-- =====================================================================

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3,  20, 'Feitiço de levitação perfeito',        '2026-09-10'),
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

-- Questão 25 - INSERT compra (sem valor_total, o trigger calcula)
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

-- Questão 25 - Rony tenta comprar a Nimbus 2001 (id 2)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado: ERRO 1644 (45000): Estoque insuficiente no Beco Diagonal.
-- Explicação: a Nimbus tem estoque 2 (após a compra do Draco) e o Rony
-- tem só 12 galeões — mas o estoque já bloqueia antes do saldo.

-- Questão 25 - Hermione tenta comprar o Caldeirão de Estanho (id 6)
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado: ERRO 1644 (45000): Estoque insuficiente no Beco Diagonal.
-- Explicação: o Caldeirão de Estanho tem estoque 0 desde a carga inicial.

-- Questão 25 - Recuperação do Rony em Poções (id 2)
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
-- Depois do UPDATE, o trigger trg_situacao_nota muda situacao para 'Aprovado'.

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
-- Linhas em log_auditoria: 1 (só a mudança de salário).
-- Por que o reajuste da questão 10 não aparece: o trigger trg_audita_salario
-- foi criado DEPOIS da questão 10, então aquele UPDATE aconteceu antes do
-- trigger existir. Além disso, o UPDATE da data_admissao não altera salario,
-- então o IF OLD.salario <> NEW.salario é falso e nada é gravado.


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================

-- Questão 26 - transferência confirmada: Draco (5) -> Pansy (6), 50 galeões
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE id_aluno = 5;
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE id_aluno = 6;
COMMIT;

-- Questão 27 - O Pirraça atacou: zera pontos, consulta, ROLLBACK, consulta
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT 'Placar DENTRO da transação (zerado):' AS etapa;
SELECT * FROM casa;
ROLLBACK;
SELECT 'Placar APÓS o ROLLBACK (voltou):' AS etapa;
SELECT * FROM casa;
-- Resposta: sim, o placar voltou ao estado anterior porque o ROLLBACK
-- desfez o UPDATE feito dentro da transação.

-- Questão 28 - Trigger dentro da transação: compra da Varinha pelo Harry
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');

SELECT 'DENTRO da transação - saldo do Harry e estoque da varinha:' AS etapa;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;

ROLLBACK;

SELECT 'APÓS o ROLLBACK - saldo do Harry e estoque da varinha:' AS etapa;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
-- Resposta: dentro da transação Harry tem 47.00 e a varinha estoque 8
-- (o trigger trg_baixa_compra rodou). Após o ROLLBACK, voltam para 54.00
-- e 9, porque a alteração feita pelo trigger também é desfeita — triggers
-- participam da mesma transação da operação que os disparou.

-- Questão 29 - SAVEPOINT
START TRANSACTION;

-- a. 15 pontos para Ana Abbott (12), professora Sprout (4)
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

-- b. savepoint
SAVEPOINT sp_pontos_legitimos;

-- c. 100 pontos para Pansy (6), Snape (2) — favoritismo
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');

-- d. volta ao savepoint e confirma
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;
-- Resultado final: os 15 pontos da Ana ficam (Sonserina não recebe os 100 da Pansy).
-- Placar final: Grifinória 100, Corvinal 50, Lufa-Lufa 50, Sonserina 30.

-- Questão 30 - pergunta conceitual
SELECT @@autocommit;
-- Resposta: o valor 1 indica que o autocommit está LIGADO — cada comando
-- é confirmado automaticamente. Se você executar um CREATE TABLE no meio
-- de uma transação aberta, o MySQL faz um COMMIT implícito antes do DDL
-- (DDL causa commit automático), encerrando a transação em andamento.


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================

-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1 Faixa salarial (BETWEEN)
SELECT nome, salario
FROM professor
WHERE salario BETWEEN 6000.00 AND 9000.00
ORDER BY salario DESC;

-- 6.2 Anos selecionados (IN)
SELECT nome, ano_escolar
FROM aluno
WHERE ano_escolar IN (1, 4, 6, 7)
ORDER BY ano_escolar;

-- 6.3 Busca por padrão (LIKE com _)
SELECT nome
FROM aluno
WHERE nome LIKE '_a%';

-- 6.4 Disciplina órfã (IS NULL)
SELECT nome_disc
FROM disciplina
WHERE id_prof IS NULL;

-- 6.5 Fora da faixa (NOT BETWEEN)
SELECT nome_produto, preco
FROM produto
WHERE preco NOT BETWEEN 5.00 AND 20.00
ORDER BY preco;

-- 6.6 Lojas do Beco Diagonal (DISTINCT)
SELECT DISTINCT loja
FROM produto
ORDER BY loja;

-- ---------- Nível 2: JOINs ----------

-- 6.7 Quem é de qual casa (INNER JOIN)
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
ORDER BY c.nome_casa, a.nome;
-- Quantos alunos: 12. Por que não 13: o Teddy Lupin tem id_casa NULL
-- (ainda não passou pelo Chapéu Seletor), então o INNER JOIN o exclui.

-- 6.8 Todos os alunos (LEFT JOIN)
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa
ORDER BY a.nome;

-- 6.9 Professor sem turma (RIGHT JOIN)
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;

-- 6.10 Boletim da Grifinória (JOIN com 5 tabelas)
SELECT a.nome AS aluno,
       d.nome_disc AS disciplina,
       p.nome AS professor,
       m.nota,
       m.situacao
FROM matricula m
INNER JOIN aluno a ON m.id_aluno = a.id_aluno
INNER JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- 6.11 Extrato do Beco Diagonal (JOIN com 3 tabelas)
SELECT co.id_compra,
       a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
INNER JOIN aluno a ON co.id_aluno = a.id_aluno
INNER JOIN produto pr ON co.id_produto = pr.id_produto
ORDER BY co.data_compra;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12 Desempenho por disciplina
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS qtd_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
INNER JOIN matricula m ON d.id_disc = m.id_disc
GROUP BY d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13 Livro-razão da Taça
SELECT c.nome_casa AS casa,
       COUNT(rp.id_registro) AS qtd_registros,
       SUM(CASE WHEN rp.pontos > 0 THEN rp.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN rp.pontos < 0 THEN rp.pontos ELSE 0 END) AS pontos_perdidos,
       SUM(rp.pontos) AS saldo
FROM casa c
LEFT JOIN aluno a ON c.id_casa = a.id_casa
LEFT JOIN registro_pontos rp ON a.id_aluno = rp.id_aluno
GROUP BY c.nome_casa;

-- 6.14 Faturamento por loja
SELECT pr.loja,
       COUNT(co.id_compra) AS qtd_compras,
       SUM(co.valor_total) AS faturamento
FROM produto pr
INNER JOIN compra co ON pr.id_produto = co.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15 Pontos por mês
SELECT MONTH(rp.data_registro) AS mes,
       COUNT(rp.id_registro) AS qtd_registros,
       SUM(rp.pontos) AS total_pontos
FROM registro_pontos rp
GROUP BY MONTH(rp.data_registro)
ORDER BY mes;

-- 6.16 Professores mais ativos
SELECT p.nome AS professor,
       COUNT(rp.id_registro) AS qtd_registros,
       SUM(rp.pontos) AS total_concedido
FROM professor p
INNER JOIN registro_pontos rp ON p.id_prof = rp.id_prof
GROUP BY p.nome
HAVING COUNT(rp.id_registro) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17 Clientes da Dedosdemel (IN, subconsultas aninhadas, sem JOIN)
SELECT nome
FROM aluno
WHERE id_aluno IN (
    SELECT id_aluno FROM compra
    WHERE id_produto IN (
        SELECT id_produto FROM produto WHERE loja = 'Dedosdemel'
    )
);

-- 6.18 Encalhados (NOT IN)
SELECT nome_produto, estoque
FROM produto
WHERE id_produto NOT IN (SELECT id_produto FROM compra);

-- 6.19 Cofres cheios (subconsulta escalar)
SELECT nome, saldo_galeoes
FROM aluno
WHERE saldo_galeoes > (SELECT AVG(saldo_galeoes) FROM aluno);

-- 6.20 Acima de todos (ALL)
SELECT nome, salario
FROM professor
WHERE salario > ALL (
    SELECT salario FROM professor WHERE id_casa IS NULL
);

-- 6.21 Mais rico que algum sonserino (ANY)
SELECT nome, saldo_galeoes
FROM aluno
WHERE id_casa <> 2
  AND saldo_galeoes > ANY (
      SELECT saldo_galeoes FROM aluno WHERE id_casa = 2
  );
-- > ANY equivale a comparar com o MENOR valor da subconsulta
-- (basta ser maior que pelo menos um). No caso, > ANY (Sonserina) é
-- equivalente a > (SELECT MIN(saldo_galeoes) FROM aluno WHERE id_casa = 2).

-- 6.22 Casas com nota máxima (EXISTS)
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m ON a.id_aluno = m.id_aluno
    WHERE a.id_casa = c.id_casa AND m.nota = 10
);

-- 6.23 Nunca foram ao Beco (NOT EXISTS)
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1 FROM compra co WHERE co.id_aluno = a.id_aluno
);

-- 6.24 Média das médias (subconsulta no FROM)
SELECT c.nome_casa,
       ROUND(AVG(media_aluno), 2) AS media_casa
FROM (
    SELECT a.id_aluno, a.id_casa, AVG(m.nota) AS media_aluno
    FROM aluno a
    INNER JOIN matricula m ON a.id_aluno = m.id_aluno
    GROUP BY a.id_aluno, a.id_casa
) AS medias
INNER JOIN casa c ON medias.id_casa = c.id_casa
GROUP BY c.nome_casa
ORDER BY media_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25 Diretório de Hogwarts
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome;

-- 6.26 UNION x UNION ALL
-- Com UNION ALL (mantém duplicatas):
SELECT a.nome
FROM aluno a
INNER JOIN compra co ON a.id_aluno = co.id_aluno
UNION ALL
SELECT a.nome
FROM aluno a
INNER JOIN registro_pontos rp ON a.id_aluno = rp.id_aluno;
-- Linhas com UNION ALL: 27

-- Com UNION (remove duplicatas):
SELECT a.nome
FROM aluno a
INNER JOIN compra co ON a.id_aluno = co.id_aluno
UNION
SELECT a.nome
FROM aluno a
INNER JOIN registro_pontos rp ON a.id_aluno = rp.id_aluno;
-- Linhas com UNION: 12
-- Explicação: o UNION ALL mantém todas as linhas (inclusive repetidas,
-- pois um aluno pode ter várias compras e vários registros de pontos).
-- O UNION remove duplicatas, deixando só um nome por aluno.

-- 6.27 Painel do Diretor
SELECT 'Total de pontos distribuídos' AS indicador,
       SUM(pontos) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', SUM(valor_total) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', SUM(salario) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', SUM(saldo_galeoes) FROM aluno;


-- =====================================================================
-- 7. VIEWS
-- =====================================================================

-- Questão 31 - vw_alunos_casas: nome do aluno, casa e ano escolar
CREATE VIEW vw_alunos_casas AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       a.ano_escolar
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa;

-- Questão 32 - vw_boletim: aluno, disciplina, nota e situação
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       d.nome_disc AS disciplina,
       m.nota,
       m.situacao
FROM matricula m
INNER JOIN aluno a ON m.id_aluno = a.id_aluno
INNER JOIN disciplina d ON m.id_disc = d.id_disc;

-- Questão 33 - vw_placar_casas: casa e pontos
CREATE VIEW vw_placar_casas AS
SELECT nome_casa AS casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 34 - vw_professores_salarios: nome, salário e casa que dirige
CREATE VIEW vw_professores_salarios AS
SELECT p.nome AS professor,
       p.salario,
       COALESCE(c.nome_casa, 'Sem casa') AS casa_dirigida
FROM professor p
LEFT JOIN casa c ON p.id_casa = c.id_casa;

-- Questão 35 - vw_compras_detalhadas: compra, aluno, produto, loja, qtd, valor, data
CREATE VIEW vw_compras_detalhadas AS
SELECT co.id_compra,
       a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
INNER JOIN aluno a ON co.id_aluno = a.id_aluno
INNER JOIN produto pr ON co.id_produto = pr.id_produto;

-- Questão 36 - vw_produtos_estoque: produto, loja, preço, estoque e ativo
CREATE VIEW vw_produtos_estoque AS
SELECT nome_produto AS produto,
       loja,
       preco,
       estoque,
       ativo
FROM produto;

-- Questão 37 - atualizar uma view e ver o que muda
-- Atualiza o preço de um produto através da view vw_produtos_estoque
UPDATE vw_produtos_estoque SET preco = 8.00 WHERE produto = 'Varinha de Azevinho';
-- O que mudou e por quê: o preço foi atualizado na tabela base produto.
-- Views simples (uma tabela, sem agregação) são atualizáveis no MySQL, então
-- a alteração na view reflete diretamente na tabela original.

-- Questão 38 - remover uma view
DROP VIEW vw_placar_casas;
-- A view vw_placar_casas foi removida. As demais continuam existindo.


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- As questões abaixo criam usuários e papéis. Em um MySQL local, o usuário
-- root tem permissão para isso. Se o servidor recusar, é porque falta
-- privilégio de CREATE USER / CREATE ROLE.

-- Questão 39 - criar usuário diretor
CREATE USER 'diretor'@'localhost' IDENTIFIED BY 'Diretor@123';

-- Questão 40 - criar usuário professor
CREATE USER 'professor'@'localhost' IDENTIFIED BY 'Professor@123';

-- Questão 41 - criar usuário aluno
CREATE USER 'aluno'@'localhost' IDENTIFIED BY 'Aluno@123';

-- Questão 42 - conceder SELECT em todas as tabelas para o diretor
GRANT SELECT ON hogwarts.* TO 'diretor'@'localhost';

-- Questão 43 - conceder SELECT em algumas views para o professor
GRANT SELECT ON hogwarts.vw_boletim TO 'professor'@'localhost';
GRANT SELECT ON hogwarts.vw_alunos_casas TO 'professor'@'localhost';

-- Questão 44 - conceder SELECT apenas em vw_placar_casas para o aluno
GRANT SELECT ON hogwarts.vw_produtos_estoque TO 'aluno'@'localhost';
-- Resultado de cada comando:
-- GRANT no diretor: OK (acesso total de leitura)
-- GRANT no professor: OK (só as duas views)
-- GRANT no aluno: OK (só a view de produtos)
-- Se o aluno tentar SELECT em aluno, recebe ERROR 1142 (42000):
-- SELECT command denied to user 'aluno'@'localhost' for table 'aluno'

-- Questão 45 - trigger atualizando casa via usuário restrito
-- O usuário 'professor' só tem SELECT em views, então NÃO consegue inserir
-- em registro_pontos. Para o trigger funcionar, é preciso dar INSERT nele:
GRANT INSERT ON hogwarts.registro_pontos TO 'professor'@'localhost';
-- Como o trigger conseguiu atualizar a casa: triggers rodam com os
-- privilégios do DEFINER (quem criou o trigger, no caso o root), não do
-- usuário que dispara o INSERT. Por isso o professor pode inserir pontos
-- sem ter UPDATE direto na tabela casa.

-- Questão 46 - revogar o SELECT do aluno
REVOKE SELECT ON hogwarts.vw_produtos_estoque FROM 'aluno'@'localhost';

-- Questão 47 - criar papel (role) e conceder
CREATE ROLE 'leitor_hogwarts';
GRANT SELECT ON hogwarts.vw_alunos_casas TO 'leitor_hogwarts';
GRANT SELECT ON hogwarts.vw_boletim TO 'leitor_hogwarts';
GRANT 'leitor_hogwarts' TO 'professor'@'localhost';
-- Vantagem dos papéis: em vez de conceder privilégio por usuário, você
-- cria um papel com o conjunto de permissões e atribui a vários usuários.
-- Fica mais fácil manter (muda o papel e todos os usuários herdam) e auditar.

-- Questão 48 - remover o papel do usuário e apagar o papel
REVOKE 'leitor_hogwarts' FROM 'professor'@'localhost';
DROP ROLE 'leitor_hogwarts';
