set time zone 'UTC';
create extension pgcrypto;

CREATE TABLE coffees (
    id serial PRIMARY KEY,
    name VARCHAR (255) NOT NULL UNIQUE,
    teaser VARCHAR(255) NULL,
    description TEXT NULL,
    price INT NOT NULL,
    image TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);
CREATE TABLE ingredients (
    id serial PRIMARY KEY,
    name VARCHAR (255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);
CREATE TABLE coffee_ingredients (
    id serial PRIMARY KEY,
    coffee_id int references coffees(id),
    ingredient_id int references ingredients(id),
    quantity int NOT NULL,
    unit VARCHAR (50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    CONSTRAINT unique_coffee_ingredient UNIQUE (coffee_id,ingredient_id)
);
CREATE TABLE users (
    id serial PRIMARY KEY,
    username VARCHAR (255) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);
CREATE TABLE tokens (
    id serial PRIMARY KEY,
    user_id int references users(id),
    created_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);
CREATE TABLE orders (
    id serial PRIMARY KEY,
    user_id int references users(id),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);
CREATE TABLE order_items (
    id serial PRIMARY KEY,
    order_id int references orders(id),
    coffee_id int references coffees(id),
    quantity int NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);


INSERT INTO ingredients (id, name, created_at, updated_at) VALUES (1, 'Espresso', CURRENT_DATE, CURRENT_DATE);
INSERT INTO ingredients (id, name, created_at, updated_at) VALUES (2, 'Semi Skimmed Milk', CURRENT_DATE, CURRENT_DATE);
INSERT INTO ingredients (id, name, created_at, updated_at) VALUES (3, 'Hot Water', CURRENT_DATE, CURRENT_DATE);
INSERT INTO ingredients (id, name, created_at, updated_at) VALUES (4, 'Pumpkin Spice', CURRENT_DATE, CURRENT_DATE);
INSERT INTO ingredients (id, name, created_at, updated_at) VALUES (5, 'Steamed Milk', CURRENT_DATE, CURRENT_DATE);


INSERT INTO coffees (name, teaser, description, price, image, created_at, updated_at) VALUES ('Packer Spiced Latte', 'Packed with goodness to spice up your images', '', 350, '/packer.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (1,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (1,2, 300, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (1,4, 5, 'g', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, description, price, image, created_at, updated_at) VALUES ('Vaulatte', 'Nothing gives you a safe and secure feeling like a Vaulatte', '', 200, '/vault.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (2,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (2,2, 300, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, description, price, image, created_at, updated_at) VALUES ('Nomadicano', 'Drink one today and you will want to schedule another', '', 150, '/nomad.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (3,1, 20, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (3,3, 100, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, description, price, image, created_at, updated_at) VALUES ('Terraspresso', 'Nothing kickstarts your day like a provision of Terraspresso', '', 150, '/terraform.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (4,1, 20, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, description, price, image, created_at, updated_at) VALUES ('Vagrante espresso', 'Stdin is not a tty', '', 200, '/vagrant.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (5,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, description, price, image, created_at, updated_at) VALUES ('Connectaccino', 'Discover the wonders of our meshy service', '', 250, '/consul.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (6,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (6,5, 300, 'ml', CURRENT_DATE, CURRENT_DATE);