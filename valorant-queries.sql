
use valorant;
-- ---------------------------- CONSULTAS ---------------------------------

-- 1) Esta consulta selecciona el nombre del jugador, el nombre del agente, el mapa, las kills y las muertes de los jugadores en las partidas. 
-- Se unen las tablas Jugadores, Agentes y Partidas. Además, se aplica una condición 
-- para seleccionar solo aquellos jugadores cuya puntuación sea mayor a 30. Por último, los resultados se ordenan en función 
-- de la cantidad de kills en orden descendente.

select j.nombre as jugador, a.nombre as agente, p.mapa, p.kills, p.muertes
from jugadores j
join agentes a on j.id_agente = a.id_agente
join partidas p on j.id_partida = p.id_partida
where j.puntuacion > 30
order by p.kills desc;


-- 2) Esta consulta devuelve el nombre del jugador y el número total de partidas en las que ha participado. Se unen las tablas Jugadores y Partidas. 
-- Luego, se agrupa por el nombre del jugador y se cuenta el número de registros en cada grupo 
-- Despues filtramos aquellos jugadores que tienen más de 2 partidas en total. 
-- Por último, los resultados se ordenan en orden descendente según el número total de partidas.


select j.nombre as jugador, count(*) as total_partidas
from jugadores j
join partidas p on j.id_partida = p.id_partida
group by j.nombre
having total_partidas > 2
order by total_partidas desc;


-- 3) En esta consulta, estamos seleccionando el nombre del jugador, su edad y su puntuación de la tabla Jugadores. La subconsulta se utiliza para obtener
-- el promedio de puntuación de todos los jugadores que son de madrid. Luego, comparamos la puntuación de cada jugador con el promedio calculado y seleccionamos aquellos jugadores cuya 
-- puntuación sea mayor que el promedio de los jugadores. Finalmente, ordenamos los resultados por puntuación en orden descendente.


select j.nombre as jugador, j.edad, j.puntuacion
from jugadores j
where j.puntuacion > (
    select avg(puntuacion) 
    from jugadores
    where país = 'madrid'
)
order by j.puntuacion desc;


-- 4) En esta consulta, estamos seleccionando el nombre del jugador, su edad y su puntuación de la tabla Jugadores.La subconsulta interna calcula el promedio de 
-- la puntuación para cada jugador que ha participado en partidas en el mapa "Ascent" y cuya edad es mayor a 18 años. Luego, la subconsulta externa utiliza 
-- el promedio calculado en la subconsulta interna y lo compara con la puntuación de cada jugador en la tabla Jugadores. Se seleccionan aquellos jugadores 
-- cuya puntuación es mayor que el promedio calculado en la subconsulta interna. Finalmente, los resultados se ordenan por puntuación en orden descendente.



select j.nombre as jugador, j.edad, j.puntuacion
from jugadores j
where j.puntuacion > (
    select avg(subquery.puntuacion_promedio)
    from (
        select avg(j2.puntuacion) as puntuacion_promedio
        from jugadores j2
        join partidas p2 on j2.id_partida = p2.id_partida
        where p2.mapa = 'ascent' and j2.edad > 18
        group by j2.id_jugador
    ) as subquery
)
order by j.puntuacion desc;



-- 5) Esta consulta selecciona el nombre del agente y hace un count para saber el numero de jugadores que han jugado ese 
-- agente y calcula el promedio de edad.

select a.nombre as agente, count(*) as total_jugadores, avg(year(now()) - j.edad) as promedio_edad
from agentes a
join jugadores j on a.id_agente = j.id_agente
where j.rango in ('platino', 'diamante', 'ascendente', 'inmortal', 'radiante')
group by a.nombre
having count(*) > 5
order by promedio_edad desc, total_jugadores desc;

-- ---------------------------- VISTAS ---------------------------------

-- Vista 1 de consulta 1

create view vistajugadores as
select j.nombre as jugador, a.nombre as agente, p.mapa, p.kills, p.muertes
from jugadores j
join agentes a on j.id_agente = a.id_agente
join partidas p on j.id_partida = p.id_partida
where j.puntuacion > 30
order by p.kills desc;


select *
from vistajugadores;


-- vista 2 de consulta 5

create view vista_jugadores_por_agente as
select a.nombre as agente, count(*) as total_jugadores
from agentes a
join jugadores j on a.id_agente = j.id_agente
group by a.nombre
order by total_jugadores desc;


select * from vista_jugadores_por_agente;


-- ---------------------------- FUNCIONES ---------------------------------


-- Recupera las estadísticas de un jugador de la base de datos. Esta función tomará como entrada el ID del jugador y 
-- devolverá su nombre, rol y puntuación general.

drop function if exists estadisticas_jugador;

delimiter //

create function estadisticas_jugador(player_id int) returns text
begin
    declare nombre_jugador text;
    declare rol_jugador text;
    declare puntuacion_jugador int;

    select jugadores.nombre, agentes.rol, jugadores.puntuacion
    into nombre_jugador, rol_jugador, puntuacion_jugador
    from jugadores
    join agentes on jugadores.id_agente = agentes.id_agente
    where jugadores.id_jugador = player_id;

    return concat('nombre del jugador: ', nombre_jugador, '   rol del jugador: ', rol_jugador, '   puntuación: ', puntuacion_jugador);
end //

delimiter ;

select estadisticas_jugador(8);


