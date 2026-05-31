/*atividade aula 12*/

DROP TABLE IF EXISTS carro, pessoa;

CREATE TABLE IF NOT EXISTS pessoa (
 id_pessoa INTEGER PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 nascimento DATE
);

CREATE TABLE IF NOT EXISTS carro (
 id_carro INTEGER PRIMARY KEY,
 placa CHAR(7) NOT NULL,
 ano INTEGER,
 id_pessoa INTEGER NOT NULL,
 FOREIGN KEY (id_pessoa)
 REFERENCES pessoa(id_pessoa)
 ON DELETE CASCADE
);


COPY pessoa (id_pessoa, nome,
nascimento)
FROM 'C:\aula3_pessoa.csv'
DELIMITER ','
CSV HEADER;


COPY carro (id_carro, placa, ano,
id_pessoa)
FROM 'C:\aula3_carro.csv'
DELIMITER ','
CSV HEADER;


select * from carro

/*Comando para listar os índices de uma tabela:*/
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'pessoa';

/*
 Compreender, por meio de medições, a diferença entre varredura sequencial (Seq
Scan) e acesso por índice (Index Scan), utilizando a coluna nome da tabela pessoa.
*/

EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nome = 'Ana Silva';

EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nome = 'João Santos';


/* Crie um índice B-tree na coluna nome: */
CREATE INDEX idx_pessoa_nome
ON pessoa (nome);

/*Execute novamente as duas consultas da Parte A */

EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nome = 'Ana Silva';

EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nome = 'João Santos';

/*
Parte D – Responda, de forma objetiva:
• Qual plano foi utilizado antes do índice?

resposta : foi utilizado o indice padrão B-Tree

• Qual plano foi utilizado após o índice?
resposta : foi criado um indice pelo campo nome facilitando a busca por um campo indexado


• Houve redução no tempo de execução?
• O índice foi utilizado em ambos os nomes testados? Justifique com base na saída do
plano.
resposta : houve redução significativa na busca


•
Por que o otimizador pode optar por não utilizar um índice, mesmo quando ele existe?
resposta : de acordo com os resultado do EXPLAIN ANALYZE ele decide qual melhor
caminho tomar

*/

DROP INDEX IF EXISTS idx_pessoa_nome;


/*Exercício 3 – Índice Composto e Ordem das Colunas*/

/*Exercício 3 - PARTE A*/

DROP INDEX IF EXISTS idx_pessoa_nascimento;

EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nascimento >= DATE '2000-01-01'
AND nome = 'Ana Silva';


/*Exercício 3 - PARTE B*/

CREATE INDEX idx_pessoa_nascimento_nome
ON pessoa (nascimento, nome);

/*Exercício 3 - PARTE C*/
EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nome = 'Ana Silva';

/*Exercício 3 - PARTE D*/
EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nome = 'Ana Silva';

/*Exercício 3 - PARTE E*/
Qual plano foi utilizado antes da criação do índice composto?
Resposta: Seq Scan (Varredura Sequencial).

Qual plano foi utilizado após a criação do índice composto?
Resposta: Index Scan (ou Bitmap Index Scan) utilizando o índice idx_pessoa_nascimento_nome

O índice composto foi utilizado na consulta que filtra apenas por nome?
Resposta: Não. O Postgres provavelmente voltou a usar um Seq Scan para essa consulta.

Por que a ordem das colunas no índice composto é relevante?
RESPOSTA: ser usar na oredem correta fica muito rapido

/*exercício 4 parte A */
DROP INDEX IF EXISTS idx_pessoa_nascimento_nome;

CREATE INDEX idx_pessoa_nascimento
ON pessoa (nascimento);

CREATE INDEX idx_pessoa_nome
ON pessoa (nome);

/*exercício 4 parte B  */
EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nascimento >= DATE '2000-01-01'
AND nome = 'Ana Silva';

