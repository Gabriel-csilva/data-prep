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