-- 2) La función sumar_puntuacion_jugador recibe el ID del jugador como parámetro y devuelve la suma total de la puntuación de todas las partidas 
-- del jugador. Si el jugador no tiene puntuación registrada en ninguna partida, la función devuelve 0.

drop function if exists sumar_puntuacion_jugador;
delimiter //

create function sumar_puntuacion_jugador(player_id int) returns int
begin
    declare total_score int;

    select sum(puntuacion)
    into total_score
    from jugadores
    where id_jugador = player_id;

    if total_score is null then
        set total_score = 0;
    end if;

    return total_score;
end //

delimiter ;

select sumar_puntuacion_jugador(37) as total_puntuacion;


-- ---------------------------- PROCEDIMIENTOS ---------------------------------

-- Este procedimiento llamado insertar_agente, inserta un nuevo agente con los datos que tu quieras meter:

drop procedure if exists insertaragente;
delimiter $$
create procedure insertaragente(
  in nombre_agente text,
  in rol_agente text,
  in habilidad_1 text,
  in habilidad_2 text,
  in habilidad_3 text,
  in habilidad_definitiva text
)
begin
  insert into agentes (nombre, rol, habilidad_1, habilidad_2, habilidad_3, habilidad_definitiva)
  values (nombre_agente, rol_agente, habilidad_1, habilidad_2, habilidad_3, habilidad_definitiva);
end $$
delimiter ;


CALL insertaragente (1000, jet, duelista, q, e, z, x);





-- ---------------------------- PROCEDIMIENTO POR CURSOR ---------------------------------

-- En este procedimiento con cursor la consulta dentro del cursor cur concatena el nombre y la puntuación de cada jugador en una sola columna 
-- Luego, se limita el resultado a los cinco jugadores con la puntuación más alta.Y devuelve el resultado de los 5 primeros cada uno en su consulta.


drop procedure if exists mostrar_jugadores;
delimiter $$

create procedure mostrar_jugadores()
begin
    declare done int default false;
    declare player_name_score text;
    declare result text default '';
    declare cur cursor for select concat(nombre, ' - puntuación: ', puntuacion) as jugador from jugadores order by puntuacion desc limit 5;
    declare continue handler for not found set done = true;
    
    open cur;
    
    read_loop: loop
        fetch cur into player_name_score;
        
        if done then
            leave read_loop;
        end if;
        
        -- concatenar el resultado en una cadena
        set result = concat(result, player_name_score, ' \n ');
    end loop;
    
    close cur;
    
    -- imprimir el resultado final
    select result;
end $$

delimiter ;

call mostrar_jugadores();






-- ---------------------------- PROCEDIMIENTO CON FUNCION --------------------------------

-- El procedimiento verificar_clasificacion_jugador toma el ID del jugador como parámetro y utiliza la función sumar_puntuacion_jugador para obtener 
-- la suma de la puntuación del jugador. Luego, comprueba si la puntuación es mayor que 15 y muestra un mensaje correspondiente.

DELIMITER //

CREATE PROCEDURE verificar_clasificacion_jugador(player_id INT)
BEGIN
    DECLARE total_score INT;

    SET total_score = sumar_puntuacion_jugador(player_id);

    IF total_score > 15 THEN
        SELECT '¡Estás clasificado!' AS mensaje;
    ELSE
        SELECT 'No estás clasificado.' AS mensaje;
    END IF;
END //

DELIMITER ;

CALL verificar_clasificacion_jugador(1);


-- ---------------------------- TRIGGER --------------------------------

-- 1) Este trigger se activará antes de insertar un nuevo registro en la tabla "Partidas". El objetivo del trigger será calcular la puntuación 
-- total de la partida en base a los valores de "kills", "muertes" y "asistencias".
delimiter //
create trigger calcular_puntuacion
before insert on partidas
for each row
begin
    declare puntuacion_total integer;
    
    set puntuacion_total = (new.kills * 2) + new.asistencias - (new.muertes * 0.5);
    
    set new.puntuacion = puntuacion_total;
end //
delimiter ;


insert into partidas (id_partida, episodio, mapa, duracion, fecha_inicio, fecha_fin, kills, muertes, asistencias)
values (1000, 1, 'lotus', 30, '2023-05-20', '2023-05-20', 10, 5, 3);



-- 2) 
-- Este trigger sirve para eliminar registros relacionados después de borrar un agente.Este desencadenador se activará después de eliminar
-- un registro de la tabla agentes. Eliminará automáticamente los registros correspondientes en la tabla jugadores donde el agente asociado 
-- sea el mismo que el agente eliminado. Además, eliminará los registros de la tabla rol donde el id_jugador no exista en la tabla 
-- jugadores después de la eliminación.

delimiter $$

create trigger actualizar_puntuacion_media
after insert on partidas
for each row
begin
    declare total_partidas integer;
    declare total_puntuacion integer;
    declare media_puntuacion decimal(10,2);
    
    -- obtener el total de partidas y la suma de puntuaciones
    select count(*) into total_partidas from partidas;
    select sum(puntuación) into total_puntuacion from partidas;
    
    -- calcular la media de puntuación
    set media_puntuacion = total_puntuacion / total_partidas;
    
    -- actualizar la puntuación media en la tabla temporada
    update temporada set puntuación_media = media_puntuacion;
end $$

delimiter ;


delete from agentes where id_agente = 1001;



















