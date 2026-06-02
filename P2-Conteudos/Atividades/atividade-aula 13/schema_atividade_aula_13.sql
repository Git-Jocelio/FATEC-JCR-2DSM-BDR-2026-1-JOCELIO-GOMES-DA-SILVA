/*atividade 13

Exercício 1 – Criar uma VIEW que liste:
titulo do livro
número de páginas
*/



create view view_livros as
select titulo, num_paginas from livro

select * from view_livros

/*
Exercício 2 - Criar uma VIEW com:
 autores que possuem mais de 1 livro (Dica: usar HAVING)
*/

select * from autor
select * from livro

create view view_livros_por_autor as
SELECT 
    id_autor,
    COUNT(id_livro) AS total_livros
FROM 
    livro
GROUP BY 
    id_autor
having COUNT(id_livro) > 1	
	
/*
Exercício 3 - Criar uma VIEW com:
 livros acima da média de páginas
*/	
CREATE OR REPLACE VIEW view_livros_acima_da_media AS
SELECT 
    id_livro,
    titulo,
    id_autor,
    num_paginas
FROM 
    livro
WHERE 
    num_paginas > (SELECT AVG(num_paginas) FROM livro);


/*
Exercício 4 - Criar uma VIEW que mostre:
 autor
 􀆡titulo do livro
 ano de publicação
*/	

create view view_autor_livros_ano_publicacao as
select a.nome, l.titulo, l.ano_publicacao 
from livro l, autor a


/*
Exercício 5 - Criar uma VIEW com:
 autor
 total de livros
 maior número de páginas
*/

CREATE VIEW view_estatisticas_autor AS
SELECT 
    a.nome AS autor,
    COUNT(l.id_livro) AS total_de_livros,
    MAX(l.num_paginas) AS maior_numero_de_paginas
FROM 
    autor a
LEFT JOIN 
    livro l ON a.id_autor = l.id_autor
GROUP BY 
    a.id_autor, 
    a.nome;


	