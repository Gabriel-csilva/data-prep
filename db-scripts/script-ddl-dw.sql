CREATE SCHEMA schema_dw;

--Dimensão Tempo
CREATE TABLE schema_dw.dim_tempo (
    sk_tempo SERIAL PRIMARY KEY,
    dia INT NOT NULL,
    mes INT NOT NULL,
    ano INT NOT NULL,
    trimestre INT,
    semestre INT
);

-- Dimensão Cliente
CREATE TABLE schema_dw.dim_cliente (
    sk_cliente SERIAL PRIMARY KEY,
    id_cliente_origem INT NOT NULL,
    nome VARCHAR(150),
    idade INT,
    email VARCHAR(100),
    etnia VARCHAR(50)
);

-- Dimensão Produto
CREATE TABLE schema_dw.dim_produto (
    sk_produto SERIAL PRIMARY KEY,
    id_produto_origem INT NOT NULL,
    nome VARCHAR(150),
    categoria VARCHAR(100),
    preco_base DECIMAL(10,2),
    data_inicio DATE NOT NULL,
    data_fim DATE,
    flag_ativo BOOLEAN DEFAULT TRUE
);

-- Dimensão Fornecedor
CREATE TABLE schema_dw.dim_fornecedor (
    sk_fornecedor SERIAL PRIMARY KEY,
    id_fornecedor_origem INT NOT NULL,
    nome_fantasia VARCHAR(150),
    cnpj VARCHAR(18),
    contato VARCHAR(100)
);

-- Dimensão Endereço
CREATE TABLE schema_dw.dim_endereco (
    sk_endereco SERIAL PRIMARY KEY,
    id_endereco_origem INT NOT NULL,
    cidade VARCHAR(100),
    estado VARCHAR(100),
    pais VARCHAR(50),
    tipo_endereco VARCHAR(20),
    data_inicio DATE NOT NULL,
    data_fim DATE,
    flag_ativo BOOLEAN DEFAULT TRUE
);

-- Dimensão Promoção
CREATE TABLE schema_dw.dim_promocao (
    sk_promocao SERIAL PRIMARY KEY,
    id_promocao_origem INT NOT NULL,
    nome VARCHAR(100),
    desconto_percentual DECIMAL(5,2),
    data_inicio DATE,
    data_fim DATE
);

-- Dimensão Personalização
CREATE TABLE schema_dw.dim_personalizacao (
    sk_personalizacao SERIAL PRIMARY KEY,
    id_personalizacao_origem INT NOT NULL,
    tipo_opcao VARCHAR(50),
    valor_adicional DECIMAL(10,2)
);

-- Dimensão Avaliação
CREATE TABLE schema_dw.dim_avaliacao (
    sk_avaliacao SERIAL PRIMARY KEY,
    id_avaliacao_origem INT NOT NULL,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT
);

-- Tabela Fato Vendas
CREATE TABLE schema_dw.fato_vendas (
    id_fato SERIAL PRIMARY KEY,
    sk_cliente INT NOT NULL,
    sk_produto INT NOT NULL,
    sk_fornecedor INT NOT NULL,
    sk_tempo INT NOT NULL,
    sk_promocao INT,
    sk_endereco INT NOT NULL,
    sk_personalizacao INT,
    sk_avaliacao INT,
    quantidade_vendida INT NOT NULL,
    valor_total_item DECIMAL(10,2) NOT NULL,
    valor_total_pedido DECIMAL(10,2) NOT NULL,
    desconto_aplicado DECIMAL(10,2),
    valor_personalizacoes DECIMAL(10,2),
    FOREIGN KEY (sk_cliente) REFERENCES schema_dw.dim_cliente(sk_cliente),
    FOREIGN KEY (sk_produto) REFERENCES schema_dw.dim_produto(sk_produto),
    FOREIGN KEY (sk_fornecedor) REFERENCES schema_dw.dim_fornecedor(sk_fornecedor),
    FOREIGN KEY (sk_tempo) REFERENCES schema_dw.dim_tempo(sk_tempo),
    FOREIGN KEY (sk_promocao) REFERENCES schema_dw.dim_promocao(sk_promocao),
    FOREIGN KEY (sk_endereco) REFERENCES schema_dw.dim_endereco(sk_endereco),
    FOREIGN KEY (sk_personalizacao) REFERENCES schema_dw.dim_personalizacao(sk_personalizacao),
    FOREIGN KEY (sk_avaliacao) REFERENCES schema_dw.dim_avaliacao(sk_avaliacao)
);