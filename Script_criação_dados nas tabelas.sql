--SQL SERVER
--DADOS SIMULADOS

--EMPRESA
INSERT INTO p1.empresa (nome, cnpj)
VALUES ('Constrular Materiais', '12.345.678/0001-99');



-- 5 VENDEDORES

INSERT INTO p1.vendedor (empresa_id, nome, telefone) VALUES
(1, 'Carlos Silva',    '11988880001'),
(1, 'João Santos',     '11988880002'),
(1, 'Marcos Lima',     '11988880003'),
(1, 'Ana Costa',       '11988880004'),
(1, 'Fernanda Alves',  '11988880005');


SELECT * FROM p1.vendedor

--CRIAR 100 CLIENTES ALEATÓRIOS

CREATE PROCEDURE p1.inserir_clientes
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;

    WHILE @i <= 100
    BEGIN
        INSERT INTO p1.cliente (empresa_id, nome, telefone, email, endereco)
        VALUES (
            1,
            CONCAT('Cliente ', @i),
            CONCAT('1199999', RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4)),
            CONCAT('cliente', @i, '@email.com'),
            CONCAT('Rua ', @i, ', São Paulo')
        );

        SET @i = @i + 1;
    END
END;
GO

EXEC p1.inserir_clientes;

SELECT * FROM p1.cliente

--CRIAR 100 PRODUTOS
CREATE PROCEDURE p1.inserir_produtos
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @dv INT;
    DECLARE @id_produto INT;
    DECLARE @categoria VARCHAR(50);

    WHILE @i <= 100
    BEGIN
        -- Calcula dígito verificador
        SET @dv = @i % 9;
        IF @dv = 0 SET @dv = 9;

        -- Monta o código final
        SET @id_produto = (@i * 10) + @dv;

        -- Define categoria
        SET @categoria = CASE 
                            WHEN @i % 5 = 0 THEN 'Ferramentas'
                            WHEN @i % 5 = 1 THEN 'Hidráulica'
                            WHEN @i % 5 = 2 THEN 'Elétrica'
                            WHEN @i % 5 = 3 THEN 'Construção'
                            ELSE 'Acabamento'
                         END;

        INSERT INTO p1.produto (id_produto, empresa_id, nome, categoria, preco, custo, estoque)
        VALUES (
            @id_produto,
            1,
            CONCAT('Produto ', @i),
            @categoria,
            CAST((10 + (@i * 0.8)) AS DECIMAL(10,2)),
            CAST((5 + (@i * 0.5)) AS DECIMAL(10,2)),
            (10 + (@i % 20))
        );

        SET @i = @i + 1;
    END
END;
GO

EXEC p1.inserir_produtos;

--FUNÇÃO NECESSÁRIA PARA GERAR EAN13

CREATE FUNCTION p1.fn_GerarEAN13 (@seq INT)
RETURNS CHAR(13)
AS
BEGIN
    DECLARE @prefixo CHAR(3) = '789';   -- Brasil
    DECLARE @empresa CHAR(4) = '0001';  -- código da empresa
    DECLARE @produto CHAR(5) = RIGHT('00000' + CAST(@seq AS VARCHAR(5)), 5);

    DECLARE @base12 CHAR(12) = @prefixo + @empresa + @produto;

    DECLARE @somaImpar INT = 
          (SUBSTRING(@base12,1,1) + SUBSTRING(@base12,3,1) + SUBSTRING(@base12,5,1)
         + SUBSTRING(@base12,7,1) + SUBSTRING(@base12,9,1) + SUBSTRING(@base12,11,1));

    DECLARE @somaPar INT =
          (SUBSTRING(@base12,2,1) + SUBSTRING(@base12,4,1) + SUBSTRING(@base12,6,1)
         + SUBSTRING(@base12,8,1) + SUBSTRING(@base12,10,1) + SUBSTRING(@base12,12,1)) * 3;

    DECLARE @total INT = @somaImpar + @somaPar;
    DECLARE @dv INT = (10 - (@total % 10)) % 10;

    RETURN @base12 + CAST(@dv AS CHAR(1));
END;
GO

