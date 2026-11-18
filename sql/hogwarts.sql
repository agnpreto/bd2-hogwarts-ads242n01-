#🪄 Atividade Prática — Escola de Magia de Hogwarts

**Disciplina:** Manipulação de Dados / Banco de Dados II  
**Professor:** Aguinaldo Neto  
**Aluno:** CAMILA DE JESUS PINHEIRO 
**Curso:** ADS 242

Este repositório contém a resolução da atividade prática de Banco de Dados utilizando **MySQL**. O script foi organizado na mesma ordem do enunciado para respeitar as dependências entre tabelas, alterações, triggers, transações, consultas, views e permissões.

## Como executar

1. Abra o MySQL Workbench.
2. Execute o script em um ambiente de testes, pois ele cria e altera o banco `hogwarts`.
3. Execute os blocos na ordem apresentada.
4. Para testar as permissões da seção DCL, crie novas conexões no Workbench usando os usuários criados.
5. Os comandos que devem falhar por causa de restrições estão identificados como **testes esperados**. Execute-os separadamente para que um erro não interrompa o restante do script.

> **Atenção:** o script utiliza recursos do MySQL 8.0. Os testes de exclusão/inserção inválidos são comentados para não interromper a execução automática. Descomente-os individualmente para observar os erros.

---

## 1. Preparação do ambiente — DDL

```sql
CREATE DATABASE IF NOT EXISTS hogwarts;
USE hogwarts;

-- Questão 1: criação das tabelas

CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    data_contratacao DATE,
    id_casa INT,
    CONSTRAINT chk_prof_salario CHECK (salario > 0),
    CONSTRAINT fk_prof_casa FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);

CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof INT,
    CONSTRAINT chk_disc_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disc_prof FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);

CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    CONSTRAINT chk_aluno_nome CHECK (TRIM(nome) <> ''),
    ano_escolar INT,
    id_casa INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT chk_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT chk_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);

CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT chk_matricula_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_matricula_disc FOREIGN KEY (id_disc)
        REFERENCES disciplina(id_disc)
);

CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_registro_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_registro_prof FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
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
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto)
);

CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Pergunta — chave primária composta em `matricula`:** a combinação `(id_aluno, id_disc)` identifica naturalmente uma matrícula de um aluno em uma disciplina e impede que o mesmo aluno seja matriculado duas vezes na mesma disciplina. Se fosse usado apenas um `id_matricula`, seria necessário criar também uma restrição `UNIQUE (id_aluno, id_disc)` para evitar duplicidade.

## 1.1. Carga inicial — DML

```sql
-- Questão 2: casas
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'),
('Sonserina', 'Salazar Slytherin'),
('Corvinal', 'Rowena Ravenclaw'),
('Lufa-Lufa', 'Helga Hufflepuff');

-- Questão 3: professores
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),
('Severo Snape', 8800.00, '1981-09-01', 2),
('Fílio Flitwick', 8200.00, '1974-09-01', 3),
('Pomona Sprout', 7900.00, '1972-09-01', 4),
('Rúbeo Hagrid', 4500.00, '1993-09-01', NULL),
('Remo Lupin', 6200.00, '1993-09-01', NULL),
('Sibila Trelawney', 5100.00, '1980-09-01', NULL),
('Gilderoy Lockhart', 7000.00, '1992-09-01', NULL),
('Horácio Slughorn', 8000.00, '1996-09-01', NULL);

-- Questão 4: disciplinas
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

-- Questão 5: alunos
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

-- Questão 6: matrículas
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

-- Questão 7: produtos
INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20),
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);

-- Conferência da carga inicial
SELECT 'casas' AS tabela, COUNT(*) AS total FROM casa
UNION ALL SELECT 'professores', COUNT(*) FROM professor
UNION ALL SELECT 'disciplinas', COUNT(*) FROM disciplina
UNION ALL SELECT 'alunos', COUNT(*) FROM aluno
UNION ALL SELECT 'matriculas', COUNT(*) FROM matricula
UNION ALL SELECT 'produtos', COUNT(*) FROM produto;
```

## 2. Manutenção pós-carga — ALTER e UPDATE

```sql
-- Questões 2.1.1 a 2.1.5: alterações de estrutura
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- Questão 2.2.6: gerar e-mails em minúsculas
UPDATE aluno
SET email = CONCAT(
    LOWER(REPLACE(nome, ' ', '.')),
    '@hogwarts.edu'
);

