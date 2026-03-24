SELECT TOP 100 *
FROM p1.produto
WHERE categoria = 'Elétrica'
ORDER BY id_produto;


SELECT TOP 10 *
FROM p1.produto
WHERE categoria = 'Hidráulica'
ORDER BY id_produto;


SELECT id_vendedor,
nome
FROM p1.vendedor
WHERE ativo = '1'
ORDER BY nome;