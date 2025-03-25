CREATE TABLE cartas (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    pokedex_number INTEGER,
    supertype VARCHAR(255),
    subtypes VARCHAR(255),
    hp INTEGER,
    types VARCHAR(255),
    attacks VARCHAR(255),
    weaknesses VARCHAR(255),
    retreat_cost VARCHAR(255),
    set_name VARCHAR(255),
    release_date DATE,
    artist VARCHAR(255),
    rarity VARCHAR(255),
    card_image_small VARCHAR(255),
    card_image_hires VARCHAR(255),
    tcg_player_url VARCHAR(255)
);

CREATE TABLE precios (
    id SERIAL PRIMARY KEY,
    carta_id INTEGER REFERENCES cartas(id),
    precio DECIMAL,
    tipo_precio VARCHAR(50),
    fecha DATE
);