-- Questão 2.2.7: impedir e-mails duplicados
ALTER TABLE aluno
ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 2.2.8: bônus de 0,5 para alunos das disciplinas de Lupin, limitado a 10
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc
    FROM disciplina
    WHERE id_prof = (
        SELECT id_prof
        FROM professor
        WHERE nome = 'Remo Lupin'
    )
);

-- Questão 2.2.9: atualizar a situação de todas as matrículas
UPDATE matricula
SET situacao = CASE
    WHEN nota >= 6 THEN 'Aprovado'
    ELSE 'Reprovado'
END;

-- Questão 2.2.10: reajuste de 10% para diretores admitidos antes de 1980
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL
  AND data_admissao < '1980-01-01';

-- Questão 2.2.11: inativar produtos sem estoque
UPDATE produto
SET ativo = 'N'
WHERE estoque = 0;

-- Questão 2.2.12: promoção de 20% na Dedosdemel
UPDATE produto
SET preco = preco * 0.80
WHERE loja = 'Dedosdemel';

-- Conferências
SELECT nome, salario FROM professor WHERE nome = 'Minerva McGonagall';
SELECT nome, nota, situacao FROM aluno
JOIN matricula USING (id_aluno)
WHERE nome = 'Harry Potter' AND id_disc = 6;
SELECT COUNT(*) AS matriculas_reprovadas
FROM matricula WHERE situacao = 'Reprovado';
SELECT nome_produto, preco FROM produto WHERE nome_produto = 'Sapo de Chocolate';
```

## 3. Remoção de dados e testes de restrições

Os comandos das questões 13, 14, 15 e 16 são testes de erro. Execute cada um separadamente.

```sql
-- Questão 13 — TESTE ESPERADO: falha por chave estrangeira.
-- Sonserina é referenciada por professores e alunos.
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro esperado: 1451 (Cannot delete or update a parent row).

-- Questão 14 — TESTE ESPERADO: falha pela restrição CHECK do ano escolar.
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Dobby', 8, 1, 0, 'dobby@hogwarts.edu');
-- Erro esperado: 3819 (Check constraint is violated).

-- Questão 15 — TESTE ESPERADO: falha pela restrição UNIQUE do e-mail.
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0, 'harry.potter@hogwarts.edu');
-- Erro esperado: 1062 (Duplicate entry).

-- Questão 16 — TESTE ESPERADO: falha porque Snape ministra Poções.
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro esperado: 1451 (Cannot delete or update a parent row).

-- Questão 17: excluir Lockhart. Ele não está referenciado por disciplina,
-- portanto a exclusão é permitida.
DELETE FROM professor
WHERE nome = 'Gilderoy Lockhart';

-- Questão 18: excluir primeiro as matrículas de Vicente Crabbe e depois o aluno.
DELETE FROM matricula
WHERE id_aluno IN (
    SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe'
);

DELETE FROM aluno
WHERE nome = 'Vicente Crabbe';

-- Questão 19: excluir disciplinas sem matrícula.
DELETE FROM disciplina AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM matricula AS m
    WHERE m.id_disc = d.id_disc
);

-- Conferência da seção 3
SELECT
    (SELECT COUNT(*) FROM professor) AS professores,
    (SELECT COUNT(*) FROM aluno) AS alunos,
    (SELECT COUNT(*) FROM disciplina) AS disciplinas,
    (SELECT COUNT(*) FROM matricula) AS matriculas;
```

**Explicações dos testes:** a casa Sonserina não pode ser removida porque há registros de alunos e professores apontando para ela por chaves estrangeiras. Dobby não pode ser cadastrado no 8º ano porque o `CHECK` permite somente anos de 1 a 7. O aluno com Poção Polissuco não pode repetir o e-mail de Harry por causa da restrição `UNIQUE`. Snape não pode ser excluído porque está associado à disciplina Poções. Lockhart pode ser excluído porque não possui disciplina vinculada a ele.

## 4. Triggers — regras automáticas

```sql
DELIMITER $$

-- Questão 20: atualizar os pontos da casa do aluno após um registro
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
END$$

