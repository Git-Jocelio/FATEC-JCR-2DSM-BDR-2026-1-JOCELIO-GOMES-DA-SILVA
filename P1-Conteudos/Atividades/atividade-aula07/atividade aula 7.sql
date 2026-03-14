/* aula 7 */

select count(*) from usuariod

SELECT 
    id_TipoEvento,
    COUNT(*) AS quantidade_eventos
FROM evento
GROUP BY id_TipoEvento;


select * from tipoevento

/*COUNT(*)              → conta quantos registros existem
  GROUP BY idTipoEvento → agrupa os eventos por tipo*/

select 
    min(data_hora) AS data_minima,
    max(data_hora) AS data_maxima
from evento;

select avg(qtde) from localizacao,(
	select count(*) from localizacao as qtde
)

SELECT AVG(qtd) AS media_registros_por_cidade
FROM (
    SELECT cidade, COUNT(*) AS qtd
    FROM localizacao
    GROUP BY cidade
) AS subconsulta;

/* subSelect: dica da lucineide
	explicação conte todas as cidades da tabela localizacao
e agrupe por cidade e guarde o valor em qtde
select
	principal tire a media de qtd */
  