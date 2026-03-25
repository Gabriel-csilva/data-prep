CREATE SCHEMA ecommerce;

--Tabelas sem FK
CREATE TABLE ecommerce.etnia (
    id_etnia SERIAL PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE ecommerce.categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

CREATE TABLE ecommerce.fornecedor (
    id_fornecedor SERIAL PRIMARY KEY,
    nome_fantasia VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    contato VARCHAR(100)
);

CREATE TABLE ecommerce.promocao (
    id_promocao SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    desconto_percentual DECIMAL(5,2) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL
);

CREATE TABLE ecommerce.cores (
    id_cor SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    valor_adicional DECIMAL(10,2) DEFAULT 0.00,
    quantidade_estoque INT DEFAULT 0 NOT NULL
);

CREATE TABLE ecommerce.materiais (
    id_material SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    valor_adicional DECIMAL(10,2) DEFAULT 0.00,
    quantidade_estoque INT DEFAULT 0 NOT NULL
);

CREATE TABLE ecommerce.estampas (
    id_estampa SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    valor_adicional DECIMAL(10,2) DEFAULT 0.00,
    quantidade_estoque INT DEFAULT 0 NOT NULL
);

CREATE TABLE ecommerce.textos_personalizados (
    id_texto SERIAL PRIMARY KEY,
    limite_caracteres INT NOT NULL,
    valor_adicional DECIMAL(10,2) DEFAULT 0.00
);

--Tabelas com FK 
CREATE TABLE ecommerce.cliente (
    id_cliente SERIAL PRIMARY KEY,
    id_etnia INT NOT NULL REFERENCES ecommerce.etnia(id_etnia),
    nome VARCHAR(150) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    idade INT
);


CREATE TABLE ecommerce.endereco (
    id_endereco SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES ecommerce.cliente(id_cliente),
    tipo_endereco VARCHAR(20) NOT NULL CHECK (tipo_endereco IN ('Entrega', 'Cobrança', 'Ambos')),
    cep VARCHAR(10) NOT NULL,
    logradouro VARCHAR(200) NOT NULL,
    bairro VARCHAR(100),
    cidade VARCHAR(100) NOT NULL,
    pais VARCHAR(50) DEFAULT 'Brasil'
);


CREATE TABLE ecommerce.produto (
    id_produto SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL REFERENCES ecommerce.categoria(id_categoria),
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco_base DECIMAL(10,2) NOT NULL
);

CREATE TABLE ecommerce.produto_fornecedor (
    id_produto INT NOT NULL REFERENCES ecommerce.produto(id_produto),
    id_fornecedor INT NOT NULL REFERENCES ecommerce.fornecedor(id_fornecedor),
    PRIMARY KEY (id_produto, id_fornecedor)
);

CREATE TABLE ecommerce.categoria_promocao (
    id_categoria INT NOT NULL REFERENCES ecommerce.categoria(id_categoria),
    id_promocao INT NOT NULL REFERENCES ecommerce.promocao(id_promocao),
    PRIMARY KEY (id_categoria, id_promocao)
);

CREATE TABLE ecommerce.pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES ecommerce.cliente(id_cliente),
    id_endereco_entrega INT NOT NULL REFERENCES ecommerce.endereco(id_endereco),
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pedido VARCHAR(50) DEFAULT 'Pendente',
    metodo_pagamento VARCHAR(50),
    codigo_rastreio VARCHAR(100),
    valor_total_pedido DECIMAL(10,2) NOT NULL
);

CREATE TABLE ecommerce.item_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL REFERENCES ecommerce.pedido(id_pedido),
    id_produto INT NOT NULL REFERENCES ecommerce.produto(id_produto),
    quantidade INT NOT NULL,
    preco_base_aplicado DECIMAL(10,2) NOT NULL, 
    preco_personalizacoes_total DECIMAL(10,2) DEFAULT 0.00
);


CREATE TABLE ecommerce.item_pedido_personalizacao (
    id_detalhe SERIAL PRIMARY KEY,
    id_item INT NOT NULL REFERENCES ecommerce.item_pedido(id_item),
    tipo_opcao VARCHAR(50) NOT NULL, -- 'Cor', 'Material', 'Estampa', 'Texto'
    id_referencia INT NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL
);


CREATE TABLE ecommerce.avaliacao (
    id_avaliacao SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES ecommerce.cliente(id_cliente),
    id_produto INT NOT NULL REFERENCES ecommerce.produto(id_produto),
    nota INT NOT NULL CHECK (nota >= 1 AND nota <= 5),
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



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
