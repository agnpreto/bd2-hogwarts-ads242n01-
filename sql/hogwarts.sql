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
