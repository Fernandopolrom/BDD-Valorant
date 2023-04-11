-- ----------------------------------- VISTAS -------------------------------------------------
-- 1 consulta 5
CREATE VIEW Agentes_Populares AS
SELECT pa.Nombre_agente, COUNT(*) AS Total
FROM PlayerAgents pa
GROUP BY pa.Nombre_agente
ORDER BY Total DESC;

SELECT * FROM Agentes_Populares;

-- 1 consulta 4

CREATE VIEW Estadisticas AS
SELECT j.Nombre, p.Mapa, p.Resultado, e.Kills, e.Deaths, e.Assists, e.Headshots, pa.Nombre_agente
FROM Jugadores j
INNER JOIN Partidas p ON j.JugadorID = p.JugadorID
INNER JOIN Estadisticas_Jugador e ON p.PartidaID = e.PartidaID AND j.JugadorID = e.JugadorID
INNER JOIN PlayerAgents pa ON j.JugadorID = pa.JugadorID
WHERE j.Nombre = 'Roman' AND j.Servidor = 'Tokio'
ORDER BY p.PartidaID ASC;


SELECT * FROM Estadisticas;


-- ----------------------------------- FUNCIONES -------------------------------------------------

-- 1 
drop function if exists calcular_KD_promedio;
DELIMITER $$
CREATE FUNCTION calcular_KD_promedio(jugador_id INT)
RETURNS FLOAT
BEGIN
    DECLARE total_kills INT;
    DECLARE total_deaths INT;
    DECLARE kd FLOAT;
    
    SELECT SUM(Kills) INTO total_kills FROM Estadisticas_Jugador WHERE JugadorID = jugador_id;
    SELECT SUM(Deaths) INTO total_deaths FROM Estadisticas_Jugador WHERE JugadorID = jugador_id;
    
    IF total_deaths = 0 THEN
        SET kd = total_kills;
    ELSE
        SET kd = total_kills / total_deaths;
    END IF;
    
    RETURN kd;
END $$
DELIMITER ;
SELECT calcular_KD_promedio(1);

-- La función coge como dato jugador_id que representa el ID del jugador para el cual deseamos calcular el KD promedio.Declara tres variables, 
-- total_kills, total_deaths, y kd y devuelve el KD promedio

-- 2
drop function if exists obtener_agente_principal;
DELIMITER $$
CREATE FUNCTION obtener_agente_principal(jugador_id INT)
RETURNS VARCHAR(100)
BEGIN
    DECLARE agente_principal VARCHAR(100);
    
    SELECT Nombre_agente INTO agente_principal
    FROM PlayerAgents
    WHERE JugadorID = jugador_id
    LIMIT 1;
    
    RETURN agente_principal;
END $$

DELIMITER ;

SELECT obtener_agente_principal(10);


-- Esta función devuelve el nombre del agente principal de un jugador. La entrada de la función sería el ID del jugador, y la salida 
-- sería el nombre del agente principal.

-- ----------------------------------- PROCEDIMIENTOS -------------------------------------------------
-- 1 Procedimiento que hace uso de la funcion calcular_KD_promedio
drop procedure if exists obtener_info_jugador_kd;
DELIMITER $$
CREATE PROCEDURE obtener_info_jugador_kd(IN jugador_id INT, OUT kd_promedio FLOAT)
BEGIN
    SET kd_promedio = calcular_KD_promedio(jugador_id);
END $$
DELIMITER ;

CALL obtener_info_jugador_kd(3, @kd_promedio);
SELECT @kd_promedio;



-- 2

drop procedure if exists info_jugador;
DELIMITER $$
CREATE PROCEDURE info_jugador(IN jugador_id INT)
BEGIN
    DECLARE nombre_jugador VARCHAR(255);
    DECLARE email_jugador VARCHAR(255);
    DECLARE servidor_jugador VARCHAR(50);

    SELECT Nombre, Email, Servidor INTO nombre_jugador, email_jugador, servidor_jugador
    FROM Jugadores
    WHERE JugadorID = jugador_id;

    SELECT CONCAT('Nombre: ', nombre_jugador) AS info, CONCAT('Email: ', email_jugador) AS info, 
   	CONCAT('Servidor: ', servidor_jugador) AS info;
END $$

DELIMITER ;

CALL info_jugador(22);
-- Este procedimiento busca información sobre el jugador con el ID proporcionado, incluyendo su nombre, dirección de correo electrónico y servidor.

-- 3

DELIMITER //
CREATE PROCEDURE obtener_nombres_agentes(IN jugador_id INT)
BEGIN
    DECLARE nombre_agente VARCHAR(100);
    
    DECLARE agentes_cursor CURSOR FOR
        SELECT Nombre_agente FROM PlayerAgents WHERE JugadorID = jugador_id;
    
    OPEN agentes_cursor;
    
    agentes_loop: LOOP
        FETCH agentes_cursor INTO nombre_agente;
        IF (nombre_agente IS NULL) THEN
            LEAVE agentes_loop;
        END IF;
        SELECT nombre_agente;
    END LOOP;
    
    CLOSE agentes_cursor;
    
END //
DELIMITER ;

-- Este procedimiento recibe como entrada un jugador_id y utiliza un cursor para obtener los nombres de los agentes asociados a ese 
-- jugador en la tabla PlayerAgents.Para llamar al procedimiento, se usa el siguiente comando:

CALL obtener_nombres_agentes(2);



-- ----------------------------------- TRIGGER -------------------------------------------------
-- 1
-- En este trigger cada vez que se inserte una nueva partida en la tabla Partidas, se actualice la tabla Jugadores con la última partida jugada por ese jugador. 
-- Se ejecutará después de que se inserte una nueva fila en la tabla Partidas. Para cada nueva fila, se actualizará la tabla Jugadores 
-- estableciendo el valor de Ultima_partida del jugador correspondiente al PartidaID de la nueva fila insertada (NEW.PartidaID).

CREATE TRIGGER actualizar_ultima_partida
AFTER INSERT ON Partidas
FOR EACH ROW
BEGIN
    UPDATE Jugadores SET Ultima_partida = NEW.PartidaID
    WHERE JugadorID = NEW.JugadorID;
END;


-- 2

CREATE TRIGGER actualizar_KD_despues_insertar_partida
AFTER INSERT ON Partidas
FOR EACH ROW
BEGIN
    DECLARE jugador_id INT;
    DECLARE kd_promedio FLOAT;
    
    SELECT JugadorID INTO jugador_id FROM Partidas WHERE PartidaID = NEW.PartidaID;
    
    SET kd_promedio = calcular_KD_promedio(jugador_id);
    
    UPDATE Jugadores SET KD_promedio = kd_promedio WHERE JugadorID = jugador_id;
END;

-- En este trigger uso la función calcular_KD_promedio que use en el primer procedimiento. Cada vez que se inserta una nueva partida en 
-- la tabla Partidas, el trigger obtiene el ID del jugador y calcula el promedio de KD. 
-- Luego actualiza el campo KD_promedio en la tabla Jugadores con el valor obtenido.

