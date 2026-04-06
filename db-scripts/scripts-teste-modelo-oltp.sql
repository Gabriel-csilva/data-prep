ALUNOS:

GABRIEL CARDOSO DA SILVA RA: 10733004
GABRIELA ADDESSO RUVOLO RA: 10735412


------------


TRUNCATE TABLE 
    ecommerce.etnia, 
    ecommerce.categoria, 
    ecommerce.fornecedor, 
    ecommerce.cores, 
    ecommerce.materiais, 
    ecommerce.estampas, 
    ecommerce.textos_personalizados,
    ecommerce.cliente,
    ecommerce.endereco,
    ecommerce.produto,
    ecommerce.promocao,
    ecommerce.pedido,
    ecommerce.item_pedido,
    ecommerce.item_pedido_personalizacao,
    ecommerce.avaliacao,
    ecommerce.produto_fornecedor,
    ecommerce.categoria_promocao
RESTART IDENTITY CASCADE;



-------------

SELECT
    p.id_produto,
    p.id_categoria,
    p.nome,
    p.descricao,
    p.preco_base,
    c.nome AS nome_categoria,
    c.descricao AS desc_categoria
FROM ecommerce.produto p
LEFT JOIN ecommerce.categoria c
ON c.id_categoria = p.id_categoria


--------------


SELECT * FROM ecommerce.avaliacao

SELECT * FROM ecommerce.categoria

SELECT * FROM ecommerce.categoria_promocao

SELECT * FROM ecommerce.cliente

SELECT * FROM ecommerce.cores

SELECT * FROM ecommerce.endereco

SELECT * FROM ecommerce.estampas

SELECT * FROM ecommerce.etnia

SELECT * FROM ecommerce.fornecedor

SELECT * FROM ecommerce.item_pedido

SELECT * FROM ecommerce.item_pedido_personalizacao

SELECT * FROM ecommerce.materiais

SELECT * FROM ecommerce.pedido

SELECT * FROM ecommerce.produto

SELECT * FROM ecommerce.produto_fornecedor

SELECT * FROM ecommerce.promocao

SELECT * FROM ecommerce.textos_personalizados


----------------



SELECT 
    -- Dados do Pedido
    p.id_pedido,
    p.data_pedido,
    p.status_pedido,
    p.valor_total_pedido AS total_final_do_pedido,
    
    -- Dados do Cliente
    c.nome AS cliente,
    c.cpf,
    e.descricao AS etnia_cliente,
    
    -- Dados de Entrega
    end_ent.logradouro,
    end_ent.cidade,
    
    -- Dados do Produto
    prod.nome AS produto_comprado,
    cat.nome AS categoria_produto,
    ip.preco_base_aplicado AS preco_unitario_base,
    
    -- Personalizações (Concatenadas para facilitar a leitura)
    (SELECT string_agg(ipp.tipo_opcao || ': ' || ipp.valor_cobrado, ' | ') 
     FROM ecommerce.item_pedido_personalizacao ipp 
     WHERE ipp.id_item = ip.id_item) AS detalhes_personalizacao,
     
    ip.preco_personalizacoes_total AS soma_adicionais

FROM 
    ecommerce.pedido p
JOIN 
    ecommerce.cliente c ON p.id_cliente = c.id_cliente
JOIN 
    ecommerce.etnia e ON c.id_etnia = e.id_etnia
JOIN 
    ecommerce.endereco end_ent ON p.id_endereco_entrega = end_ent.id_endereco
JOIN 
    ecommerce.item_pedido ip ON p.id_pedido = ip.id_pedido
JOIN 
    ecommerce.produto prod ON ip.id_produto = prod.id_produto
JOIN 
    ecommerce.categoria cat ON prod.id_categoria = cat.id_categoria

ORDER BY 
    p.id_pedido;