-- Questão 21: validar estoque e saldo antes de inserir a compra
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo DECIMAL(10,2);

    SELECT preco, estoque
    INTO v_preco, v_estoque
    FROM produto
    WHERE id_produto = NEW.id_produto;

   SELECT saldo_galeoes
INTO v_saldo
FROM aluno
WHERE id_aluno = NEW.id_aluno;

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

-- Questão 22: baixar estoque e saldo depois da compra
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

-- Questão 23: recalcular a situação quando a nota for alterada
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    SET NEW.situacao = CASE
        WHEN NEW.nota >= 6 THEN 'Aprovado'
        ELSE 'Reprovado'
    END;
END$$

-- Questão 24: registrar auditoria quando o salário mudar
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(
                OLD.nome, ': salário de ',
                FORMAT(OLD.salario, 2, 'en_US'),
                ' para ',
                FORMAT(NEW.salario, 2, 'en_US')
            )
        );
    END IF;
END$$

DELIMITER ;
```

**Pergunta — BEFORE e AFTER:** a validação deve ocorrer em `BEFORE INSERT` porque precisa impedir que uma compra inválida seja gravada e preencher `NEW.valor_total` antes da inserção. A baixa deve ocorrer em `AFTER INSERT` porque só deve atualizar estoque e saldo depois que a compra tiver sido inserida com sucesso.

### 4.1. Testando os triggers

```sql
-- Questão 25: registros de pontos
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

-- Compras: o trigger calcula valor_total e atualiza estoque/saldo
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

-- Teste: Rony tenta comprar uma Nimbus de 300 galeões.
-- A compra é bloqueada porque seu saldo é insuficiente.
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Erro esperado: Galeões insuficientes no cofre do aluno.

-- Teste: Hermione tenta comprar o caldeirão sem estoque.
-- A compra é bloqueada pelo estoque igual a zero.
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Erro esperado: Estoque insuficiente no Beco Diagonal.

-- Atualizar a nota de Rony em Poções; o trigger altera a situação automaticamente.
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3
  AND id_disc = (
      SELECT id_disc FROM disciplina WHERE nome_disc = 'Poções'
  );

-- Alterar o salário de Hagrid: gera uma linha de auditoria.
UPDATE professor
SET salario = 5000.00
WHERE nome = 'Rúbeo Hagrid';

-- Alterar somente a data: não gera outra linha, pois o salário não mudou.
UPDATE professor
SET data_admissao = '1993-08-15'
WHERE nome = 'Rúbeo Hagrid';

-- Conferências dos triggers
SELECT nome_casa, pontos FROM casa ORDER BY id_casa;
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Harry Potter');
SELECT nome_produto, estoque FROM produto
WHERE id_produto IN (2, 3);
SELECT SUM(valor_total) AS total_compras FROM compra;
SELECT * FROM log_auditoria;
SELECT nome, nota, situacao
FROM aluno
JOIN matricula USING (id_aluno)
WHERE nome = 'Rony Weasley' AND id_disc = 2;
```

**Explicações dos testes:** Rony não consegue comprar a Nimbus porque não tem 300 galeões. Hermione não consegue comprar o caldeirão porque o estoque está zerado. Ao atualizar a nota de Rony, o trigger `BEFORE UPDATE` muda sua situação para `Aprovado`. A alteração salarial de Hagrid gera um registro no log; a alteração da data não gera outro porque o salário permaneceu igual. O reajuste da questão 10 ocorreu antes da criação do trigger, portanto não foi auditado retroativamente.

## 5. Controle de transações — TCL

```sql
-- Questão 26: transferência de 50 galeões de Draco para Pansy
START TRANSACTION;

UPDATE aluno
SET saldo_galeoes = saldo_galeoes - 50
WHERE nome = 'Draco Malfoy';

UPDATE aluno
SET saldo_galeoes = saldo_galeoes + 50
WHERE nome = 'Pansy Parkinson';

COMMIT;

-- Questão 27: zerar temporariamente o placar e desfazer
START TRANSACTION;

UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;

ROLLBACK;

SELECT nome_casa, pontos FROM casa;

-- Questão 28: compra dentro de uma transação
START TRANSACTION;

INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');

-- Dentro da transação, o trigger já atualizou saldo e estoque.
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;

ROLLBACK;

