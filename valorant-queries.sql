
use valorant;
-- ---------------------------- CONSULTAS ---------------------------------

-- 1) Esta consulta selecciona el nombre del jugador, el nombre del agente, el mapa, las kills y las muertes de los jugadores en las partidas. 
-- Se unen las tablas Jugadores, Agentes y Partidas. Además, se aplica una condición 
-- para seleccionar solo aquellos jugadores cuya puntuación sea mayor a 30. Por último, los resultados se ordenan en función 
-- de la cantidad de kills en orden descendente.

SELECT j.nombre AS jugador, a.nombre AS agente, p.mapa, p.kills, p.muertes
FROM Jugadores j
JOIN Agentes a ON j.id_agente = a.id_agente
JOIN Partidas p ON j.id_partida = p.id_partida
WHERE j.puntuacion > 30
ORDER BY p.kills DESC;


-- 2) Esta consulta devuelve el nombre del jugador y el número total de partidas en las que ha participado. Se unen las tablas Jugadores y Partidas. 
-- Luego, se agrupa por el nombre del jugador y se cuenta el número de registros en cada grupo 
-- Despues filtramos aquellos jugadores que tienen más de 3 partidas en total. 
-- Por último, los resultados se ordenan en orden descendente según el número total de partidas.


SELECT j.nombre AS jugador, COUNT(*) AS total_partidas
FROM Jugadores j
JOIN Partidas p ON j.id_partida = p.id_partida
GROUP BY j.nombre
HAVING total_partidas > 3
ORDER BY total_partidas DESC;


-- 3) En esta consulta, estamos seleccionando el nombre del jugador, su edad y su puntuación de la tabla Jugadores. La subconsulta se utiliza para obtener
-- el promedio de puntuación de todos los jugadores que son de madrid. Luego, comparamos la puntuación de cada jugador con el promedio calculado y seleccionamos aquellos jugadores cuya 
-- puntuación sea mayor que el promedio de los jugadores. Finalmente, ordenamos los resultados por puntuación en orden descendente.


SELECT j.nombre AS jugador, j.edad, j.puntuacion
FROM Jugadores j
WHERE j.puntuacion > (
    SELECT AVG(puntuacion) 
    FROM Jugadores
    WHERE país = 'madrid'
)
ORDER BY j.puntuacion DESC;


-- 4) En esta consulta, estamos seleccionando el nombre del jugador, su edad y su puntuación de la tabla Jugadores.La subconsulta interna calcula el promedio de 
-- la puntuación para cada jugador que ha participado en partidas en el mapa "Ascent" y cuya edad es mayor a 18 años. Luego, la subconsulta externa utiliza 
-- el promedio calculado en la subconsulta interna y lo compara con la puntuación de cada jugador en la tabla Jugadores. Se seleccionan aquellos jugadores 
-- cuya puntuación es mayor que el promedio calculado en la subconsulta interna. Finalmente, los resultados se ordenan por puntuación en orden descendente.



SELECT j.nombre AS jugador, j.edad, j.puntuacion
FROM Jugadores j
WHERE j.puntuacion > (
    SELECT AVG(subquery.puntuacion_promedio)
    FROM (
        SELECT AVG(j2.puntuacion) AS puntuacion_promedio
        FROM Jugadores j2
        JOIN Partidas p2 ON j2.id_partida = p2.id_partida
        WHERE p2.mapa = 'Ascent' AND j2.edad > 18
        GROUP BY j2.id_jugador
    ) AS subquery
)
ORDER BY j.puntuacion DESC;


-- 5) Esta consulta selecciona el nombre del agente y el número de jugadores que lo utilizan. Se unen las tablas Agentes y Jugadores
-- y luego se agrupa por el nombre del agente.Los resultados se ordenan en orden descendente según el número de jugadores.


SELECT a.nombre AS agente, COUNT(*) AS total_jugadores
FROM Agentes a
JOIN Jugadores j ON a.id_agente = j.id_agente
GROUP BY a.nombre
ORDER BY total_jugadores DESC;



-- ---------------------------- VISTAS ---------------------------------

-- Vista 1 de consulta 1

CREATE VIEW VistaJugadores AS
SELECT j.nombre AS jugador, a.nombre AS agente, p.mapa, p.kills, p.muertes
FROM Jugadores j
JOIN Agentes a ON j.id_agente = a.id_agente
JOIN Partidas p ON j.id_partida = p.id_partida
WHERE j.puntuacion > 30
ORDER BY p.kills DESC;


SELECT *
FROM VistaJugadores;


-- Vista 2 de consulta 5

CREATE VIEW vista_jugadores_por_agente AS
SELECT a.nombre AS agente, COUNT(*) AS total_jugadores
FROM Agentes a
JOIN Jugadores j ON a.id_agente = j.id_agente
GROUP BY a.nombre
ORDER BY total_jugadores DESC;


SELECT * FROM vista_jugadores_por_agente;


-- ---------------------------- FUNCIONES ---------------------------------


-- Recupera las estadísticas de un jugador de la base de datos. Esta función tomará como entrada el ID del jugador y 
-- devolverá su nombre, rol y puntuación general.

drop function if exists estadisticas_jugador;

DELIMITER //

