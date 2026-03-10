# Projeto Prático: Data Prep & Modelagem Dimensional com PostgreSQL

Bem-vindo(a) ao projeto prático de Preparação de Dados (Data Prep)!

O objetivo deste laboratório é construir um pipeline de dados puramente em SQL, lendo dados de um banco de dados transacional (Relacional/ERP) e transformando-os em um modelo analítico (Dimensional/Data Warehouse)

[Image of star schema vs snowflake schema]
.

Aqui, você terá a oportunidade de colocar a mão na massa desenvolvendo scripts de criação de tabelas (DDL) e os processos de extração, transformação e carga (ETL).

## A Ideia Geral do Projeto

Neste repositório, você atuará como Engenheiro(a) de Dados. Sua missão é preencher os arquivos SQL que atualmente estão em branco.

Você deverá estruturar três etapas fundamentais na pasta db-scripts:
1. script-ddl-source.sql: Criar o schema de origem (ex: erp) e as tabelas transacionais (clientes, produtos, pedidos), inserindo alguns dados fictícios.
2. script-ddl-dw.sql: Criar o schema de destino (ex: dw) e as tabelas do modelo dimensional (tabelas Fato e Dimensão).
3. etl-script.sql: Criar o script responsável por ler os dados da origem, transformá-los adequadamente (JOINs, agregações) e carregá-los no schema do Data Warehouse.

## Como a Infraestrutura Funciona

Para garantir que todos os alunos tenham exatamente o mesmo ambiente sem precisar instalar bancos de dados complexos no próprio computador, utilizamos duas tecnologias juntas:

* DevContainers (pasta .devcontainer): É uma tecnologia que permite usar um container Docker como um ambiente de desenvolvimento completo. O arquivo devcontainer.json diz ao VS Code quais extensões instalar (como ferramentas de SQL) e como configurar o editor de forma automática para você.
* Docker Compose (docker-compose.yml): É o maestro da nossa infraestrutura. Ele levanta dois "computadores virtuais" (containers) simultaneamente:
  1. O ambiente do VS Code onde você vai programar.
  2. Um servidor PostgreSQL 15 rodando nos bastidores, pronto para receber suas queries.

## Passo a Passo: Como Iniciar e Usar o Ambiente

Siga as instruções abaixo para iniciar sua máquina virtual na nuvem gratuitamente usando o GitHub Codespaces.

### Passo 1: Iniciando o Codespace
1. Na página principal deste repositório no GitHub, clique no botão verde escrito "<> Code".
2. Selecione a aba "Codespaces".
3. Clique em "Create codespace on main" (ou no símbolo de +).
4. Uma nova aba será aberta no seu navegador carregando o VS Code. Aguarde alguns minutos até que o processo de "Building container" termine. Quando os arquivos aparecerem na lateral esquerda, você está pronto.

### Passo 2: Acessando o Banco de Dados
O banco de dados PostgreSQL já estará rodando automaticamente. Para acessá-lo e rodar seus scripts, usaremos a extensão SQLTools (que já foi instalada automaticamente pelo DevContainer):
1. No menu lateral esquerdo do VS Code, clique no ícone do SQLTools (parece um cilindro de banco de dados).
2. Clique em "Add New Connection" e escolha "PostgreSQL".
3. Preencha com os seguintes dados de acesso (conforme configurado na nossa infra):
   * Connection Name: Postgres Local (ou o nome que preferir)
   * Server Address: db
   * Port: 5432
   * Database: datawarehouse
   * Username: postgres
   * Password: password123
4. Clique em "Save Connection" e depois em "Connect Now".

### Passo 3: Desenvolvendo e Executando seus Scripts
1. Abra os arquivos dentro da pasta db-scripts/ e comece a escrever seu código SQL.
2. Para executar o código que você escreveu, selecione o texto, clique com o botão direito e escolha "Run Selected Query" (ou use o botão "Run on active connection" no topo do arquivo).
3. Desenvolva na ordem: primeiro a origem (source), depois o destino (dw) e, por fim, o etl.

## IMPORTANTE: Como Pausar o Ambiente

O GitHub Codespaces oferece uma cota gratuita de horas por mês. Para não consumir sua cota quando não estiver estudando, é fundamental desligar a máquina virtual ao terminar.

Não basta apenas fechar a aba do navegador! Faça o seguinte:
1. No VS Code (no navegador), olhe para o canto inferior esquerdo. Haverá um botão azul/verde escrito ">< Codespaces".
2. Clique nele.
3. No menu que aparecer no topo da tela, selecione "Stop Current Codespace".
4. A máquina será desligada e seu progresso ficará salvo para a próxima vez que você iniciar.
