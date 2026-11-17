-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Francisco Kenison da Silva Monteiro
-- Matrícula: 2415681
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
-- Resposta: A chave primária composta (id_aluno, id_disc) garante a integridade dos dados ao impedir que um mesmo aluno se matricule mais de uma vez na mesma disciplina. Se fosse utilizado um id_matricula auto_increment isolado, o banco permitiria a inserção acidental de registros duplicados para o mesmo aluno e disciplina, exigindo uma restrição UNIQUE adicional para evitar a inconsistência.


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
(2,1,10.0),(2,2,9.5), (2,3,10.0), (2,5,9.0), (2,9,9.5),
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
SELECT COUNT(*) FROM casa;
SELECT COUNT(*) FROM professor;
SELECT COUNT(*) FROM disciplina;
SELECT COUNT(*) FROM aluno;
SELECT COUNT(*) FROM matricula;
SELECT COUNT(*) FROM produto;

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
SET email = LOWER(CONCAT(REPLACE(nome, ' ', '.'), '@hogwarts.edu'));

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
SET nota = LEAST(10.00, nota + 0.5)
WHERE id_disc IN (
    SELECT id_disc FROM disciplina WHERE id_prof = (
        SELECT id_prof FROM professor WHERE nome = 'Remo Lupin'
    )
);

