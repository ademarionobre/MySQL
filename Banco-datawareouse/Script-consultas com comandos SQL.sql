-- Execução de comandos para análise e exploração
-- Atenção: Evitar o uso do *, ser específico, adicionar apenas as colunas que irá precisar para análise. Evitando assim sobrecarga e demoras.
-- O uso de -- ou /* */ para aplicar comentários.
use datawarehouse
/* Aplicando comandos */
-- -------
-- SELECT para selecionar colunas das tabelas a serem consultadas

SELECT CodigoCliente, CodigoStatus
FROM fato_vendas
LIMIT 10;

-- Usando WHERE para filtrar a consulta
SELECT CodigoCliente, CodigoStatus
FROM fato_vendas
WHERE CodigoCliente = 5;

-- DISTINCT -- Seleciona distintamente as colunas, informação única registrada
SELECT DISTINCT CodigoCliente,CodigoStatus
FROM fato_vendas
WHERE CodigoCliente = 5;

-- LIMIT OU TOP -- Traz os primeiros registros da consulta
SELECT CodigoCliente,CodigoStatus
FROM fato_vendas
LIMIT 10;

-- AND | OR | NOT
-- AND
SELECT CodigoCliente, CodigoStatus, CodigoProduto
FROM fato_vendas
WHERE CodigoProduto = 2
AND CodigoCliente <6;

-- OR
SELECT CodigoCliente, CodigoProduto
FROM fato_vendas
WHERE (CodigoProduto = 2 OR CodigoProduto = 3);

-- NOT (negar a consulta)
SELECT CodigoCliente, CodigoProduto
FROM fato_vendas
WHERE NOT(CodigoProduto = 2);

-- FUNÇÕES DE AGREGAÇÃO (SUM, AVG, MAX, COUNT, ROUND)

-- Somatório de quantidade de produtos vendidos
SELECT SUM(Quantidade) AS quantidade_venda # AS usado para apelidar a coluna
FROM fato_vendas;

-- Média da quantidade de produtos vendidos. Usando round para arredondar as casas decimais
SELECT AVG(Quantidade) AS media_quantidade_venda, ROUND(AVG(Quantidade),2) AS media_quantidade_venda_arredondado
FROM fato_vendas;

-- Maior e Menor quantidade de produtos vendidos
SELECT MAX(Quantidade) AS maior_quantidade_venda
FROM fato_vendas;

SELECT MIN(Quantidade) AS menor_quantidade_venda
FROM fato_vendas;

SELECT MAX(Quantidade) AS maior_quantidade_venda, MIN(Quantidade) AS menor_quantidade_venda
FROM fato_vendas;

-- Contagem de produtos
SELECT *
FROM dim_produto;

SELECT COUNT(CodigoProduto) AS qtd_produtos
FROM dim_produto;

-- Visualiaçao de consultas únicas com UNION
SELECT SUM(Quantidade) AS qtd, 'Quantidade de Venda - somatório' AS desrição FROM fato_vendas
UNION
SELECT ROUND(AVG(Quantidade),2) AS qtd, 'Quantidade de Venda - média' AS desrição FROM fato_vendas
UNION
SELECT MAX(Quantidade) AS qtd, 'Quantidade de Venda - máxima' AS desrição FROM fato_vendas
UNION
SELECT MIN(Quantidade) AS qtd, 'Quantidade de Venda - miníma' AS desrição FROM fato_vendas
UNION
SELECT COUNT(Quantidade) AS qtd, 'Quantidade de Produtos - contagem' AS desrição FROM fato_vendas;
-- *******
-- GROUP BY - Agrupa dados por algum parametro. O parametro deve estar no select e no group by.
-- ORDER BY - Ordena a consulta pela coluna sendo crescente ASC ou decrescente DESC
-- Quantos clientes por Estado?
SELECT COUNT(Estado)
FROM dim_cliente
GROUP BY Estado;
-- Fazendo a consulta corretamente com duas colunas e agrupados por Estado
SELECT Estado, COUNT(*) AS qtd_clientes
FROM dim_cliente
GROUP BY Estado
ORDER BY Estado;

SELECT *
FROM fato_vendas
ORDER BY Quantidade DESC;

-- HAVING - Condições em agrupamento de dados.  cláusula HAVING foi adicionada ao SQL porque a palavra-chave WHERE não pode ser usada com funções agregadas
SELECT Estado, COUNT(*)
FROM dim_cliente
GROUP BY Estado
HAVING count(*) >1;
/* Necessidade: Seu cliente precisa de uma relação de quantidade de clientes por Estado, caso o estado tenha mais de um cliente.
   Lendo o comando: Mostra o Estado e a quantidade de clientes naquele Estado, agrupando por Estado, se a contagem de cliente for maior que 1.*/
   
-- IN | BETWEEN
SELECT DISTINCT 
	CodigoCliente,
    CodigoProduto
FROM fato_vendas
WHERE CodigoProduto IN (2, 4)
AND CodigoCliente BETWEEN 1 AND 9;

