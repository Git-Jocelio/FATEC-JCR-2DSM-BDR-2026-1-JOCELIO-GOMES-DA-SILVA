/*atividade 16 
exercicio 1 A
A coordenação deseja impedir que livros sejam removidos do sistema caso ainda existam
exemplares disponíveis.
Desenvolva:
a)
Uma FUNCTION chamada:
bloquear_exclusao()
que:
impeça DELETE quando:
quantidade > 0
• utilize:
RAISE EXCEPTION
para exibir mensagem apropriada. 
*/

CREATE OR REPLACE FUNCTION bloquear_exclusao()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Regra de Negócio: Impedir DELETE quando a quantidade for maior que zero
    IF OLD.quantidade > 0 THEN
        -- Exibir erro com mensagem apropriada
        RAISE EXCEPTION 'Ação bloqueada: O livro "%" ainda possui % exemplar(es) em estoque e não pode ser removido.', 
            OLD.titulo, OLD.quantidade;
    END IF;

    -- Se a quantidade for 0, permite a exclusão retornando a linha (OLD)
    RETURN OLD;
END;
$$;


/*exercicio 1 B
Uma TRIGGER chamada:
trg_bloquear_exclusao
executada BEFORE DELETE na tabela:
livro
*/
CREATE TRIGGER trg_bloquear_exclusao
BEFORE DELETE ON livro
FOR EACH ROW
EXECUTE FUNCTION bloquear_exclusao();

/*EXERCIO 2*/

CREATE TABLE historico_exclusao_livro (
    id_log SERIAL PRIMARY KEY,
    titulo_livro VARCHAR(255),
    data_hora_exclusao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensagem_informativa TEXT
);

CREATE OR REPLACE FUNCTION log_exclusao_livro()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Inserindo os dados do livro excluído na tabela de histórico
    INSERT INTO historico_exclusao_livro (titulo_livro, data_hora_exclusao, mensagem_informativa)
    VALUES (
        OLD.titulo, 
        NOW(), -- Captura a data e hora exata do sistema no momento da execução
        CONCAT('O livro "', OLD.titulo, '" (ID: ', OLD.id_livro, ') foi removido com sucesso do sistema.')
    );

    -- Mensagem informativa no console/log do servidor de banco de dados
    RAISE NOTICE 'Log de exclusão registrado para o livro: %', OLD.titulo;

    -- Em triggers AFTER DELETE, o retorno ideal é o próprio registro OLD
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_log_exclusao
AFTER DELETE ON livro
FOR EACH ROW
EXECUTE FUNCTION log_exclusao_livro();


/*EXERCICIO 3*/

CREATE OR REPLACE FUNCTION validar_limite_estoque()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Regra de Negócio: Impedir UPDATE quando a NOVA quantidade for maior que 100
    IF NEW.quantidade > 100 THEN
        -- Apresentar mensagem de erro usando RAISE EXCEPTION
        RAISE EXCEPTION 'Operação cancelada: A quantidade informada (%) excede o limite máximo permitido de 100 exemplares por livro.', 
            NEW.quantidade;
    END IF;

    -- Se a quantidade for menor ou igual a 100, a alteração é permitida
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_limite
BEFORE UPDATE ON livro
FOR EACH ROW
EXECUTE FUNCTION validar_limite_estoque();


