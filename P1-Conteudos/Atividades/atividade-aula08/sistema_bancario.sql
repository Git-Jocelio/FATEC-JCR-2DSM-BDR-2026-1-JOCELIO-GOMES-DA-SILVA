/*EXERCÍCIO 1
Crie o banco de dados sistema_bancario.
*/
create database sistema_bancario;

/*EXERCÍCIO 2
Tabela clientes
• Cada cliente tem um ID único (chave primária).
• O CPF é único e obrigatório.
Crie a tabela clientes como descrita a seguir:*/
CREATE TABLE clientes (
 id_cliente SERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 cpf VARCHAR(11) UNIQUE NOT NULL,
 endereco TEXT,
 telefone VARCHAR(15)
);

/*EXERCÍCIO 3
Inserir clientes na tabela. Veja alguns exemplos:*/
INSERT INTO clientes (nome, cpf, endereco, telefone) VALUES
('João Silva', '12345678900', 'Rua A, 123', '11999990000'),
('Maria Oliveira', '98765432100', 'Rua B, 456', '11988887777'),
('Jocelio Gomes', '10562976892', 'Rua João Osório, 246', '11959365875'),
('Lucineide Pimenta', '09847558895', 'Rua B, 456', '11988858752'),
('Arley Souza', '11511811792', 'Rua B, 456', '11988885555');


/*EXERCÍCIO 4
Tabela contas
• Cada conta tem um número único e pertence a um cliente.
• O saldo inicial deve ser zero por padrão.
Crie a tabela contas como descrita a seguir.*/
CREATE TABLE contas (
	id_conta SERIAL PRIMARY KEY,
    numero_conta VARCHAR(10) UNIQUE NOT NULL,
    saldo DECIMAL(10,2) DEFAULT 0,
    id_cliente INT REFERENCES clientes(id_cliente) ON DELETE CASCADE
);



/*EXERCÍCIO 5
Inserir as contas na tabela. Veja alguns exemplos: */
INSERT INTO contas (numero_conta, saldo, id_cliente) VALUES
('000123', 1500.25, 1),
('000456', 2300.10, 2),
('000777', 1.00, 3),
('000999', 5275.99, 4),
('001202', 12300.00, 5);


/*EXERCÍCIO 6
Tabela transacoes
• Cada transação tem um ID único e está ligada a uma conta bancária.
• O tipo pode ser saque, depósito ou transferência.
• O campo destino_transferencia é usado apenas para transferências.
Crie a tabela transacoes como descrita a seguir.*/

CREATE TABLE transacoes (
 id_transacao SERIAL PRIMARY KEY,
 id_conta INT REFERENCES contas(id_conta) ON DELETE CASCADE,
 tipo VARCHAR(15) CHECK (tipo IN ('Depósito', 'Saque', 'Transferência')),
 valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
 data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 destino_transferencia INT REFERENCES contas(id_conta)
);



/*EXERCÍCIO 7
Inserir as transações na tabela. Veja alguns exemplos: */

INSERT INTO transacoes (id_conta, tipo, valor, data_transacao, destino_transferencia) VALUES
(1, 'Depósito', 500.00,'2025-02-01', null),
(2, 'Saque', 200.00, '2025-03-02', null),
(1, 'Transferência', 300.00, '2025-03-02', 3),
(3, 'Transferência', 1300.00, '2025-03-02', 1),
(3, 'Transferência', 532.50, '2025-04-01',2);

select * from transacoes

/*EXERCÍCIO 8
Listar todos os clientes cadastrados.*/
select * from clientes

/*EXERCÍCIO 9
Listar todas as contas e seus respectivos clientes.*/
select * from contas
inner join clientes on (contas.id_cliente = clientes.id_cliente)

/*EXERCÍCIO 10
Insira um novo cliente no sistema*/
select * from clientes
insert into clientes (nome,cpf,endereco,telefone)
values('Jose da Silva','12345678911','Rua Brasil, 300, Centro','11988887777'),
('Maria Jose','22233344455','Rua das Palmeiras, 10, São Jose dos Campos','11988885555');

/*EXERCÍCIO 11
Crie uma conta para esse novo cliente.*/
select * from contas
select * from clientes
insert into contas (numero_conta,saldo,id_cliente)
values ('1254-52','0.01',6)


/*EXERCÍCIO 12
Realize uma transferência de R$ 100,00 da conta 000123 para a conta 000789.*/
INSERT INTO contas (numero_conta, saldo, id_cliente) VALUES
('000789', 1500.00, 1)
select * from contas


select * from transacoes
INSERT INTO transacoes (id_conta, tipo, valor, data_transacao, destino_transferencia) VALUES
(1, 'Transferência', 100.00, '2025-04-01',7);

/*13 - liste todas as contas do banco mostrando os saldos atualizados */
select * from contas c
