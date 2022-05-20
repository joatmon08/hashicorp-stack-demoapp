set time zone 'UTC';
create extension pgcrypto;

CREATE TABLE coffees (
    id serial PRIMARY KEY,
    name VARCHAR (255) NOT NULL UNIQUE,
    teaser VARCHAR(255) NULL,
    collection VARCHAR(255) NULL,
    origin VARCHAR(255) NULL,
    color VARCHAR(7) NULL,
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
INSERT INTO ingredients (id, name, created_at, updated_at) VALUES (6, 'Coffee', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('HCP Aeropress', 'Automation in a cup', 'Foundations', 'Summer 2020', '#444', '', 200, '/hashicorp.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (1,6, 350, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Packer Spiced Latte', 'Packed with goodness to spice up your images', 'Origins', 'Summer 2013', '#1FA7EE', '', 350, '/packer.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (2,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (2,2, 300, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (2,4, 5, 'g', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Vaulatte', 'Nothing gives you a safe and secure feeling like a Vaulatte', 'Foundations', 'Spring 2015', '#FFD814', '', 200, '/vault.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (3,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (3,2, 300, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Nomadicano', 'Drink one today and you will want to schedule another',  'Foundations', 'Fall 2015', '#00CA8E', '', 150, '/nomad.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (4,1, 20, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (4,3, 100, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Terraspresso', 'Nothing kickstarts your day like a provision of Terraspresso', 'Origins', 'Summer 2014', '#894BD1', '', 150, '/terraform.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (5,1, 20, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Vagrante espresso', 'Stdin is not a tty', 'Origins', '2010', '#0E67ED', '', 200, '/vagrant.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (6,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Connectaccino', 'Discover the wonders of our meshy service', 'Origins', 'Spring 2014', '#F44D8A', '', 250, '/consul.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (7,1, 40, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (7,5, 300, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Boundary Red Eye', 'Perk up and watch out for your access management', 'Discoveries', 'Fall 2020', '#F24C53', '', 200, '/boundary.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (8,1, 30, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (8,6, 120, 'ml', CURRENT_DATE, CURRENT_DATE);

INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ('Waypointiato', 'Deploy with a little foam', 'Discoveries', 'Fall 2020', '#14C6CB', '', 250, '/waypoint.png', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (9,1, 60, 'ml', CURRENT_DATE, CURRENT_DATE);
INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES (9,2, 30, 'ml', CURRENT_DATE, CURRENT_DATE);