--CRIAÇÃO DE DADOS NA TABELA PRODUTO

CREATE PROCEDURE p1.inserir_produtos_10000
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @categoria VARCHAR(50);
    DECLARE @catCodigo VARCHAR(10);
    DECLARE @seq VARCHAR(10);
    DECLARE @dv VARCHAR(5);
    DECLARE @id_produto VARCHAR(30);
    DECLARE @nome VARCHAR(100);
    DECLARE @CodigoBarras CHAR(13);

    WHILE @i <= 10000
    BEGIN
        -- Categoria real
        SET @categoria = CASE 
                            WHEN @i % 10 = 1 THEN 'Hidráulica'
                            WHEN @i % 10 = 2 THEN 'Elétrica'
                            WHEN @i % 10 = 3 THEN 'Construção'
                            WHEN @i % 10 = 4 THEN 'Acabamento'
                            WHEN @i % 10 = 5 THEN 'Ferramentas'
                            WHEN @i % 10 = 6 THEN 'Pintura'
                            WHEN @i % 10 = 7 THEN 'Jardinagem'
                            WHEN @i % 10 = 8 THEN 'EPI'
                            WHEN @i % 10 = 9 THEN 'Madeiras'
                            ELSE 'Pisos e Revestimentos'
                         END;

        -- Código da categoria
        SET @catCodigo = CASE @categoria
                            WHEN 'Hidráulica' THEN '1010'
                            WHEN 'Elétrica' THEN '2020'
                            WHEN 'Construção' THEN '3030'
                            WHEN 'Acabamento' THEN '4040'
                            WHEN 'Ferramentas' THEN '5050'
                            WHEN 'Pintura' THEN '6060'
                            WHEN 'Jardinagem' THEN '7070'
                            WHEN 'EPI' THEN '8080'
                            WHEN 'Madeiras' THEN '9090'
                            WHEN 'Pisos e Revestimentos' THEN '1110'
                         END;

        -- Nome real do produto (mantido exatamente como você criou)
        SET @nome = CASE @categoria
                        WHEN 'Hidráulica' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Registro de pressão 1/2"'),('Torneira metálica'),('Joelho PVC 90º'),
                                ('Curva PVC 45º'),('Tubo PVC 50mm'),('Caixa sifonada'),
                                ('Válvula de retenção'),('Adaptador soldável'),('Conector metálico'),
                                ('Chuveiro elétrico')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Elétrica' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Tomada 10A'),('Interruptor simples'),('Fio 2,5mm'),
                                ('Disjuntor 20A'),('Eletroduto corrugado'),('Lâmpada LED 9W'),
                                ('Extensão 5m'),('Conector Wago'),('Quadro de distribuição'),
                                ('Campainha elétrica')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Construção' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Cimento CP-II'),('Areia fina 20kg'),('Pedra brita 20kg'),
                                ('Argamassa AC-II'),('Vergalhão 8mm'),('Tela soldada'),
                                ('Massa corrida'),('Cal hidratada'),('Bloco cerâmico'),
                                ('Tijolo baiano')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Acabamento' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Rodapé MDF'),('Massa acrílica'),('Silicone branco'),
                                ('Rejunte cinza'),('Kit dobradiça'),('Fechadura interna'),
                                ('Maçaneta inox'),('Espelho 60x40'),('Cuba de apoio'),
                                ('Porta de madeira')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Ferramentas' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Martelo 500g'),('Trena 5m'),('Furadeira 600W'),
                                ('Serra tico-tico'),('Alicate universal'),('Chave Philips'),
                                ('Chave de fenda'),('Nível bolha'),('Esmerilhadeira'),
                                ('Parafusadeira')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Pintura' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Tinta acrílica 18L'),('Rolo de lã'),('Bandeja de pintura'),
                                ('Lixa 120'),('Pincel 2"'),('Selador acrílico'),
                                ('Massa para madeira'),('Fita crepe'),('Removedor de tinta'),
                                ('Spray colorido')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Jardinagem' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Pá de jardinagem'),('Mangueira 20m'),('Regador 5L'),
                                ('Adubo NPK'),('Tesoura de poda'),('Pulverizador'),
                                ('Sementes de grama'),('Carrinho de mão'),('Luvas de borracha'),
                                ('Enxada')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'EPI' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Luva nitrílica'),('Óculos de proteção'),('Capacete de segurança'),
                                ('Protetor auricular'),('Bota de PVC'),('Máscara PFF2'),
                                ('Avental PVC'),('Cinto de segurança'),('Creme de proteção'),
                                ('Respirador semifacial')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Madeiras' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Tábuas de pinus'),('Sarrafo 2x3'),('Compensado 10mm'),
                                ('MDF 15mm'),('OSB 12mm'),('Viga 6x12'),
                                ('Caibro 5x6'),('Ripas de madeira'),('Rodapé de madeira'),
                                ('Prancha tratada')
                            ) AS T(item) ORDER BY NEWID())

                        WHEN 'Pisos e Revestimentos' THEN 
                            (SELECT TOP 1 item FROM (VALUES
                                ('Piso porcelanato 60x60'),('Piso cerâmico 45x45'),
                                ('Revestimento branco'),('Pastilha de vidro'),('Rodapé cerâmico'),
                                ('Argamassa AC-III'),('Nivelador de piso'),('Cunha niveladora'),
                                ('Espaçador 2mm'),('Piso antiderrapante')
                            ) AS T(item) ORDER BY NEWID())
                    END;

        -- Sequencial de 6 dígitos
        SET @seq = RIGHT('000000' + CAST(@i AS VARCHAR(6)), 6);

        -- DV aleatório
        SET @dv = RIGHT('000' + CAST(ABS(CHECKSUM(@catCodigo + @seq)) % 1000 AS VARCHAR(3)), 3);

        -- Código final interno
        SET @id_produto = CONCAT(@catCodigo, '-', @seq, '/', @dv);

        -- Geração do EAN-13
        SET @CodigoBarras = p1.fn_GerarEAN13(@i);

        INSERT INTO p1.produto (id_produto, CodigoBarras, empresa_id, nome, categoria, preco, custo, estoque)
        VALUES (
            @id_produto,
            @CodigoBarras,
            1,
            @nome,
            @categoria,
            CAST((10 + (@i * 0.03)) AS DECIMAL(10,2)),
            CAST((5 + (@i * 0.02)) AS DECIMAL(10,2)),
            (5 + (@i % 50))
        );

        SET @i = @i + 1;
    END