-- Após o ROLLBACK, compra, saldo e estoque voltam ao estado anterior.
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;

-- Questão 29: SAVEPOINT
START TRANSACTION;

INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

SAVEPOINT sp_pontos_legitimos;

INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(6, 2, 100, 'Favoritismo descarado', '2026-11-10');

ROLLBACK TO SAVEPOINT sp_pontos_legitimos;

COMMIT;

-- Questão 30: verificar autocommit
SELECT @@autocommit;
```

**Respostas conceituais:**

- **Questão 27:** sim. O `ROLLBACK` desfaz a atualização temporária do placar.
- **Questão 28:** as alterações feitas pelos triggers também são desfeitas, pois os comandos dos triggers participam da mesma transação.
- **Questão 29:** os 15 pontos de Ana são confirmados. Os 100 pontos de Pansy são desfeitos ao voltar ao `SAVEPOINT`.
- **Questão 30:** `@@autocommit = 1` significa que cada comando é confirmado automaticamente quando executado fora de uma transação explícita. No MySQL, comandos DDL como `CREATE TABLE` provocam commit implícito; por isso, não se deve executar DDL no meio de uma transação que se deseja reverter.

## 6. Desafios de consulta — SQL avançado

### Nível 1 — filtros e operadores especiais

```sql
-- Questão 6.1: faixa salarial
SELECT p.nome, p.salario
FROM professor AS p
WHERE p.salario BETWEEN 6000 AND 9000
ORDER BY p.salario DESC;

-- Questão 6.2: anos selecionados
SELECT a.nome, a.ano_escolar
FROM aluno AS a
WHERE a.ano_escolar IN (1, 4, 6, 7)
ORDER BY a.ano_escolar, a.nome;

-- Questão 6.3: letra 'a' como segunda letra
SELECT a.nome
FROM aluno AS a
WHERE a.nome LIKE '_a%';

-- Questão 6.4: disciplinas sem professor
SELECT d.nome_disc
FROM disciplina AS d
WHERE d.id_prof IS NULL;

-- Questão 6.5: produtos fora da faixa de 5 a 20 galeões
SELECT p.nome_produto, p.preco
FROM produto AS p
WHERE p.preco NOT BETWEEN 5 AND 20
ORDER BY p.preco;

-- Questão 6.6: lojas sem repetição
SELECT DISTINCT p.loja
FROM produto AS p
ORDER BY p.loja;
```

### Nível 2 — JOINs

```sql
-- Questão 6.7: alunos que possuem casa (INNER JOIN)
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno AS a
INNER JOIN casa AS c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;

-- Retornam 12 alunos, pois Teddy Lupin ainda não possui casa.
-- Questão 6.8: todos os alunos, inclusive quem não possui casa
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapéu Seletor') AS casa
FROM aluno AS a
LEFT JOIN casa AS c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- Questão 6.9: professores que não ministram disciplinas
SELECT p.nome AS professor
FROM disciplina AS d
RIGHT JOIN professor AS p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- Questão 6.10: boletim da Grifinória; professor pode não estar definido
SELECT a.nome AS aluno,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM aluno AS a
INNER JOIN casa AS c ON c.id_casa = a.id_casa
INNER JOIN matricula AS m ON m.id_aluno = a.id_aluno
INNER JOIN disciplina AS d ON d.id_disc = m.id_disc
LEFT JOIN professor AS p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinória'
ORDER BY a.nome, d.nome_disc;

-- Questão 6.11: extrato do Beco Diagonal
SELECT co.id_compra,
       a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra AS co
INNER JOIN aluno AS a ON a.id_aluno = co.id_aluno
INNER JOIN produto AS pr ON pr.id_produto = co.id_produto
ORDER BY co.data_compra, co.id_compra;
```

### Nível 3 — agrupamento e funções de agregação

```sql
-- Questão 6.12: desempenho por disciplina
SELECT d.nome_disc,
       COUNT(m.id_aluno) AS quantidade_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina AS d
INNER JOIN matricula AS m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- Questão 6.13: livro-razão da Taça
SELECT c.nome_casa,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       COALESCE(SUM(r.pontos), 0) AS saldo_pontos
FROM casa AS c
LEFT JOIN aluno AS a ON a.id_casa = c.id_casa
LEFT JOIN registro_pontos AS r ON r.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY c.nome_casa;

