create database clima_alerta

CREATE TABLE if not exists TipoEvento(
  idTipoEvento serial NOT NULL ,
  nome VARCHAR(100) not  NULL,
  descricao VARCHAR(100) not NULL,
  primary key(idTipoEvento)
);

select * from tipoevento
drop table localizacao 

CREATE TABLE if not exists localizacao (
  idlocalizacao serial NOT NULL,
  latitude DECIMAL(9,6) not NULL,
  longitude DECIMAL(9,6) not NULL,
  cidade VARCHAR(60) not NULL,
  estado VARCHAR(2) not NULL,
  PRIMARY KEY(idlocalizacao)
);

select * from localizacao
select * from localizacao

CREATE TABLE if not exists localizacao (
  idlocalizacao serial NOT NULL,
  latitude INTEGER not NULL,
  longitude INTEGER not NULL,
  cidade VARCHAR(60) not NULL,
  estado VARCHAR(2) not NULL,
  PRIMARY KEY(idlocalizacao)
);

CREATE TABLE if not exists usuario (
  idUsuario serial NOT NULL,
  nome varchar(60) not NULL,
  email varchar(100) not NULL,
  senhaHash VARCHAR(100) not NULL,
  PRIMARY KEY(idUsuario)
);

select * from usuario

CREATE TABLE if not exists evento (
  idEvento serial NOT NULL,
  titulo varchar(100) NULL,
  descricao varchar(100) NULL,
  datahora date,
  status varchar(50) NULL,
  idTipoEvento integer NOT NULL,
  idLocalizacao integer NOT NULL,
  PRIMARY KEY(idEvento),
  FOREIGN KEY(idTipoEvento) REFERENCES TipoEvento(idTipoEvento),
  FOREIGN KEY(idLocalizacao) REFERENCES localizacao(idlocalizacao)
);

select * from evento



CREATE TABLE if not exists relato (
  idRelato serial NOT NULL,
  texto varchar(100) NOT NULL,
  dataHora DATE NULL,
  idEvento integer not null,
  idUsuario integer not null,
  PRIMARY KEY(idRelato),
  FOREIGN KEY(idEvento) REFERENCES evento(idEvento),
  FOREIGN KEY(idUsuario) REFERENCES usuario(idUsuario)
);

select * from relato


CREATE TABLE if not exists alerta (
  idAlerta serial NOT NULL,
  mensagem varchar(100) NOT NULL,
  dataHora DATE NULL,
  idEvento integer not null,
  idTipoEvento integer not null,
  PRIMARY KEY(idAlerta),
  FOREIGN KEY(idEvento) REFERENCES evento(idEvento),
  FOREIGN KEY(idTipoEvento) REFERENCES TipoEvento(idTipoEvento)
);

select * from alerta

CREATE TABLE IF NOT EXISTS historico_status (
    idHistorico SERIAL PRIMARY KEY,
    idEvento INTEGER NOT NULL,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50) NOT NULL,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT, -- Para explicar o porquê da mudança (ex: "Nível do rio subiu 2m")
    idUsuario_responsavel INTEGER, -- Quem alterou o status?
    
    FOREIGN KEY (idEvento) REFERENCES evento(idEvento), 
    FOREIGN KEY (idUsuario_responsavel) REFERENCES usuario(idUsuario)
);

