/*Atividade aula 3*/


CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    cnh VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE Carro (
    id_carro SERIAL PRIMARY KEY,
    placa VARCHAR(10) UNIQUE NOT NULL,
    modelo VARCHAR(50),
    valor_diaria DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'Disponivel'
);

CREATE TABLE Aluguel (
    id_aluguel SERIAL PRIMARY KEY,
    id_cliente INT REFERENCES Cliente(id_cliente),
    id_carro INT REFERENCES Carro(id_carro),
    data_retirada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_prevista DATE,
    valor_total DECIMAL(10,2)
);