-- Questão 6.14: faturamento por loja
SELECT p.loja,
       COUNT(co.id_compra) AS quantidade_compras,
       SUM(co.valor_total) AS faturamento
FROM produto AS p
INNER JOIN compra AS co ON co.id_produto = p.id_produto
GROUP BY p.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- Questão 6.15: pontos por mês
SELECT MONTH(r.data_registro) AS mes,
       COUNT(*) AS quantidade_registros,
       SUM(r.pontos) AS total_pontos
FROM registro_pontos AS r
GROUP BY MONTH(r.data_registro)
ORDER BY mes;

-- Questão 6.16: professores com pelo menos dois registros
SELECT p.nome AS professor,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(r.pontos) AS total_concedido
FROM professor AS p
INNER JOIN registro_pontos AS r ON r.id_prof = p.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_concedido DESC;
```

### Nível 4 — subconsultas

```sql
-- Questão 6.17: alunos que compraram produtos da Dedosdemel (sem JOIN)
SELECT a.nome
FROM aluno AS a
WHERE a.id_aluno IN (
    SELECT co.id_aluno
    FROM compra AS co
    WHERE co.id_produto IN (
        SELECT p.id_produto
        FROM produto AS p
        WHERE p.loja = 'Dedosdemel'
    )
);

-- Questão 6.18: produtos nunca comprados
SELECT p.nome_produto, p.estoque
FROM produto AS p
WHERE p.id_produto NOT IN (
    SELECT co.id_produto
    FROM compra AS co
);

-- Questão 6.19: alunos com saldo acima da média geral
SELECT a.nome, a.saldo_galeoes
FROM aluno AS a
WHERE a.saldo_galeoes > (
    SELECT AVG(a2.saldo_galeoes)
    FROM aluno AS a2
);

-- Questão 6.20: professores que ganham mais que todos os não diretores
SELECT p.nome, p.salario
FROM professor AS p
WHERE p.salario > ALL (
    SELECT p2.salario
    FROM professor AS p2
    WHERE p2.id_casa IS NULL
);

-- Questão 6.21: alunos de outras casas com saldo maior que algum sonserino
SELECT a.nome, a.saldo_galeoes
FROM aluno AS a
WHERE a.id_casa <> 2
  AND a.saldo_galeoes > ANY (
      SELECT s.saldo_galeoes
      FROM aluno AS s
      WHERE s.id_casa = 2
  );

-- > ANY significa maior que pelo menos um valor da subconsulta,
-- ou seja, maior que o menor valor do conjunto (não o maior).

-- Questão 6.22: casas com pelo menos um aluno que tirou 10
SELECT c.nome_casa
FROM casa AS c
WHERE EXISTS (
    SELECT 1
    FROM aluno AS a
    INNER JOIN matricula AS m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa
      AND m.nota = 10
);

-- Questão 6.23: alunos que nunca compraram
SELECT a.nome
FROM aluno AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra AS co
    WHERE co.id_aluno = a.id_aluno
);

-- Questão 6.24: média das médias dos alunos por casa
SELECT c.nome_casa,
       ROUND(AVG(medias.media_aluno), 2) AS media_da_casa
FROM casa AS c
INNER JOIN aluno AS a ON a.id_casa = c.id_casa
INNER JOIN (
    SELECT m.id_aluno, AVG(m.nota) AS media_aluno
    FROM matricula AS m
    GROUP BY m.id_aluno
) AS medias ON medias.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;
```

### Nível 5 — UNION ALL

```sql
-- Questão 6.25: diretório de Hogwarts
SELECT nome, vinculo
FROM (
    SELECT a.nome, 'Aluno' AS vinculo
    FROM aluno AS a
    UNION ALL
    SELECT p.nome, 'Professor' AS vinculo
    FROM professor AS p
) AS diretorio
ORDER BY nome;

-- Questão 6.26: alunos que compraram ou receberam pontos
-- UNION ALL mantém as ocorrências repetidas.
SELECT a.nome
FROM aluno AS a
WHERE a.id_aluno IN (SELECT id_aluno FROM compra)
UNION ALL
SELECT a.nome
FROM aluno AS a
WHERE a.id_aluno IN (SELECT id_aluno FROM registro_pontos);