END;
GO

EXEC p1.inserir_produtos_10000;

--REMOVER PROCEDURE ANTIGA
DROP PROCEDURE p1.inserir_produtos_10000;
DROP PROCEDURE p1.inserir_produtos;


SELECT 
    kc.name AS nome_da_pk
FROM sys.key_constraints kc
JOIN sys.tables t ON kc.parent_object_id = t.object_id
WHERE t.name = 'produto'
  AND kc.type = 'PK';



SELECT 
    fk.name AS nome_da_fk,
    'ALTER TABLE ' + sch.name + '.' + tp.name + ' DROP CONSTRAINT ' + fk.name AS comando_pronto
FROM sys.foreign_keys fk
JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN sys.schemas sch ON tp.schema_id = sch.schema_id
JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tr.name = 'produto';

ALTER TABLE p1.produto
DROP CONSTRAINT PK__produto__BA38A6B8725CC801;

ALTER TABLE p1.item_pedido DROP CONSTRAINT FK__item_pedi__produ__5AEE82B9

ALTER TABLE p1.produto
ALTER COLUMN id_produto VARCHAR(30) NOT NULL;

ALTER TABLE p1.produto
ADD CONSTRAINT PK_produto PRIMARY KEY (id_produto);

ALTER TABLE p1.item_pedido
ALTER COLUMN produto_id VARCHAR(30) NOT NULL;


ALTER TABLE p1.item_pedido
ADD CONSTRAINT FK_item_pedido_produto
FOREIGN KEY (produto_id)
REFERENCES p1.produto(id_produto);


SELECT TOP 100 *
FROM p1.produto
WHERE categoria = 'Elétrica'
ORDER BY id_produto;