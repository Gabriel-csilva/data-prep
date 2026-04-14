

/* etl_dimensions */

-- 1(DUMMY)

-- Garante que a Fato não quebre se houver nulos no OLTP

INSERT INTO schema_dw.dim_cliente (sk_cliente, id_cliente_origem, nome) VALUES (-1, 0, 'Não Informado') ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_produto (sk_produto, id_produto_origem, nome, data_inicio, flag_ativo) VALUES (-1, 0, 'Não Informado', '1900-01-01', TRUE) ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_tempo (sk_tempo, dia, mes, ano) VALUES (-1, 0, 0, 0) ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_fornecedor (sk_fornecedor, id_fornecedor_origem, nome_fantasia) VALUES (-1, 0, 'Não Informado') ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_endereco (sk_endereco, id_endereco_origem, cidade, data_inicio, flag_ativo) VALUES (-1, 0, 'Não Informado', '1900-01-01', TRUE) ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_promocao (sk_promocao, id_promocao_origem, nome) 
VALUES (-1, 0, 'Sem Promoção') ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_personalizacao (sk_personalizacao, id_personalizacao_origem, tipo_opcao) 
VALUES (-1, 0, 'Nenhuma') ON CONFLICT DO NOTHING;

INSERT INTO schema_dw.dim_avaliacao (sk_avaliacao, id_avaliacao_origem, nota) 
VALUES (-1, 0, 1) ON CONFLICT DO NOTHING;


-- 2 CARGA SCD TIPO 0: DIM_TEMPO

INSERT INTO schema_dw.dim_tempo (dia, mes, ano, trimestre, semestre)
SELECT 
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    CASE WHEN EXTRACT(MONTH FROM d) <= 6 THEN 1 ELSE 2 END
FROM generate_series('2020-01-01'::date, '2030-12-31'::date, interval '1 day') AS d
ON CONFLICT DO NOTHING;


-- 3 CARGA SCD TIPO 1: CLIENTE E FORNECEDOR

MERGE INTO schema_dw.dim_cliente dc
USING (SELECT c.id_cliente, c.nome, c.idade, c.email, e.descricao as etnia 
       FROM ecommerce.cliente c JOIN ecommerce.etnia e ON c.id_etnia = e.id_etnia) src
ON dc.id_cliente_origem = src.id_cliente
WHEN MATCHED THEN 
    UPDATE SET nome = src.nome, idade = src.idade, email = src.email, etnia = src.etnia
WHEN NOT MATCHED THEN 
    INSERT (id_cliente_origem, nome, idade, email, etnia) VALUES (src.id_cliente, src.nome, src.idade, src.email, src.etnia);

MERGE INTO schema_dw.dim_fornecedor df
USING ecommerce.fornecedor src ON df.id_fornecedor_origem = src.id_fornecedor
WHEN MATCHED THEN UPDATE SET nome_fantasia = src.nome_fantasia, cnpj = src.cnpj, contato = src.contato
WHEN NOT MATCHED THEN INSERT (id_fornecedor_origem, nome_fantasia, cnpj, contato) VALUES (src.id_fornecedor, src.nome_fantasia, src.cnpj, src.contato);


-- 4 CARGA SCD TIPO 2: PRODUTO 

DO $$
DECLARE rec RECORD;
BEGIN
    FOR rec IN SELECT p.id_produto, p.nome, cat.nome as categoria, p.preco_base 
               FROM ecommerce.produto p JOIN ecommerce.categoria cat ON p.id_categoria = cat.id_categoria
    LOOP
        -- Se o produto não existe, insere
        IF NOT EXISTS (SELECT 1 FROM schema_dw.dim_produto WHERE id_produto_origem = rec.id_produto) THEN
            INSERT INTO schema_dw.dim_produto (id_produto_origem, nome, categoria, preco_base, data_inicio, flag_ativo)
            VALUES (rec.id_produto, rec.nome, rec.categoria, rec.preco_base, CURRENT_DATE, TRUE);
        -- Se existe e mudou algo crítico, versiona
        ELSIF EXISTS (SELECT 1 FROM schema_dw.dim_produto WHERE id_produto_origem = rec.id_produto AND flag_ativo = TRUE 
                      AND (nome <> rec.nome OR categoria <> rec.categoria OR preco_base <> rec.preco_base)) THEN
            UPDATE schema_dw.dim_produto SET data_fim = CURRENT_DATE, flag_ativo = FALSE 
            WHERE id_produto_origem = rec.id_produto AND flag_ativo = TRUE;
            
            INSERT INTO schema_dw.dim_produto (id_produto_origem, nome, categoria, preco_base, data_inicio, flag_ativo)
            VALUES (rec.id_produto, rec.nome, rec.categoria, rec.preco_base, CURRENT_DATE, TRUE);
        END IF;
    END LOOP;
