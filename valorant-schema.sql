CREATE DATABASE `valorant` /*!40100 DEFAULT CHARACTER SET latin1 */;

CREATE TABLE `estadisticas_jugador` (
  `StatID` int(11) NOT NULL,
  `JugadorID` int(11) NOT NULL,
  `PartidaID` int(11) NOT NULL,
  `Kills` int(11) NOT NULL,
  `Deaths` int(11) NOT NULL,
  `Assists` int(11) NOT NULL,
  `Headshots` int(11) NOT NULL,
  PRIMARY KEY (`StatID`,`JugadorID`,`PartidaID`),
  KEY `JugadorID` (`JugadorID`),
  KEY `PartidaID` (`PartidaID`),
  CONSTRAINT `estadisticas_jugador_ibfk_1` FOREIGN KEY (`JugadorID`) REFERENCES `jugadores` (`JugadorID`),
  CONSTRAINT `estadisticas_jugador_ibfk_2` FOREIGN KEY (`PartidaID`) REFERENCES `partidas` (`PartidaID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `jugadores` (
  `JugadorID` int(11) NOT NULL,
  `Nombre` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Servidor` varchar(50) NOT NULL,
  PRIMARY KEY (`JugadorID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partidas` (
  `PartidaID` int(11) NOT NULL,
  `Mapa` varchar(100) NOT NULL,
  `Resultado` varchar(100) NOT NULL,
  `JugadorID` int(11) NOT NULL,
  PRIMARY KEY (`PartidaID`),
  KEY `JugadorID` (`JugadorID`),
  CONSTRAINT `partidas_ibfk_1` FOREIGN KEY (`JugadorID`) REFERENCES `jugadores` (`JugadorID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `playeragents` (
  `JugadorID` int(11) NOT NULL,
  `Nombre_agente` varchar(100) NOT NULL,
  PRIMARY KEY (`JugadorID`,`Nombre_agente`),
  CONSTRAINT `playeragents_ibfk_1` FOREIGN KEY (`JugadorID`) REFERENCES `jugadores` (`JugadorID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
