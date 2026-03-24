--RELATORIOS GERENCIAIS
--Faturamento Total

SELECT SUM(valor_total) AS FaturamentoTotal
FROM p1.pedido
WHERE Status = 'Finalizado';

--Vendas por vendedor
SELECT 
nome,
SUM(P.valor_total) AS TotalVendido
FROM p1.pedido P
JOIN p1.vendedor V
ON P.vendedor_id = V.id_vendedor
GROUP BY V.nome
ORDER BY TotalVendido DESC;

--Produtos mais vendidos
SELECT 
PR.nome,
SUM(IPE.quantidade) AS QuantidadeVendida
FROM p1.item_pedido IPE
JOIN p1.produto PR
ON IPE.produto_id = PR.id_produto
GROUP BY PR.Nome
ORDER BY QuantidadeVendida DESC;