-- UNION elimina nomes repetidos.
SELECT a.nome
FROM aluno AS a
WHERE a.id_aluno IN (SELECT id_aluno FROM compra)
UNION
SELECT a.nome
FROM aluno AS a
WHERE a.id_aluno IN (SELECT id_aluno FROM registro_pontos);

-- A conferência do enunciado indica 27 linhas com UNION ALL e 12 com UNION.

-- Questão 6.27: painel do diretor
SELECT 'Total de pontos distribuídos' AS indicador,
       CAST(COALESCE(SUM(pontos), 0) AS CHAR) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Total de galeões gastos na loja',
       CAST(COALESCE(SUM(valor_total), 0) AS CHAR)
FROM compra
UNION ALL
SELECT 'Folha salarial dos professores',
       CAST(COALESCE(SUM(salario), 0) AS CHAR)
FROM professor
UNION ALL
SELECT 'Total de galeões nos cofres dos alunos',
       CAST(COALESCE(SUM(saldo_galeoes), 0) AS CHAR)
FROM aluno;
```

## 7. Views — quadros de avisos de Hogwarts

```sql
-- Questão 31: placar das casas
CREATE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa;

-- Questão 32: boletim completo
CREATE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula AS m
INNER JOIN aluno AS a ON a.id_aluno = m.id_aluno
LEFT JOIN casa AS c ON c.id_casa = a.id_casa
INNER JOIN disciplina AS d ON d.id_disc = m.id_disc
LEFT JOIN professor AS p ON p.id_prof = d.id_prof;

-- Questão 33: extrato da loja
CREATE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra AS co
INNER JOIN aluno AS a ON a.id_aluno = co.id_aluno
INNER JOIN produto AS pr ON pr.id_produto = co.id_produto;

-- Questão 34: alunos destaque
CREATE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno AS a
INNER JOIN casa AS c ON c.id_casa = a.id_casa
INNER JOIN matricula AS m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questão 35: quadro de professores
CREATE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Não é diretor') AS casa_que_dirige,
       (SELECT COUNT(*)
        FROM disciplina AS d
        WHERE d.id_prof = p.id_prof) AS quantidade_disciplinas,
       (SELECT COALESCE(SUM(r.pontos), 0)
        FROM registro_pontos AS r
        WHERE r.id_prof = p.id_prof) AS total_pontos_concedidos
FROM professor AS p
LEFT JOIN casa AS c ON c.id_casa = p.id_casa;

-- Questão 36: consultas utilizando as views
SELECT * FROM vw_placar_casas ORDER BY pontos DESC;

SELECT * FROM vw_boletim
WHERE casa = 'Corvinal'
ORDER BY aluno, disciplina;

SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja
ORDER BY total_faturado DESC;

SELECT * FROM vw_alunos_destaque
ORDER BY media DESC;

SELECT * FROM vw_quadro_professores
ORDER BY total_pontos_concedidos DESC;

-- Questão 37: inserir pontos para Cedrico e consultar a view novamente
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas ORDER BY pontos DESC;

-- A view reflete os dados atuais das tabelas; não precisa ser recriada.

-- Questão 38: substituir a view para incluir também o fundador
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa;
```

## 8. Controle de acesso — DCL

> Execute esta seção conectado com um usuário administrador do MySQL. As senhas abaixo são as definidas no enunciado da atividade e devem ser usadas somente no ambiente acadêmico de testes.

```sql
-- Questão 39: criar usuários locais
CREATE USER 'filch'@'localhost' IDENTIFIED BY 'MadameNorra#1';
CREATE USER 'mcgonagall'@'localhost' IDENTIFIED BY 'Animago#Gato1';
CREATE USER 'dumbledore'@'localhost' IDENTIFIED BY 'Fenix#Fawkes1';

-- Questão 40: Filch consulta somente o placar
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questão 41: permissões da Professora McGonagall
GRANT SELECT, INSERT ON hogwarts.registro_pontos
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.aluno
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.vw_boletim
TO 'mcgonagall'@'localhost';

-- Questão 42: Dumbledore recebe todos os privilégios e pode concedê-los
GRANT ALL PRIVILEGES ON hogwarts.*
TO 'dumbledore'@'localhost'
WITH GRANT OPTION;

