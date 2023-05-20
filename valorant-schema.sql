 drop database if exists valorant;
create database valorant;
use valorant;

CREATE TABLE Agentes (
id_agente INTEGER PRIMARY KEY,
nombre TEXT,
rol TEXT,
habilidad_1 TEXT,
habilidad_2 TEXT,
habilidad_3 TEXT,
habilidad_definitiva TEXT
);


CREATE TABLE Armas (
id_arma INTEGER PRIMARY KEY,
nombre TEXT,
tipo TEXT,
daño_cuerpo_a_cuerpo INTEGER,
daño_a_la_cabeza INTEGER
);


CREATE TABLE Temporada (
episodio INTEGER,
id_partida INTEGER,
fecha DATE,
estado TEXT,
PRIMARY KEY (episodio)
);


CREATE TABLE Partidas (
id_partida INTEGER,
episodio INTEGER,
mapa TEXT,
duración INTEGER,
fecha_inicio DATE,
fecha_fin DATE,
kills INTEGER,
muertes INTEGER,
asistencias INTEGER,
puntuación INTEGER,
primary key (id_partida,episodio),
FOREIGN KEY (episodio) REFERENCES Temporada(episodio)
);


CREATE TABLE Jugadores (
id_jugador INTEGER PRIMARY KEY,
nombre TEXT,
edad INTEGER,
país TEXT,
rol_principal TEXT,
rango TEXT,
puntuación INTEGER,
id_agente INTEGER,
id_partida INTEGER,
id_arma INTEGER,
FOREIGN KEY (id_agente) REFERENCES Agentes(id_agente),
FOREIGN KEY (id_partida) REFERENCES Partidas(id_partida),
FOREIGN KEY (id_arma) REFERENCES Armas(id_arma)
);
