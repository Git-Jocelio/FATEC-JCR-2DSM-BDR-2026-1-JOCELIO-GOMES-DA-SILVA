/*  ATIVIDADE AULA AULA 2 - PROF LUCINEIDE PIMENTA*/
create database queimadas_db;

create table focos_calor(
  queimadas_id serial,
  estado varchar(20) not null,
  bioma varchar(50) not null,
  data_ocorrencia date,
  primary key(queimadas_id)
);

INSERT INTO focos_calor (estado, bioma, data_ocorrencia) VALUES
('Amazonas', 'Amazônia', '2025-02-01');

INSERT INTO focos_calor (estado, bioma, data_ocorrencia) VALUES
('Mato Grosso', 'Cerrado', '2025-02-03');

INSERT INTO focos_calor (estado, bioma, data_ocorrencia) VALUES
('Pará', 'Amazônia', '2025-02-05');

select * from focos_calor;