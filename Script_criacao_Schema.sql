-- Criação de Schemas
-- Um **schema** é uma estrutura lógica que organiza e agrupa objetos de banco de dados 
-- (como tabelas, visões e procedimentos), funcionando como um “container” dentro do banco.

-- dbo = padrão

-- Extra para a aula: TECLA DE ATALHOS
-- F5, CTRL + R (fechar janela de mensagens)
-- CTRL + F4 (fecha consulta)
-- CTRL + SHIFT + R (atualizar janela de scripts

USE BD_LOJA_CONSTRUCAO_SQL
GO

-- Schema padrão
CREATE TABLE TESTE(
	ID_TESTE numeric(4,0),
	CAMPO1 nvarchar(150), 
	CAMPO2 date
);

CREATE schema trovato;

CREATE TABLE trovato.TESTE(
	ID_TESTE numeric(4,0),
	CAMPO1 nvarchar(150), 
	CAMPO2 date
);

DROP SCHEMA trovato;  -- Dará erro. Há objetos atrelados ao schema

DROP TABLE trovato.TESTE;
DROP TABLE dbo.TESTE;

CREATE schema p1;