-- LIKE - Condição para filtra consulta de texto ou parte de caracteres. Contem algo, voltado para texto.
SELECT DISTINCT 
	v.CodigoCliente,
    v.CodigoProduto,
    p.NomeProduto
FROM fato_vendas v
JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto
WHERE p.NomeProduto LIKE '% CH'; -- Palvras terminada com espaço CH

-- NULL
SELECT DISTINCT
       v.CodigoCliente, 
       v.CodigoProduto,
       p.NomeProduto
FROM fato_vendas v
RIGHT JOIN dim_produto p on p.CodigoProduto = v.CodigoProduto
WHERE p.NomeProduto IS NULL;
-- WHERE p.NomeProduto IS NOT NULL;

/* Lendo o comando: Seleciona distintamente as colunas: CodigoCliente e CodigoProduto da tabela: fato_vendas, 
   apenas os registros onde o NomeProduto SEJA Nulo.
   Se quisermos só os que não seja nulo, basta negar a condição: WHERE p.NomeProduto IS NOT NULL*/

-- *******************************************************************
-- TRIM | REPLACE | LPAD | REPLICATE | SUBSTRING | UPPER | LOWER | LEN
-- Comandos relacionados a tratamento de colunas texto, em um único SELECT.
-- TRIM — remove espaços
-- REPLACE — substitui algo por algo
-- LPAD e REPLICATE — Replica valores
-- SUBSTRING — pega trecho de um texto
-- UPPER — deixa tudo maiúsculo
-- LOWER — deixa tudo minúsculo
-- LEN — calcula a quantidade de caracteres

SELECT p.codigoProduto, -- Informação original
       p.NomeProduto, -- Informação original                 
       TRIM(p.NomeProduto)               AS TRIM, -- removendo espaços da coluna NomeProduto
       REPLACE(p.NomeProduto, 'A', 'AA') AS "REPLACE", -- Substiui onde tiver A por AA no Tipo de Produto
       LPAD(p.CodigoProduto, 9, "0")     AS LPAD,  -- Adiciona zeros a esquerda no código do produto até completar 9 dígitos
       SUBSTRING(p.NomeProduto, 1, 3)    AS SUBSTRING, -- Pega os primeiros 3 caracteres da coluna de Nome do Produto 
       UPPER(p.NomeProduto)              AS UPPER, -- Nome de Produto em maiúsculo
       LOWER(p.NomeProduto)              AS LOWER, -- Nome de Produto em minúsculo
       LENGTH(p.NomeProduto)             AS LENGTH -- Quantos caracteres tem o campo NomeProduto
FROM dim_produto AS p;

-- ******************
-- CAST | CONVERT — Convertem um tipo de dados em outro

SELECT c.CodigoCliente,
	CONCAT('Código - ', CAST(c.CodigoCliente as CHAR)) AS CodigoCliente_Texto
FROM dim_cliente c; -- Não usei o AS, aqui é implicito
  
/* Lendo o comando: 
   Neste caso, o cliente precisava adicionar a palavra "Código - ", antes do código do Cliente.
   Concatenamos (Comando CONCAT) a palavra solicitada com o código do cliente, para concatenarmos,
   colocamos o código como texto usando o CAST (comando para converter tipos de dados)
*/

-- ******************
-- DATE - Operações envolvendo datas
-- ******************
SELECT DataVenda							AS Data
     , DAY(DataVenda)                     	AS Dia
     , MONTH(DataVenda)                   	AS Mes
     , YEAR(DataVenda)                    	AS Ano
     , HOUR(DataVenda)                    	AS Hora
     , MINUTE(DataVenda)                  	AS Minuto
     , DATE_FORMAT(DataVenda, '%Y%m%d')   	AS AnoMesDia
     , DATE_FORMAT(DataVenda, '%b %Y')    	AS Mes_Ano
     , DataVenda - INTERVAL '3' HOUR      	AS "Data-3hs"
     , DataVenda - INTERVAL '3' DAY       	AS "Data-3days"
     , LOCALTIMESTAMP()                   	AS hora_atual
     , LOCALTIMESTAMP - INTERVAL '3' HOUR 	AS "DataAtual-3hs"
  FROM fato_vendas v;
/* Lendo o comando: 
   Ocorre variações a depender da engine do BD que trabalha.
   Importante ser o mais especifíco em relação as colunas que vai utilizar.
*/
-- ****************
-- JOIN — Relacionamento entre tabelas — Operação que permite buscar informações de duas ou mais tabelas que estão relacionadas.
-- INNER JOIN -- 
-- O Inner Join é o método de junção mais conhecido e retorna os registros que são comuns às duas tabelas. Exemplo:
SELECT * FROM fato_vendas;
SELECT * FROM dim_produto;
-- A coluna CodigoProduto é comum nas duas tabelas.
-- Relacionando a tabela de vendas com a de produtos por meio do CodigoProduto
SELECT * -- Exemplo trazendo todas as colunas para verificar que a CodigoProduto contém nas duas.
  FROM       fato_vendas v
  INNER JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto;

SELECT CodigoCliente, p.CodigoProduto, NomeProduto
  FROM       fato_vendas v
  INNER JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto;
