/* aula 6*/
insert into alerta (mensagem, datahora,nivel,id_evento)
values ('Chuva forte com pontencial grande','2026-03-13','Médio', 3 )
insert into alerta (mensagem, datahora,nivel,id_evento)
values ('Queimada em aarea de preservação','2025-07-13','Grave', 3 )
select * from evento
select * from alerta

select * from alerta order by datahora

select * from usuario limit 3