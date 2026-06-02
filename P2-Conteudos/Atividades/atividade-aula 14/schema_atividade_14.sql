/* 
aula 14 
Insira um livro somente se o autor existir
Regras:
Verificar se id_autor existe na tabela autor
Se não existir: mostrar erro com RAISE EXCEPTION
*/
CREATE OR REPLACE PROCEDURE inserir_livro_com_validacao(
    p_titulo VARCHAR,
    p_id_autor INT,
    p_ano_publicacao INT,
    p_num_paginas INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_autor_existe INT;
BEGIN
    -- Habilidade: SELECT dentro da procedure para verificar se o id_autor existe
    SELECT id_autor INTO v_autor_existe 
    FROM autor 
    WHERE id_autor = p_id_autor;

    -- Regra de Negócio: Verificar se o id_autor existe na tabela autor
    IF v_autor_existe IS NULL THEN
        -- Se não existir: mostrar erro com RAISE EXCEPTION
        RAISE EXCEPTION 'Erro de validação: O id_autor % não existe na tabela autor.', p_id_autor;
    END IF;

    -- Lógica: Insira o livro somente se o autor existir (passou pelo IF)
    INSERT INTO livro (titulo, id_autor, ano_publicacao, num_paginas)
    VALUES (p_titulo, p_id_autor, p_ano_publicacao, p_num_paginas);

    -- Mensagem de confirmação no console
    RAISE NOTICE 'Sucesso: Livro "%" inserido com êxito.', p_titulo;
END;
$$;


/*exercicio 02
Criar uma procedure que:
- Atualize o número de páginas de um livro - Mas só permita valores maiores que 10
Caso contrário:
Exibir erro
*/
CREATE OR REPLACE PROCEDURE atualizar_paginas_livro(
    p_id_livro INT,
    p_novo_num_paginas INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Regra de Negócio: Não permite valores menores ou iguais a 10
    IF p_novo_num_paginas <= 10 THEN
        -- Mostrar erro com RAISE EXCEPTION caso a condição seja violada
        RAISE EXCEPTION 'Operação negada: O número de páginas (%) deve ser estritamente maior que 10.', p_novo_num_paginas;
    END IF;

    -- 2. Habilidade: UPDATE dentro da procedure
    UPDATE livro
    SET num_paginas = p_novo_num_paginas
    WHERE id_livro = p_id_livro;

    -- 3. Verificação extra: O livro informado realmente existe?
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Erro: O livro com ID % não foi encontrado.', p_id_livro;
    END IF;

    -- Mensagem informativa de sucesso
    RAISE NOTICE 'Sucesso: O livro ID % foi atualizado para % páginas.', p_id_livro, p_novo_num_paginas;
END;
$$;

/*exercicio 3
Criar uma procedure que:
- Exclua um autor - Mas só permita se ele NÃO tiver livros cadastrados
*/

CREATE OR REPLACE PROCEDURE excluir_autor_sem_livros(
    p_id_autor INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Regra de Negócio: Verificar se o autor possui livros cadastrados
    PERFORM 1 
    FROM livro 
    WHERE id_autor = p_id_autor;

    -- 2. Condição: Se encontrar livros (FOUND), bloqueia a exclusão
    IF FOUND THEN
        RAISE EXCEPTION 'Operação negada: O autor ID % possui livros cadastrados e não pode ser excluído.', p_id_autor;
    END IF;

    -- 3. Habilidade: DELETE dentro da procedure (caso não tenha livros)
    DELETE FROM autor
    WHERE id_autor = p_id_autor;

    -- 4. Verificação extra: O autor informado realmente existia?
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Erro: O autor com ID % não foi encontrado.', p_id_autor;
    END IF;

    -- Mensagem informativa de sucesso
    RAISE NOTICE 'Sucesso: Autor ID % excluído corretamente.', p_id_autor;
END;
$$;

/*exercicio 4
Criar uma procedure que:
- Receba id_autor -Retorne (via SELECT dentro da procedure):
Nome do autor
Média de páginas dos livros
*/
CREATE OR REPLACE FUNCTION obter_media_paginas_autor(
    p_id_autor INT
)
RETURNS TABLE (
    nome_autor VARCHAR,
    media_paginas NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Habilidade: Retornar (via SELECT dentro da procedure/função)
    RETURN QUERY
    SELECT 
        a.nome,
        -- Cálculo: Média de páginas arredondada para 2 casas decimais
        ROUND(AVG(l.num_paginas), 2)
    FROM autor a
    INNER JOIN livro l ON a.id_autor = l.id_autor
    WHERE a.id_autor = p_id_autor
    GROUP BY a.nome;

    -- Regra de negócio extra: Se o autor não tiver livros ou não existir
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Aviso: Autor ID % não encontrado ou não possui livros cadastrados.', p_id_autor;
    END IF;
END;
$$;

/*exercio 5
Criar uma procedure que:
- Insira um livro - Aplique TODAS as validações:
páginas > 0
título não pode ser vazio
autor deve existir
*/

CREATE OR REPLACE PROCEDURE inserir_livro_completo(
    p_titulo VARCHAR,
    p_id_autor INT,
    p_ano_publicacao INT,
    p_num_paginas INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_autor_existe INT;
BEGIN
    -- Validação 1: O título não pode ser vazio ou nulo
    -- (TRIM remove espaços em branco extras para evitar títulos como "   ")
    IF p_titulo IS NULL OR TRIM(p_titulo) = '' THEN
        RAISE EXCEPTION 'Erro de Validação: O título do livro não pode ser vazio.';
    END IF;

    -- Validação 2: O número de páginas deve ser maior que 0
    IF p_num_paginas IS NULL OR p_num_paginas <= 0 THEN
        RAISE EXCEPTION 'Erro de Validação: O número de páginas (%) deve ser estritamente maior que zero.', p_num_paginas;
    END IF;

    -- Validação 3: O autor deve existir na tabela autor
    SELECT id_autor INTO v_autor_existe 
    FROM autor 
    WHERE id_autor = p_id_autor;

    IF v_autor_existe IS NULL THEN
        RAISE EXCEPTION 'Erro de Validação: O id_autor % não corresponde a nenhum autor cadastrado.', p_id_autor;
    END IF;


    -- INSERÇÃO: Se o código chegou até aqui, significa que passou por todas as barreiras!
    INSERT INTO livro (titulo, id_autor, ano_publicacao, num_paginas)
    VALUES (TRIM(p_titulo), p_id_autor, p_ano_publicacao, p_num_paginas);

    -- Mensagem clara de sucesso
    RAISE NOTICE 'Sucesso: O livro "%" foi validado e cadastrado com êxito!', p_titulo;

END;
$$;