-- -------------
-- LEFT JOIN --
-- -------------
-- O Left Join tem como resultado todos os registros que estão na tabela A (mesmo que não estejam na tabela B) 
-- e os registros da tabela B que são comuns à tabela A. Quando não tem traz o valor NULL.
SELECT *
  FROM      fato_vendas v
  LEFT JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto;

-- -------------
-- RIGHT JOIN --
-- -------------
-- Teremos como resultado todos os registros que estão na tabela B (mesmo que não estejam na tabela A) 
-- e os registros da tabela A que são comuns à tabela B.

SELECT * FROM fato_vendas;
SELECT * FROM dim_produto;

SELECT *
  FROM       fato_vendas v
  RIGHT JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto;

-- -------------
-- OUTER JOIN --
-- -------------
-- O Outer Join (também conhecido por FULL OUTER JOIN ou FULL JOIN) tem como resultado todos os registros que estão na tabela A e todos os registros da tabela B.
-- No MySQL não tem nativamente, necessário usar o UNION para unir a consulta LEFT e RIGHT.
SELECT *
  FROM            fato_vendas v
  LEFT OUTER JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto
UNION
SELECT *
  FROM            fato_vendas v
 RIGHT OUTER JOIN dim_produto p ON p.CodigoProduto = v.CodigoProduto;

/* Lendo o comando: Neste caso, precisamos relacionar 2 tabelas e mostramos algumas formas de relacionar */
-- ***********
-- VIEW — Em SQL, uma view é uma tabela virtual baseada no conjunto de resultados de uma instrução SQL.
-- Necessidade: Um determinado usuário precisa da data de venda, nome do cliente e o nome do produto vendido

CREATE OR REPLACE VIEW vwvendas_resumida AS -- Pode usar o Create view, se usar OR REPLACE VIEW já sobrescreve uma view anterior.
SELECT v.DataVenda   AS Data
     , c.NomeCliente AS Cliente
     , p.NomeProduto AS Produto
  FROM fato_vendas v
  JOIN dim_cliente c on c.CodigoCliente = v.CodigoCliente
  JOIN dim_produto p on p.CodigoProduto = v.CodigoProduto;

-- Consultando a View (basta passarmos essa View ao usuário ou exportar em csv)
SELECT * FROM vwvendas_resumida;

/* Lendo o comando: 
   Neste caso, precisamos relacionar 3 tabelas para realizar o solicitado pelo cliente.
   Relacionamos a tabela das vendas com a de clientes para pegarmos o nome do cliente e
   relacionamos a tabela das vendas com a de produtos para pegarmos o nome do produto
*/
-- ***********
-- CASE — Controle de Fluxo (uso de condições na consulta)
/* Lendo o comando: 
   Selecione o Codigo e o nome do Produto, e informe se o produto tá disponível para venda ou não tem estoque suficiente.
   A condição para a venda disponível é ter pelo menos um Saldo de 10 unidades e que o produto esteja ativo.
*/
SELECT * FROM dim_produto;
-- --
SELECT CodigoProduto,
       NomeProduto,
	   CASE WHEN SaldoProduto > 10 AND StatusProduto = 'Ativo' THEN 'Disponível para Venda'
       ELSE 'Estoque insuficiente' END  StatusVenda
FROM dim_Produto;

-- ***********
-- WITH — CTE
/* Uma expressão de tabela comum (CTE) é um conjunto de resultados temporário nomeado que existe no escopo de uma única instrução
 e que pode ser consultado posteriormente nessa instrução, possivelmente várias vezes.*/
 -- Organização, performance
-- ************************
 -- Evite...
 SELECT * 
   FROM fato_vendas v
   JOIN (SELECT CodigoCliente
           FROM dim_cliente 
	   	  WHERE Estado = 'Ceará') c ON c.codigocliente = v.codigocliente;

-- Recomendado...
WITH cliente AS (
	SELECT CodigoCliente
      FROM dim_cliente WHERE Estado = 'Ceará'
) 
 SELECT * 
   FROM fato_vendas v
   JOIN cliente c ON c.codigocliente = v.codigocliente;
 
 -- ***********
-- Window Function
/* Em SQL, uma função de janela ou função analítica é uma função que usa valores de uma ou várias linhas para retornar um valor para cada linha.
 As funções de janela têm uma cláusula OVER; qualquer função sem uma cláusula OVER não é uma função de janela, mas sim uma função agregada ou de linha única.*/

-- Quantidade de produto total por cliente - detalhar por ano - queremos saber também a quantidade total de vendas (relatório detalhado)
SELECT codigocliente   AS codidocliente,
       YEAR(DataVenda) AS ano, 
       codigoProduto   AS codigoproduto,
       quantidade      AS qtpro,
       SUM(quantidade) OVER(PARTITION BY codigocliente) AS quantidade_por_cliente,
       SUM(quantidade) OVER(PARTITION BY codigocliente, YEAR(DataVenda)) AS quantidade_por_cliente_ano,
       SUM(quantidade) OVER() AS quantidade_total
  FROM fato_vendas
 ORDER BY codigocliente, YEAR(DataVenda), quantidade;