-- Questão 9
UPDATE matricula
SET situacao = CASE
    WHEN nota >= 6.0 THEN 'Aprovado'
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
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`aluno`, CONSTRAINT `aluno_ibfk_1` FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: A exclusão foi negada devido à restrição de chave estrangeira (FOREIGN KEY). Existem registros nas tabelas filhas (como `aluno` e `professor`) que referenciam o `id_casa` da Sonserina. Para excluir a casa, seria necessário antes remover ou atualizar as referências nas tabelas vinculadas.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES ('Dobby', 8, 1, 0.00);
-- Erro: Error Code: 3819. Check constraint 'aluno_chk_1' is violated.
-- Explicação: O comando violou a restrição CHECK (ano_escolar BETWEEN 1 AND 7) definida na criação da tabela `aluno`, pois tentou-se cadastrar o valor 8 para a coluna `ano_escolar`.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 0.00, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: O comando falhou porque o e-mail 'harry.potter@hogwarts.edu' já existe na tabela `aluno`. A restrição UNIQUE (`uq_aluno_email`) impede a inserção de valores duplicados nessa coluna.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`hogwarts`.`disciplina`, CONSTRAINT `disciplina_ibfk_1` FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`))
-- Explicação: A exclusão falhou por restrição de integridade referencial (FOREIGN KEY), pois Severo Snape está cadastrado como professor da disciplina de Poções na tabela `disciplina`.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Explicação: O comando funcionou perfeitamente porque Gilderoy Lockhart não estava associado como chave estrangeira (`id_prof`) a nenhuma disciplina cadastrada na tabela `disciplina` (a disciplina de Defesa Contra as Artes das Trevas está vinculada ao professor Remo Lupin no cadastro inicial).

-- Questão 18
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT DISTINCT id_disc FROM matricula);


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    DECLARE v_id_casa INT;
    SELECT id_casa INTO v_id_casa FROM aluno WHERE id_aluno = NEW.id_aluno;
    IF v_id_casa IS NOT NULL THEN
        UPDATE casa
        SET pontos = pontos + NEW.pontos
        WHERE id_casa = v_id_casa;
    END IF;
END$$
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
    
    SELECT estoque, preco INTO v_estoque, v_preco FROM produto WHERE id_produto = NEW.id_produto;
    SELECT saldo_galeoes INTO v_saldo FROM aluno WHERE id_aluno = NEW.id_aluno;
    
    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    ELSEIF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
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
    IF NEW.nota <> OLD.nota THEN
        IF NEW.nota >= 6.0 THEN
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


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50.00 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50.00 WHERE nome = 'Pansy Parkinson';
COMMIT;

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT * FROM casa;
ROLLBACK;
SELECT * FROM casa;
-- Resposta: Sim, o placar voltou aos valores originais pré-transação pois o ROLLBACK desfez completamente as alterações efetuadas.

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT estoque FROM produto WHERE id_produto = 1;
-- Explicação: As alterações feitas pelo trigger (desconto no saldo de Harry e baixa no estoque da varinha) foram completamente desfeitas pelo ROLLBACK, pois os efeitos do trigger ocorrem dentro do mesmo contexto transacional do comando acionador.

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
-- Resposta: O valor 1 indica que a opção autocommit está ligada, ou seja, cada instrução SQL individual é confirmada automaticamente logo após sua execução. Se um comando DDL (como CREATE TABLE) for executado no meio de uma transação aberta, ele realiza um COMMIT implícito imediato, confirmando permanentemente todas as operações pendentes realizadas até aquele ponto e encerrando a transação.



-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1
SELECT nome, salario
FROM professor
WHERE salario BETWEEN 6000.00 AND 9000.00
ORDER BY salario DESC;

-- 6.2
SELECT nome, ano_escolar
FROM aluno
WHERE ano_escolar IN (1, 4, 6, 7)
ORDER BY ano_escolar ASC;

-- 6.3
SELECT nome
FROM aluno
WHERE nome LIKE '_a%';

-- 6.4
SELECT nome_disc
FROM disciplina
WHERE id_prof IS NULL;

-- 6.5
SELECT nome_produto, preco
FROM produto
WHERE preco NOT BETWEEN 5.00 AND 20.00
ORDER BY preco ASC;

-- 6.6
SELECT DISTINCT loja
FROM produto
ORDER BY loja ASC;

-- ---------- Nível 2: JOINs ----------

-- 6.7
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
ORDER BY c.nome_casa ASC, a.nome ASC;
-- Quantos alunos e por quê: Aparecem 12 alunos. O aluno Teddy Lupin não aparece porque possui id_casa NULL, sendo excluído pela junção interna (INNER JOIN).

-- 6.8
SELECT a.nome AS aluno, COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON a.id_casa = c.id_casa
ORDER BY a.nome ASC;

-- 6.9
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON d.id_prof = p.id_prof
WHERE d.id_disc IS NULL;

-- 6.10
SELECT a.nome AS aluno, d.nome_disc AS disciplina, p.nome AS professor, m.nota, m.situacao
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN matricula m ON a.id_aluno = m.id_aluno
INNER JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome ASC, d.nome_disc ASC;

-- 6.11
SELECT c.id_compra, a.nome AS aluno, p.nome_produto AS produto, p.loja, c.quantidade, c.valor_total, c.data_compra
FROM compra c
INNER JOIN aluno a ON c.id_aluno = a.id_aluno
INNER JOIN produto p ON c.id_produto = p.id_produto
ORDER BY c.data_compra ASC, c.id_compra ASC;

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS qtd_alunos,
       ROUND(AVG(m.nota), 2) AS media_nota,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
INNER JOIN matricula m ON d.id_disc = m.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7.0
ORDER BY media_nota DESC;

-- 6.13
SELECT c.nome_casa,
       COUNT(r.id_registro) AS qtd_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN ABS(r.pontos) ELSE 0 END) AS pontos_perdidos,
       SUM(r.pontos) AS saldo_pontos
FROM casa c
LEFT JOIN aluno a ON c.id_casa = a.id_casa
LEFT JOIN registro_pontos r ON a.id_aluno = r.id_aluno
GROUP BY c.id_casa, c.nome_casa;

-- 6.14
SELECT p.loja,
       COUNT(c.id_compra) AS qtd_compras,
       SUM(c.valor_total) AS faturamento
FROM produto p
INNER JOIN compra c ON p.id_produto = c.id_produto
GROUP BY p.loja
HAVING SUM(c.valor_total) > 20.00
ORDER BY faturamento DESC;

-- 6.15
SELECT MONTH(data_registro) AS mes,
       COUNT(*) AS qtd_registros,
       SUM(pontos) AS total_pontos
FROM registro_pontos
GROUP BY MONTH(data_registro)
ORDER BY mes ASC;

-- 6.16
SELECT p.nome AS professor,
       COUNT(r.id_registro) AS qtd_registros,
       SUM(r.pontos) AS total_concedido
FROM professor p
INNER JOIN registro_pontos r ON p.id_prof = r.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_concedido DESC;

-- ---------- Nível 4: subconsultas ----------

-- 6.17
SELECT nome
FROM aluno
WHERE id_aluno IN (
    SELECT id_aluno
    FROM compra
    WHERE id_produto IN (
        SELECT id_produto
        FROM produto
        WHERE loja = 'Dedosdemel'
    )
);

-- 6.18
SELECT nome_produto, estoque
FROM produto
WHERE id_produto NOT IN (
    SELECT DISTINCT id_produto
    FROM compra
);

-- 6.19
SELECT nome, saldo_galeoes
FROM aluno
WHERE saldo_galeoes > (
    SELECT AVG(saldo_galeoes)
    FROM aluno
);

-- 6.20
SELECT nome, salario
FROM professor
WHERE salario > ALL (
    SELECT salario
    FROM professor
    WHERE id_casa IS NULL
);

-- 6.21
SELECT nome, saldo_galeoes
FROM aluno
WHERE (id_casa IS NULL OR id_casa <> (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina'))
  AND saldo_galeoes > ANY (
      SELECT saldo_galeoes
      FROM aluno
      WHERE id_casa = (SELECT id_casa FROM casa WHERE nome_casa = 'Sonserina')
  );
-- > ANY equivale a: Comparar se o valor é maior do que o MENOR valor retornado pela subconsulta.

-- 6.22
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    INNER JOIN matricula m ON a.id_aluno = m.id_aluno
    WHERE a.id_casa = c.id_casa AND m.nota = 10.00
);

-- 6.23
SELECT nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra c
    WHERE c.id_aluno = a.id_aluno
);

-- 6.24
SELECT c.nome_casa, ROUND(AVG(med.media_aluno), 2) AS media_casa
FROM (
    SELECT id_aluno, AVG(nota) AS media_aluno
    FROM matricula
    GROUP BY id_aluno
) med
INNER JOIN aluno a ON med.id_aluno = a.id_aluno
INNER JOIN casa c ON a.id_casa = c.id_casa
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_casa DESC;

-- ---------- Nível 5: UNION ALL ----------

-- 6.25
SELECT nome, 'Aluno' AS vinculo FROM aluno
UNION ALL
SELECT nome, 'Professor' AS vinculo FROM professor
ORDER BY nome ASC;

-- 6.26
-- UNION ALL:
SELECT a.nome FROM aluno a INNER JOIN compra c ON a.id_aluno = c.id_aluno
UNION ALL
SELECT a.nome FROM aluno a INNER JOIN registro_pontos r ON a.id_aluno = r.id_aluno;

-- UNION:
SELECT a.nome FROM aluno a INNER JOIN compra c ON a.id_aluno = c.id_aluno
UNION
SELECT a.nome FROM aluno a INNER JOIN registro_pontos r ON a.id_aluno = r.id_aluno;

-- Linhas com UNION ALL: 27
-- Linhas com UNION: 12
-- Explicação: O UNION ALL preserva todas as linhas resultantes das duas consultas, incluindo duplicatas de um mesmo aluno que fez várias compras ou recebeu múltiplos registros. O UNION remove registros duplicados, retornando apenas nomes distintos.

-- 6.27
SELECT 'Total de pontos distribuídos' AS indicador, CAST(SUM(pontos) AS CHAR) AS valor FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja', CAST(SUM(valor_total) AS CHAR) FROM compra
UNION ALL
SELECT 'Folha salarial dos professores', CAST(SUM(salario) AS CHAR) FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos', CAST(SUM(saldo_galeoes) AS CHAR) FROM aluno;


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31
CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questão 32
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula m
INNER JOIN aluno a ON m.id_aluno = a.id_aluno
LEFT JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN disciplina d ON m.id_disc = d.id_disc
LEFT JOIN professor p ON d.id_prof = p.id_prof;

-- Questão 33
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       p.nome_produto AS produto,
       p.loja,
       c.quantidade,
       c.valor_total,
       c.data_compra
FROM compra c
INNER JOIN aluno a ON c.id_aluno = a.id_aluno
INNER JOIN produto p ON c.id_produto = p.id_produto;

-- Questão 34
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media_nota
FROM aluno a
INNER JOIN casa c ON a.id_casa = c.id_casa
INNER JOIN matricula m ON a.id_aluno = m.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8.0;

-- Questão 35
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_que_dirige,
       (SELECT COUNT(*) FROM disciplina d WHERE d.id_prof = p.id_prof) AS qtd_disciplinas,
       COALESCE((SELECT SUM(r.pontos) FROM registro_pontos r WHERE r.id_prof = p.id_prof), 0) AS total_pontos_concedidos
FROM professor p
LEFT JOIN casa c ON p.id_casa = c.id_casa;

-- Questão 36
SELECT * FROM vw_placar_casas;

SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja;

SELECT * FROM vw_alunos_destaque ORDER BY media_nota DESC;

SELECT * FROM vw_quadro_professores ORDER BY total_pontos_concedidos DESC;

-- Questão 37
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas;
-- O que mudou e por quê: Os pontos da Lufa-Lufa subiram de 50 para 70. Isso ocorre porque a view é um objeto dinâmico (uma consulta salva que roda em tempo de execução); ao inserir o registro de pontos, a trigger `trg_pontos_casa` atualizou a tabela física `casa`, refletindo imediatamente o novo placar na visualização da view.

-- Questão 38
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;

-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39
CREATE USER 'filch'@'localhost' IDENTIFIED BY 'Madame Norra#1';
CREATE USER 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 40
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 41
GRANT SELECT, INSERT ON hogwarts.registro_pontos TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.aluno TO 'mcgonagall'@'localhost';
GRANT SELECT ON hogwarts.vw_boletim TO 'mcgonagall'@'localhost';

-- Questão 42
GRANT ALL PRIVILEGES ON hogwarts.* TO 'dumbledore'@'localhost' WITH GRANT OPTION;

-- Questão 43
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 44
-- Conectado como filch:
-- SELECT * FROM vw_placar_casas; -- Funciona normalmente e retorna a pontuação das casas.
-- SELECT * FROM aluno;
-- Resultado de cada comando: O primeiro comando consulta com sucesso a View. O segundo falha com Error Code: 1142. SELECT command denied to user 'filch'@'localhost' for table 'aluno'.

-- Questão 45
-- Conectado como mcgonagall:
-- a. INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES (2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');
-- b. UPDATE casa SET pontos = 1000 WHERE id_casa = 1; -- Erro 1142: UPDATE command denied.
-- Como o trigger conseguiu atualizar a casa: Triggers no MySQL são executados sob a cláusula por padrão DEFINER (o usuário criador do objeto, root/admin), o que permite ao trigger alterar a tabela `casa` mesmo que o usuário acionador (mcgonagall) não possua permissão direta de UPDATE sobre ela.

-- Questão 46
REVOKE INSERT ON hogwarts.registro_pontos FROM 'mcgonagall'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47
CREATE ROLE monitor;
GRANT SELECT ON hogwarts.vw_boletim TO monitor;
GRANT SELECT ON hogwarts.vw_placar_casas TO monitor;

CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';
GRANT monitor TO 'percy'@'localhost';
ALTER USER 'percy'@'localhost' DEFAULT ROLE monitor;

-- Vantagem dos papéis: A utilização de papéis (roles) simplifica a gestão de acessos e a manutenção do banco. Em vez de conceder ou revogar individualmente múltiplos privilégios para cada usuário, define-se um conjunto padrão de privilégios no papel; novos monitores precisam apenas receber a atribuição desse papel, e eventuais mudanças de permissões aplicadas à role refletem-se instantaneamente para todos os usuários associados.

-- Questão 48
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE monitor;
