create table Cartas (
    id serial primary key NOT NULL,
    nombre varchar(250) NOT NULL,
    tipo varchar(250) NOT NULL,
    rareza varchar(250) NOT NULL
);

create table Precio (
    id serial primary key NOT NULL,
    carta_id int references Cartas(id) NOT NULL,
    precio float NOT NULL,
    fecha date NOT NULL
);