END $$;

------------------------------------------------------------------------------------------------------------------------------


/* etl_facts */


INSERT INTO schema_dw.fato_vendas (
    sk_cliente, sk_produto, sk_fornecedor, sk_tempo, sk_promocao, 
    sk_endereco, sk_personalizacao, sk_avaliacao, 
    quantidade_vendida, valor_total_item, valor_total_pedido, 
    desconto_aplicado, valor_personalizacoes
)
SELECT 
    COALESCE(dc.sk_cliente, -1),
    COALESCE(dp.sk_produto, -1),
    COALESCE(df.sk_fornecedor, -1),
    COALESCE(dt.sk_tempo, -1),
    COALESCE(dpr.sk_promocao, -1),
    COALESCE(de.sk_endereco, -1),
    COALESCE(dper.sk_personalizacao, -1),
    COALESCE(dav.sk_avaliacao, -1),
    i.quantidade,
    (i.preco_base_aplicado * i.quantidade),
    p.valor_total_pedido,
    COALESCE(pr.desconto_percentual, 0),
    i.preco_personalizacoes_total
FROM ecommerce.pedido p
JOIN ecommerce.item_pedido i ON p.id_pedido = i.id_pedido
-- 1. Lookup de Tempo (SCD 0)
LEFT JOIN schema_dw.dim_tempo dt ON dt.dia = EXTRACT(DAY FROM p.data_pedido) 
                                AND dt.mes = EXTRACT(MONTH FROM p.data_pedido) 
                                AND dt.ano = EXTRACT(YEAR FROM p.data_pedido)
-- 2. Lookup de Cliente (SCD 1)
LEFT JOIN schema_dw.dim_cliente dc ON dc.id_cliente_origem = p.id_cliente
-- 3. Lookup Histórico de Produto (SCD 2) - SEM flag_ativo para permitir buscar versões antigas
LEFT JOIN schema_dw.dim_produto dp ON dp.id_produto_origem = i.id_produto 
                                  AND p.data_pedido::date >= dp.data_inicio 
                                  AND (p.data_pedido::date <= dp.data_fim OR dp.data_fim IS NULL)
-- 4. Lookup de Fornecedor
LEFT JOIN ecommerce.produto_fornecedor pf ON pf.id_produto = i.id_produto
LEFT JOIN schema_dw.dim_fornecedor df ON df.id_fornecedor_origem = pf.id_fornecedor
-- 5. Lookup Histórico de Endereço (SCD 2)
LEFT JOIN schema_dw.dim_endereco de ON de.id_endereco_origem = p.id_endereco_entrega 
                                   AND p.data_pedido::date >= de.data_inicio 
                                   AND (p.data_pedido::date <= de.data_fim OR de.data_fim IS NULL)
-- 6. Lookup de Promoção
LEFT JOIN ecommerce.categoria_promocao cp ON dp.id_produto_origem = i.id_produto -- via regra de negócio
LEFT JOIN ecommerce.promocao pr ON cp.id_promocao = pr.id_promocao
LEFT JOIN schema_dw.dim_promocao dpr ON dpr.id_promocao_origem = pr.id_promocao
-- 7. Lookup de Personalização e Avaliação
LEFT JOIN schema_dw.dim_personalizacao dper ON dper.id_personalizacao_origem = i.id_item
LEFT JOIN ecommerce.avaliacao av ON av.id_produto = i.id_produto AND av.id_cliente = p.id_cliente
LEFT JOIN schema_dw.dim_avaliacao dav ON dav.id_avaliacao_origem = av.id_avaliacao

-- (Não duplica se rodar de novo)
WHERE NOT EXISTS (
    SELECT 1 FROM schema_dw.fato_vendas f 
    WHERE f.sk_produto = dp.sk_produto 
      AND f.sk_tempo = dt.sk_tempo 
      AND f.sk_cliente = dc.sk_cliente
      -- Adicione outros campos se quiser uma trava ainda mais específica
);