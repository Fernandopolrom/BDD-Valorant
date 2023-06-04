CREATE DATABASE `valorant` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

CREATE TABLE `agentes` (
  `id_agente` int NOT NULL,
  `nombre` text,
  `rol` text,
  `habilidad_1` text,
  `habilidad_2` text,
  `habilidad_3` text,
  `habilidad_definitiva` text,
  PRIMARY KEY (`id_agente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `armas` (
  `id_arma` int NOT NULL,
  `nombre` text,
  `tipo` text,
  `daño_cuerpo_a_cuerpo` int DEFAULT NULL,
  `daño_a_la_cabeza` int DEFAULT NULL,
  PRIMARY KEY (`id_arma`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `jugadores` (
  `id_jugador` int NOT NULL,
  `nombre` text,
  `edad` int DEFAULT NULL,
  `país` text,
  `rango` enum('hierro','bronce','plata','oro','platino','diamante','ascendente','inmortal','radiante') DEFAULT NULL,
  `id_agente` int DEFAULT NULL,
  `id_partida` int DEFAULT NULL,
  `id_arma` int DEFAULT NULL,
  `puntuacion` int DEFAULT NULL,
  PRIMARY KEY (`id_jugador`),
  KEY `id_agente` (`id_agente`),
  KEY `id_partida` (`id_partida`),
  KEY `id_arma` (`id_arma`),
  CONSTRAINT `jugadores_ibfk_1` FOREIGN KEY (`id_agente`) REFERENCES `agentes` (`id_agente`),
  CONSTRAINT `jugadores_ibfk_2` FOREIGN KEY (`id_partida`) REFERENCES `partidas` (`id_partida`),
  CONSTRAINT `jugadores_ibfk_3` FOREIGN KEY (`id_arma`) REFERENCES `armas` (`id_arma`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partidas` (
  `id_partida` int NOT NULL,
  `episodio` int NOT NULL,
  `mapa` text,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `kills` int DEFAULT NULL,
  `muertes` int DEFAULT NULL,
  `asistencias` int DEFAULT NULL,
  `duracion` int DEFAULT NULL,
  `puntuacion` int DEFAULT NULL,
  PRIMARY KEY (`id_partida`,`episodio`),
  KEY `episodio` (`episodio`),
  CONSTRAINT `partidas_ibfk_1` FOREIGN KEY (`episodio`) REFERENCES `temporada` (`episodio`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `rol` (
  `id_rol_partida_jugador` int NOT NULL,
  `rol_principal` text,
  `id_partida` int DEFAULT NULL,
  `id_jugador` int DEFAULT NULL,
  PRIMARY KEY (`id_rol_partida_jugador`),
  KEY `id_partida` (`id_partida`),
  KEY `id_jugador` (`id_jugador`),
  CONSTRAINT `rol_ibfk_1` FOREIGN KEY (`id_partida`) REFERENCES `partidas` (`id_partida`),
  CONSTRAINT `rol_ibfk_2` FOREIGN KEY (`id_jugador`) REFERENCES `jugadores` (`id_jugador`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `temporada` (
  `episodio` int NOT NULL,
  `id_partida` int DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `estado` text,
  `id_jugador` int DEFAULT NULL,
  PRIMARY KEY (`episodio`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
