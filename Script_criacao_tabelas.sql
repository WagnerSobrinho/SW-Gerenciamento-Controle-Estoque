--SQL SERVER
--CRIAÇÃO DE TABELAS


USE BD_LOJA_CONSTRUCAO_SQL
GO

CREATE TABLE p1.empresa (
    id_Empresa INT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100),
    cnpj NVARCHAR(20)
);

CREATE TABLE p1.cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    empresa_id INT NOT NULL,
    nome VARCHAR(100),
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(200),
    FOREIGN KEY (empresa_id) REFERENCES p1.empresa(id_empresa)
);

CREATE TABLE p1.vendedor (
    id_vendedor INT IDENTITY(1,1) PRIMARY KEY,
    empresa_id INT,
    nome VARCHAR(100),
    telefone VARCHAR(20),
    ativo BIT DEFAULT 1,
    FOREIGN KEY (empresa_id) REFERENCES p1.empresa(id_empresa)
);

-- AJUSTADO PARA COMPATIBILIZAR COM A PROCEDURE
CREATE TABLE p1.produto (
    id_produto VARCHAR(30) PRIMARY KEY,      -- código interno gerado pela procedure
    CodigoBarras CHAR(13) UNIQUE NOT NULL,   -- EAN-13 válido
    empresa_id INT NOT NULL,
    nome VARCHAR(100),
    categoria VARCHAR(50),
    preco DECIMAL(10,2),
    custo DECIMAL(10,2),
    estoque INT,
    FOREIGN KEY (empresa_id) REFERENCES p1.empresa(id_empresa)
);


CREATE TABLE p1.pedido (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT,
    vendedor_id INT,
    data_pedido DATE,
    valor_total DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (cliente_id) REFERENCES p1.cliente(id_cliente),
    FOREIGN KEY (vendedor_id) REFERENCES p1.vendedor(id_vendedor)
);

CREATE TABLE p1.item_pedido (
    id_item INT IDENTITY(1,1) PRIMARY KEY,
    pedido_id INT,
    produto_id VARCHAR(30),                  -- ajustado
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    FOREIGN KEY (pedido_id) REFERENCES p1.pedido(id_pedido),
    FOREIGN KEY (produto_id) REFERENCES p1.produto(id_produto)
);


CREATE TABLE p1.entrega (
    id_entrega INT IDENTITY(1,1) PRIMARY KEY,
    pedido_id INT,
    endereco_entrega VARCHAR(200),
    data_entrega DATE,
    status_entrega VARCHAR(50),
    FOREIGN KEY (pedido_id) REFERENCES p1.pedido(id_pedido)
);

CREATE TABLE p1.pagamento (
    id_pagamento INT IDENTITY(1,1) PRIMARY KEY,
    pedido_id INT,
    forma_pagamento VARCHAR(50),
    valor_pago DECIMAL(10,2),
    data_pagamento DATE,
    FOREIGN KEY (pedido_id) REFERENCES p1.pedido(id_pedido)
);

-- AJUSTADO PARA REFERENCIAR O NOVO TIPO
CREATE TABLE p1.movimentacaoestoque (
    id_movimento INT IDENTITY(1,1) PRIMARY KEY,
    produto_id VARCHAR(30),                  -- já estava correto
    tipomovimento NVARCHAR(20),
    quantidade INT,
    datamovimento DATETIME DEFAULT GETDATE(),
    referencia NVARCHAR(100),
    FOREIGN KEY (produto_id) REFERENCES p1.produto(id_produto)
);




SELECT 
    name 
FROM sys.foreign_keys 
WHERE parent_object_id = OBJECT_ID('p1.cliente');

ALTER TABLE p1.cliente DROP CONSTRAINT FK__cliente__empresa__4CA06362;


SELECT 
    fk.name AS nome_da_fk,
    tp.name AS tabela_filha,
    cp.name AS coluna_filha
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
WHERE tr.name = 'cliente';

ALTER TABLE p1.pedido 
DROP CONSTRAINT FK__pedido__cliente__5629CD9C;

--IDENTIFICAR QUAIS TABELA TEM RELACIONAMENTO ENTRE SI E CRIA O CÓDIGO PARA ALTERAÇÃO DA FK

SELECT 
    fk.name AS nome_da_fk,
    'ALTER TABLE ' + sch.name + '.' + tp.name + ' DROP CONSTRAINT ' + fk.name AS comando_pronto
FROM sys.foreign_keys fk
JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN sys.schemas sch ON tp.schema_id = sch.schema_id
JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tr.name = 'cliente';

--ALTERAÇÃO DE FK
ALTER TABLE p1.pedido DROP CONSTRAINT FK__pedido__cliente___5629CD9C

--APAGAR TABELA
DROP TABLE p1.cliente;
DROP TABLE p1.empresa;
DROP TABLE p1.entrega;
DROP TABLE p1.item_pedido;
DROP TABLE p1.pagamento;
DROP TABLE p1.pedido;
DROP TABLE p1.produto;
DROP TABLE p1.vendedor;
DROP TABLE p1.movimentacaoestoque

--CRIAÇÃO DA FK NA TABELA PEDIDO
ALTER TABLE p1.pedido
ADD CONSTRAINT FK_pedido_cliente
FOREIGN KEY (cliente_id)
REFERENCES p1.cliente(id_cliente);

EXEC sp_help 'p1.produto';