/*plano de execução
"Bitmap Heap Scan on pessoa  (cost=4.34..26.75 rows=1 width=23) (actual time=10.641..10.644 rows=2.00 loops=1)"
"  Recheck Cond: ((nome)::text = 'Ana Silva'::text)"
"  Filter: (nascimento >= '2000-01-01'::date)"
"  Rows Removed by Filter: 3"
"  Heap Blocks: exact=5"
"  Buffers: shared hit=5 read=2"
"  ->  Bitmap Index Scan on idx_pessoa_nome  (cost=0.00..4.34 rows=6 width=0) (actual time=10.607..10.607 rows=5.00 loops=1)"
"        Index Cond: ((nome)::text = 'Ana Silva'::text)"
"        Index Searches: 1"
"        Buffers: shared read=2"
"Planning:"
"  Buffers: shared hit=32 read=2"
"Planning Time: 7.607 ms"
"Execution Time: 14.779 ms"

*/

/*exercício 4 parte C  */

O PostgreSQL utilizou os dois índices simples na consulta?
Resposta: Não, ele utilizou apenas um deles: o idx_pessoa_nome.

Qual é o papel do operador BitmapAnd no plano de execução?
Resposta: O papel dele seria combinar (fazer uma interseção) entre os resultados de dois índices diferentes.

O que o plano efetivamente fez?
Em vez de ler a tabela linha por linha (Seq Scan) ou ficar pulando na tabela a cada linha encontrada (Index Scan tradicional), o Postgres usou uma estratégia em duas etapas (Bitmap Scan):

/*EXERCÍCIO 5 */
EXPLAIN ANALYZE
SELECT *
FROM carro
WHERE ano BETWEEN 2015 AND 2020;

CREATE INDEX idx_carro_ano ON carro (ano);

Antes da Criação do Índice : 
Seq Scan on carro (Varredura Sequencial)
Depois da criação do indice
O plano mudou para um Index Scan using idx_carro_ano on carro (ou Bitmap Index Scan


/*Exercicio 6 */
drop index idx_carro_ano 

EXPLAIN ANALYZE
SELECT p.nome, c.placa
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nome = 'Ana Silva';

"Hash Join  (cost=1938.08..3837.59 rows=6 width=23) (actual time=13.543..25.616 rows=7.00 loops=1)"
"  Hash Cond: (c.id_pessoa = p.id_pessoa)"
"  Buffers: shared hit=1325"
"  ->  Seq Scan on carro c  (cost=0.00..1637.00 rows=100000 width=12) (actual time=0.022..5.071 rows=100000.00 loops=1)"
"        Buffers: shared hit=637"
"  ->  Hash  (cost=1938.00..1938.00 rows=6 width=19) (actual time=11.908..11.910 rows=5.00 loops=1)"
"        Buckets: 1024  Batches: 1  Memory Usage: 9kB"
"        Buffers: shared hit=688"
"        ->  Seq Scan on pessoa p  (cost=0.00..1938.00 rows=6 width=19) (actual time=5.314..11.885 rows=5.00 loops=1)"
"              Filter: ((nome)::text = 'Ana Silva'::text)"
"              Rows Removed by Filter: 99995"
"              Buffers: shared hit=688"
"Planning:"
"  Buffers: shared hit=15"
"Planning Time: 1.537 ms"
"Execution Time: 25.656 ms"
-- 1. Índice para encontrar a pessoa rapidamente pelo nome (Cláusula WHERE)
CREATE INDEX idx_pessoa_nome ON pessoa (nome);

-- 2. Índice na FK da tabela carro para acelerar o cruzamento dos dados (Cláusula JOIN)
CREATE INDEX idx_carro_id_pessoa ON carro (id_pessoa);

Execute novamente a consulta e analise as alterações no plano de execução
EXPLAIN ANALYZE
SELECT p.nome, c.placa
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nome = 'Ana Silva';

RESPOSTA : Os novos índices eliminaram completamente os gargalos de processamento.
A query deixou de fazer buscas lineares pesadas e passou a fazer buscas indexadas e cirúrgicas. O banco reduziu o consumo de memória/disco a quase zero e o tempo de resposta caiu para menos de 1 milissegundo.

/* EXERCICIO 7 */
EXPLAIN ANALYZE
SELECT p.nome, c.placa, c.ano
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nascimento >= DATE '1980-01-01'
AND c.ano >= 2018;


/*EXERCIO 8*/
EXPLAIN ANALYZE
SELECT *
FROM pessoa
WHERE nascimento BETWEEN DATE '1980-01-01' AND DATE '1990-12-31';