ALTER TABLE livro
ADD COLUMN num_paginas INT;

/*atividade aula 11*/
/* exercicio 1A*/
SELECT 
    a.nome,
    (
        SELECT COUNT(*)
        FROM livro l
        WHERE l.id_autor = a.id_autor
    ) AS total_livros,

    (
        SELECT ROUND(AVG(l.num_paginas), 2)
        FROM livro l
        WHERE l.id_autor = a.id_autor
    ) AS media_paginas

FROM autor a;




/*exercio 1B*/
WITH dados_autor AS (

    SELECT
        a.id_autor,
        a.nome,
        COUNT(l.id_livro) AS total_livros,
        ROUND(AVG(l.num_paginas), 2) AS media_paginas

    FROM autor a
    LEFT JOIN livro l
        ON a.id_autor = l.id_autor

    GROUP BY a.id_autor, a.nome
)

SELECT *
FROM dados_autor;



/*exercio 2A*/

WITH paginas_por_autor AS (
    SELECT
        a.id_autor,
        a.nome,
        SUM(l.num_paginas) AS total_paginas

    FROM autor a
    JOIN livro l
        ON a.id_autor = l.id_autor

    GROUP BY a.id_autor, a.nome
)
SELECT
    nome,
    total_paginas
FROM paginas_por_autor
WHERE total_paginas > (
    SELECT AVG(total_paginas)
    FROM paginas_por_autor
);




/*EXECICIO 3A*/
SELECT
    a.nome,

    (
        SELECT SUM(l.num_paginas)
        FROM livro l
        WHERE l.id_autor = a.id_autor
    ) AS total_paginas

FROM autor a;


/*EXERCICIO 3B*/

WITH total_por_autor AS (
    SELECT
        id_autor,
        SUM(num_paginas) AS total_paginas
    FROM livro
    GROUP BY id_autor
)
SELECT
    a.nome,
    t.total_paginas
FROM autor a
LEFT JOIN total_por_autor t
    ON a.id_autor = t.id_autor;

