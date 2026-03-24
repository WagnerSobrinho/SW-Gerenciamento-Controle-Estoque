--VERSÃO 1 — Usando o Código de Barras (recomendado)
--Essa é a forma mais correta, já que o EAN-13 é o identificador operacional

--Exemplo: venda de 2 unidades do produto com EAN‑13
BEGIN TRANSACTION;

DECLARE @CodigoBarras CHAR(13) = '7890001000016';
DECLARE @id_produto VARCHAR(30);

-- Obter o id_produto interno
SELECT @id_produto = id_produto
FROM p1.produto
WHERE CodigoBarras = @CodigoBarras;

-- Criar o pedido
INSERT INTO p1.pedido (cliente_id, vendedor_id, valor_total, status)
VALUES (10, 2, 76, 'Finalizado');

DECLARE @id_pedido INT = SCOPE_IDENTITY();

-- Inserir item
INSERT INTO p1.item_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal)
VALUES (@id_pedido, @id_produto, 2, 38, 76);

-- Atualizar estoque
UPDATE p1.produto
SET estoque = estoque - 2
WHERE id_produto = @id_produto;

-- Registrar movimentação
INSERT INTO p1.movimentacaoestoque (produto_id, tipomovimento, quantidade, referencia)
VALUES (@id_produto, 'VENDA', 2, 'Pedido ' + CAST(@id_pedido AS NVARCHAR));

COMMIT;

--VERSÃO 2 — Usando o id_produto textual
--Se você quiser usar o código interno gerado pela procedure, por exemplo: 1010-000001/123

BEGIN TRANSACTION;

DECLARE @id_produto VARCHAR(30) = '1010-000001/123';

INSERT INTO p1.pedido (cliente_id, vendedor_id, valor_total, status)
VALUES (10, 2, 76, 'Finalizado');

DECLARE @id_pedido INT = SCOPE_IDENTITY();

INSERT INTO p1.item_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal)
VALUES (@id_pedido, @id_produto, 2, 38, 76);

UPDATE p1.produto
SET estoque = estoque - 2
WHERE id_produto = @id_produto;

INSERT INTO p1.movimentacaoestoque (produto_id, tipomovimento, quantidade, referencia)
VALUES (@id_produto, 'VENDA', 2, 'Pedido ' + CAST(@id_pedido AS NVARCHAR));

COMMIT;



--Procedure de VENDA (com atualização de estoque + movimentação)
--Essa procedure:
-- recebe EAN‑13
-- valida estoque
-- cria pedido
-- cria item
-- atualiza estoque
-- registra movimentação

CREATE PROCEDURE p1.realizar_venda
(
    @CodigoBarras CHAR(13),
    @cliente_id INT,
    @vendedor_id INT,
    @quantidade INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_produto VARCHAR(30);
    DECLARE @preco DECIMAL(10,2);
    DECLARE @estoqueAtual INT;
    DECLARE @subtotal DECIMAL(10,2);
    DECLARE @id_pedido INT;

    -- Obter produto
    SELECT 
        @id_produto = id_produto,
        @preco = preco,
        @estoqueAtual = estoque
    FROM p1.produto
    WHERE CodigoBarras = @CodigoBarras;

    IF @id_produto IS NULL
    BEGIN
        RAISERROR('Produto não encontrado para o EAN informado.', 16, 1);
        RETURN;
    END

    -- Verificar estoque
    IF @estoqueAtual < @quantidade
    BEGIN
        RAISERROR('Estoque insuficiente.', 16, 1);
        RETURN;
    END

    SET @subtotal = @preco * @quantidade;

    BEGIN TRANSACTION;

    -- Criar pedido
    INSERT INTO p1.pedido (cliente_id, vendedor_id, data_pedido, valor_total, status)
    VALUES (@cliente_id, @vendedor_id, GETDATE(), @subtotal, 'Finalizado');

    SET @id_pedido = SCOPE_IDENTITY();

    -- Criar item
    INSERT INTO p1.item_pedido (pedido_id, produto_id, quantidade, preco_unitario, subtotal)
    VALUES (@id_pedido, @id_produto, @quantidade, @preco, @subtotal);

    -- Atualizar estoque
    UPDATE p1.produto
    SET estoque = estoque - @quantidade
    WHERE id_produto = @id_produto;

    -- Registrar movimentação
    INSERT INTO p1.movimentacaoestoque (produto_id, tipomovimento, quantidade, referencia)
    VALUES (@id_produto, 'VENDA', @quantidade, 'Pedido ' + CAST(@id_pedido AS NVARCHAR));

    COMMIT;
END;
GO

--O que acontece ao executar a procedure:
-- Verifica se o produto existe pelo EAN‑13
-- Verifica estoque
-- Cria o pedido
-- Cria o item
-- Atualiza o estoque
-- Registra a movimentação

EXEC p1.realizar_venda
    @CodigoBarras = '7890001000016',
    @cliente_id = 10,
    @vendedor_id = 2,
    @quantidade = 2;


--Procedure de ENTRADA DE ESTOQUE (compra, reposição, devolução)
--Essa procedure:
-- recebe EAN‑13
-- adiciona estoque
-- registra movimentação

CREATE PROCEDURE p1.entrada_estoque
(
    @CodigoBarras CHAR(13),
    @quantidade INT,
    @referencia NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_produto VARCHAR(30);

    SELECT @id_produto = id_produto
    FROM p1.produto
    WHERE CodigoBarras = @CodigoBarras;

    IF @id_produto IS NULL
    BEGIN
        RAISERROR('Produto não encontrado para o EAN informado.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE p1.produto
    SET estoque = estoque + @quantidade
    WHERE id_produto = @id_produto;

    INSERT INTO p1.movimentacaoestoque (produto_id, tipomovimento, quantidade, referencia)
    VALUES (@id_produto, 'ENTRADA', @quantidade, @referencia);

    COMMIT;
END;
GO

--O que acontece se executar a procedure:
-- Aumenta o estoque
-- Registra movimentação do tipo ENTRADA

EXEC p1.entrada_estoque
    @CodigoBarras = '7890001000016',
    @quantidade = 50,
    @referencia = 'Compra fornecedor ABC';




--Procedure de CONSULTA por EAN‑13
--Retorna:
-- id_produto
-- nome
-- categoria
-- preço
-- estoque
-- movimentações recentes

CREATE PROCEDURE p1.consultar_produto_por_ean
(
    @CodigoBarras CHAR(13)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.id_produto,
        p.CodigoBarras,
        p.nome,
        p.categoria,
        p.preco,
        p.custo,
        p.estoque
    FROM p1.produto p
    WHERE p.CodigoBarras = @CodigoBarras;

    SELECT TOP 20
        m.tipomovimento,
        m.quantidade,
        m.datamovimento,
        m.referencia
    FROM p1.movimentacaoestoque m
    INNER JOIN p1.produto p ON p.id_produto = m.produto_id
    WHERE p.CodigoBarras = @CodigoBarras
    ORDER BY m.datamovimento DESC;
END;
GO