-- Questão 43: conferir permissões
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 44: conectado como filch
-- Esta consulta deve funcionar:
-- SELECT * FROM hogwarts.vw_placar_casas;
-- Esta consulta deve falhar com erro 1142 (SELECT command denied):
-- SELECT * FROM hogwarts.aluno;

-- Questão 45: conectado como mcgonagall
-- Inserção permitida; o trigger atualiza a pontuação da casa.
INSERT INTO hogwarts.registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES
(2, 1, 10, 'Ajudou um colega em Transfiguração', '2026-11-10');

-- Este UPDATE deve falhar por falta de privilégio UPDATE na tabela casa:
-- UPDATE hogwarts.casa SET pontos = 1000 WHERE id_casa = 1;

-- O trigger executa com os privilégios do DEFINER (usuário que o criou),
-- por isso consegue atualizar casa mesmo sem conceder UPDATE diretamente
-- para mcgonagall.

-- Questão 46: revogar INSERT de McGonagall
REVOKE INSERT ON hogwarts.registro_pontos
FROM 'mcgonagall'@'localhost';

SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questão 47: criar papel de monitor
CREATE ROLE 'monitor';

GRANT SELECT ON hogwarts.vw_boletim TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

CREATE USER 'percy'@'localhost' IDENTIFIED BY 'Monitor#Chefe1';

GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';

-- A vantagem dos papéis é permitir agrupar permissões e atribuir o mesmo
-- conjunto de acessos a vários usuários, facilitando manutenção e segurança.

-- Questão 48: remover os usuários e o papel criados
DROP USER 'filch'@'localhost';
DROP USER 'mcgonagall'@'localhost';
DROP USER 'dumbledore'@'localhost';
DROP USER 'percy'@'localhost';
DROP ROLE 'monitor';
```

---

## Respostas conceituais — resumo

| Questão | Resposta |
|---|---|
| Chave composta em `matricula` | Impede matrícula duplicada do mesmo aluno na mesma disciplina. |
| Validação `BEFORE` e baixa `AFTER` | Primeiro valida e calcula; depois da inserção efetiva atualiza estoque e saldo. |
| `INNER JOIN` da questão 6.7 | Retorna 12 alunos porque Teddy ainda não pertence a uma casa. |
| `> ANY` | Significa maior que pelo menos um valor da subconsulta, equivalente a ser maior que o menor valor do conjunto. |
| `UNION` x `UNION ALL` | `UNION` elimina duplicados; `UNION ALL` mantém todas as ocorrências. |
| View viva | Consulta os dados atuais das tabelas; alterações nas tabelas aparecem sem recriar a view. |
| `@@autocommit` | Valor 1 indica confirmação automática fora de transações explícitas. DDL pode causar commit implícito. |
| Trigger e permissões | O trigger executa com o contexto de privilégios do seu `DEFINER`, conforme a configuração do MySQL. |
| Papéis (roles) | Facilitam conceder, revogar e administrar permissões de vários usuários em conjunto. |

## Conferência dos resultados

O enunciado fornece os seguintes resultados para validar a execução:

- Carga inicial: 4 casas, 9 professores, 9 disciplinas, 14 alunos, 35 matrículas e 8 produtos.
- Após as exclusões: 8 professores, 13 alunos, 8 disciplinas e 33 matrículas.
- Após os triggers: placar inicial Grifinória 100, Corvinal 50, Lufa-Lufa 35 e Sonserina 30.
- Compras: soma de `valor_total` igual a 474,00 galeões; log de auditoria com 1 linha.
- Transações: após a questão 29, Lufa-Lufa fica com 50 pontos e `registro_pontos` tem 17 linhas.
- Views: `vw_alunos_destaque` retorna 5 alunos; Hermione aparece com média 9,60.
- Após a questão 37, Lufa-Lufa passa a 70 pontos.
- DCL: Filch deve receber erro 1142 ao consultar diretamente a tabela `aluno`; após a questão 45, Grifinória fica com 110 pontos.

> **Observação importante:** execute as etapas na ordem. As consultas e os valores de conferência dependem dos dados, atualizações, triggers e transações anteriores. Se algum resultado divergir, confira se todos os blocos anteriores foram executados e se os testes que deveriam falhar foram mantidos comentados.