/* EXERCICIO 4 */
/*
=============================================================================
             DOCUMENTAÇÃO TÉCNICA: ANÁLISE DE TRIGGERS (BEFORE vs AFTER)
=============================================================================

EXERCÍCIO 4 - ANÁLISE E FLUXO DE EXECUÇÃO NO BANCO DE DADOS

-----------------------------------------------------------------------------
a) A diferença fundamental entre Triggers BEFORE e AFTER
-----------------------------------------------------------------------------
A divergência reside no momento da execução e no controle dos dados:

* BEFORE (Antes):
  - Disparada ANTES que os dados sejam validados pelas constraints ou gravados 
    permanentemente na tabela.
  - O banco intercepta a intenção do comando (INSERT, UPDATE ou DELETE).
  - Poder Especial: Permite ler e ALTERAR os valores do registro 'NEW' (novos 
    dados) diretamente na memória antes de entrarem no disco.

* AFTER (Depois):
  - Disparada APÓS a operação principal ter sido concluída com sucesso e os dados 
    já estarem consolidados na tabela.
  - Limitação: Não pode de forma alguma modificar os registros 'NEW' ou 'OLD', 
    pois o ciclo de escrita da tabela já foi encerrado.

-----------------------------------------------------------------------------
b) Tipo de Trigger indicado para VALIDAÇÃO: BEFORE
-----------------------------------------------------------------------------
Para validações de regras de negócio, o uso da trigger BEFORE é obrigatório.

* Arquitetura Fail-Fast (Falha Rápida):
  Se um operador tentar inserir uma quantidade inválida (ex: maior que 100), 
  a trigger BEFORE cancela a operação imediatamente via RAISE EXCEPTION. 
  Como o dado ruim foi barrado antes da escrita, o banco de dados economiza 
  processamento e I/O, eliminando a necessidade de gerar um Rollback complexo.

-----------------------------------------------------------------------------
c) Tipo de Trigger indicado para AUDITORIA e LOGS: AFTER
-----------------------------------------------------------------------------
Para rotinas de auditoria, histórico e logs, o uso da trigger AFTER é o correto.

* Princípio do Fato Consumado:
  Um log só deve existir se o evento realmente se concretizou no mundo real. 
  Se o log fosse gerado no BEFORE, e logo em seguida o banco rejeitasse a 
  operação devido a uma violação de chave estrangeira (FK), o histórico de 
  auditoria conteria um "falso positivo" (mentindo que a alteração ocorreu). 
  O AFTER garante a fidelidade do log.

-----------------------------------------------------------------------------
d) A importância da Ordem de Execução em Bancos Corporativos Reais
-----------------------------------------------------------------------------
O fluxo oficial de uma transação segue rigidamente a linha do tempo:
[ Comando SQL ] -> [ Triggers BEFORE ] -> [ Constraints/FKs ] -> [ Triggers AFTER ]

Essa ordem é vital por três fatores críticos:

1. Integridade Absoluta: Dados corrompidos ou falsos são filtrados na primeira 
   linha de defesa (BEFORE), impedindo que cheguem perto da estrutura da tabela.
   
2. Otimização de I/O (Disco): Gravar em disco é a operação mais lenta de um 
   servidor. Validar no BEFORE evita o desperdício de escrever um dado inválido 
   para ter que desfazê-lo na sequência.
   
3. Compliance e Segurança (LGPD / Auditoria Fiscal): Garante que a tabela de 
   rastreabilidade (logs) seja um espelho 100% confiável, imutável e livre de 
   erros processuais sobre as ações dos usuários.

=============================================================================
*/

/*EXERCICIO 5*/
/*
=============================================================================
         DOCUMENTAÇÃO TÉCNICA: INTEGRIDADE DE DADOS E AUTOMAÇÃO (TRIGGERS)
=============================================================================

EXERCÍCIO 5 - REFLEXÃO CRÍTICA: VALIDAÇÃO NA APLICAÇÃO VS NO BANCO DE DADOS

-----------------------------------------------------------------------------
a) Riscos ao remover as Triggers e validar APENAS na Aplicação
-----------------------------------------------------------------------------
Confiar exclusivamente no código do software (Java, Python, Node, etc.) para 
garantir a qualidade dos dados gera três riscos críticos:

1. Ignorância de Múltiplos Canais de Acesso (Múltiplas Portas):
   A aplicação é apenas uma das vias de entrada. Se um DBA, analista de suporte,
   ou um script externo rodar um comando direto via terminal (DBeaver, pgAdmin),
   o dado corrompido entrará no banco sem passar pelas travas da aplicação.

2. Bugs e Falhas de Código Humano:
   Se um desenvolvedor esquecer de chamar a função de validação ao criar uma nova 
   tela, ou introduzir um bug na lógica, dados inválidos serão persistidos.

3. Inconsistência entre Ecossistemas (Silos de Regras):
   Em cenários corporativos, vários sistemas leem o mesmo banco. Se a regra mudar 
   na aplicação "A" e a equipe da aplicação "B" esquecer de atualizar o código,
   as duas regras vão colidir, gerando caos e assimetria nos dados.

-----------------------------------------------------------------------------
b) Vantagens em manter as Regras DIRETAMENTE no Banco de Dados
-----------------------------------------------------------------------------
Deixar o banco de dados responsável por sua própria integridade traz:

* Centralização da Verdade:
  A regra reside em um único ponto focal. Não importa a origem do dado (web, 
  mobile, planilha ou comando manual), todos enfrentam a mesma barreira.

* Performance em Lote (Batch Processing):
  Para processar e validar milhares de linhas, o banco resolve tudo internamente 
  em milissegundos. Trazer esses dados para a aplicação validar geraria um 
  tráfego de rede destrutivo (overhead).

* Imutabilidade e Blindagem:
  O banco diminui a dependência do fator humano. Ele prefere estourar um erro 
  e abortar a operação (Fail-Fast) a aceitar