CREATE FUNCTION estadisticas_jugador(player_id INT) RETURNS TEXT
BEGIN
    DECLARE nombre_jugador TEXT;
    DECLARE rol_jugador TEXT;
    DECLARE puntuacion_jugador INT;

    SELECT Jugadores.nombre, Agentes.rol, Jugadores.puntuacion
    INTO nombre_jugador, rol_jugador, puntuacion_jugador
    FROM Jugadores
    JOIN Agentes ON Jugadores.id_agente = Agentes.id_agente
    WHERE Jugadores.id_jugador = player_id;

    RETURN CONCAT('Nombre del jugador: ', nombre_jugador, '   Rol del jugador: ', rol_jugador, '   Puntuación: ', puntuacion_jugador);
END //

DELIMITER ;

select estadisticas_jugador(8);


-- 2) La función sumar_puntuacion_jugador recibe el ID del jugador como parámetro y devuelve la suma total de la puntuación de todas las partidas 
-- del jugador. Si el jugador no tiene puntuación registrada en ninguna partida, la función devuelve 0.

drop function if exists sumar_puntuacion_jugador;
DELIMITER //

CREATE FUNCTION sumar_puntuacion_jugador(player_id INT) RETURNS INT
BEGIN
    DECLARE total_score INT;

    SELECT SUM(puntuacion)
    INTO total_score
    FROM Jugadores
    WHERE id_jugador = player_id;

    IF total_score IS NULL THEN
        SET total_score = 0;
    END IF;

    RETURN total_score;
END //

DELIMITER ;

SELECT sumar_puntuacion_jugador(37) AS total_puntuacion;


-- ---------------------------- PROCEDIMIENTOS ---------------------------------

-- Este procedimiento llamado "ActualizarPuntuacionJugador",toma dos parámetros de entrada: "jugador_id" y "nueva_puntuacion" (la nueva puntuación 
-- a asignar al jugador). El procedimiento ejecuta una instrucción UPDATE para actualizar la puntuación del 
-- jugador con el ID asignado.


drop procedure if exists ActualizarPuntuacionJugador;

DELIMITER $$
CREATE PROCEDURE ActualizarPuntuacionJugador(IN jugador INTEGER, IN nueva_puntuacion INTEGER)
BEGIN
    UPDATE Jugadores
    SET puntuacion = nueva_puntuacion
    WHERE jugador = id_jugador;
END $$

DELIMITER ;


CALL ActualizarPuntuacionJugador(7, 21);

-- ---------------------------- PROCEDIMIENTO POR CURSOR ---------------------------------

-- Enn este procedimiento con cursor la consulta dentro del cursor cur concatena el nombre y la puntuación de cada jugador en una sola columna 
-- Luego, se limita el resultado a los cinco jugadores con la puntuación más alta.Y devuelve el resultado de los 5 primeros cada uno en su consulta.


drop procedure if exists mostrar_jugadores;
DELIMITER //

CREATE PROCEDURE mostrar_jugadores()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE player_name_score TEXT;
    DECLARE cur CURSOR FOR SELECT CONCAT(nombre, ' - Puntuación: ', puntuacion) AS jugador FROM Jugadores ORDER BY puntuacion DESC LIMIT 5;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO player_name_score;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Puedes realizar acciones con los datos del jugador aquí
        SELECT player_name_score;
    END LOOP;
    
    CLOSE cur;
END //

DELIMITER ;


CALL mostrar_jugadores();





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
DELIMITER //
CREATE TRIGGER calcular_puntuacion
BEFORE INSERT ON Partidas
FOR EACH ROW
BEGIN
    DECLARE puntuacion_total INTEGER;
    
    SET puntuacion_total = (NEW.kills * 2) + NEW.asistencias - (NEW.muertes * 0.5);
    
    SET NEW.puntuación = puntuacion_total;
END //
DELIMITER ;


INSERT INTO Partidas (id_partida, episodio, mapa, duracion, fecha_inicio, fecha_fin, kills, muertes, asistencias)
VALUES (1000, 1, 'lotus', 30, '2023-05-20', '2023-05-20', 10, 5, 3);



-- 2) 
-- En este ejemplo, el trigger actualizar_puntuacion_media se ejecuta después de cada inserción en la tabla Partidas. Su objetivo es calcular y 
-- actualizar la puntuación media en la tabla Temporada basándose en las nuevas inserciones realizadas en la tabla Partidas.
-- Cada vez que se inserta una nueva partida en la tabla Partidas, el trigger actualizar_puntuacion_media se activa y recalcula 
-- la puntuación media, actualizando el valor correspondiente en la tabla Temporada.
DELIMITER //

CREATE TRIGGER actualizar_puntuacion_media
AFTER INSERT ON Partidas
FOR EACH ROW
BEGIN
    DECLARE total_partidas INTEGER;
    DECLARE total_puntuacion INTEGER;
    DECLARE media_puntuacion DECIMAL(10,2);
    
    -- Obtener el total de partidas y la suma de puntuaciones
    SELECT COUNT(*) INTO total_partidas FROM Partidas;
    SELECT SUM(puntuación) INTO total_puntuacion FROM Partidas;
    
    -- Calcular la media de puntuación
    SET media_puntuacion = total_puntuacion / total_partidas;
    
    -- Actualizar la puntuación media en la tabla Temporada
    UPDATE Temporada SET puntuación_media = media_puntuacion;
END //

DELIMITER ;





















