-- =========================
-- Task 1 - Simple Integer ID
-- =========================

CREATE DATABASE postgresql_practice2_db;

\c postgresql_practice2_db;

CREATE TABLE categories (
category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
category_name TEXT 
);

\d categories;

        --                            Table "public.categories"
        --     Column     |  Type   | Collation | Nullable |           Default            
        -- ---------------+---------+-----------+----------+------------------------------
        --  category_id   | integer |           | not null | generated always as identity
        --  category_name | text    |           |          | 
        -- Indexes:
        --     "categories_pkey" PRIMARY KEY, btree (category_id)


INSERT INTO categories (category_name)
VALUES ('Electronics'),
('Furniture'),
('Stationery'),
('Books'),
('Toys');

SELECT * FROM categories ORDER BY  category_id asc;

        --  category_id | category_name 
        -- -------------+---------------
        --            1 | Electronics
        --            2 | Furniture
        --            3 | Stationery
        --            4 | Books
        --            5 | Toys

UPDATE categories SET category_name = 'Toys & Games' where category_name = 'Toys'; 

SELECT * FROM categories;

        --  category_id | category_name 
        -- -------------+---------------
        --            1 | Electronics
        --            2 | Furniture
        --            3 | Stationery
        --            4 | Books
        --            5 | Toys & Games

INSERT INTO categories (category_name) VALUES ('Test');

DELETE FROM categories WHERE category_name = 'Test';

SELECT * FROM categories;

        --  category_id | category_name 
        -- -------------+---------------
        --            1 | Electronics
        --            2 | Furniture
        --            3 | Stationery
        --            4 | Books
        --            5 | Toys & Games


-- =========================
-- Task 2 - Adding Constraints
-- =========================

ALTER TABLE categories ALTER COLUMN  category_name SET NOT NULL;

ALTER TABLE categories ADD CONSTRAINT category_name_ SET UNIQUE(category_name);

ALTER TABLE categories ADD CONSTRAINT category_name_check  CHECK(length(category_name) >= 3);
       
ALTER TABLE categories ADD COLUMN description text;

ALTER TABLE categories ADD COLUMN is_active boolean NOT NULL DEFAULT(true);

        --                         Table "public.categories"
        --     Column     |  Type   | Collation | Nullable |           Default            
        -- ---------------+---------+-----------+----------+------------------------------
        --  category_id   | integer |           | not null | generated always as identity
        --  category_name | text    |           | not null | 
        --  description   | text    |           |          | 
        --  is_active     | boolean |           | not null | true
        -- Indexes:
        --     "categories_pkey" PRIMARY KEY, btree (category_id)
        --     "set" UNIQUE CONSTRAINT, btree (category_name)
        -- Check constraints:
        --     "category_name_check" CHECK (length(category_name) >= 3)


INSERT INTO categories (category_name) VALUES ('Electronics');

        -- ERROR:  duplicate key value violates unique constraint "set"
        -- DETAIL:  Key (category_name)=(Electronics) already exists.

INSERT INTO categories (category_name) VALUES ('TV');

        -- ERROR:  new row for relation "categories" violates check constraint "category_name_check"
        -- DETAIL:  Failing row contains (9, TV, null, t).

INSERT INTO categories (category_name) VALUES (NULL);

        --  ERROR:  null value in column "category_name" of relation "categories" violates not-null constraint
        -- DETAIL:  Failing row contains (10, null, null, t).


INSERT INTO categories (category_name, description) VALUES ('Sport', 'Some description');

        --  category_id | category_name |   description    | is_active 
        -- -------------+---------------+------------------+-----------
        --            1 | Electronics   |                  | t
        --            2 | Furniture     |                  | t
        --            3 | Stationery    |                  | t
        --            4 | Books         |                  | t
        --            5 | Toys & Games  |                  | t
        --           11 | Sport         | Some description | t

-- =========================
-- Task 3 - Joining Two Tables
-- =========================

CREATE TABLE products (
 product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
 product_name TEXT NOT NULL,
 price NUMERIC(8,2) NOT NULL CHECK(price > 0),
 category_id INTEGER,
 stock_quantity INTEGER NOT NULL DEFAULT(0) 
);

\d products

        --                               Table "public.products"
        --      Column     |     Type     | Collation | Nullable |           Default            
        -- ----------------+--------------+-----------+----------+------------------------------
        --  product_id     | integer      |           | not null | generated always as identity
        --  product_name   | text         |           | not null | 
        --  price          | numeric(8,2) |           | not null | 
        --  category_id    | integer      |           |          | 
        --  stock_quantity | integer      |           | not null | 0
        -- Indexes:
        --     "products_pkey" PRIMARY KEY, btree (product_id)
        -- Check constraints:
        --     "products_price_check" CHECK (price > 0::numeric)
   

CREATE TABLE orders (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    order_date DATE NOT NULL DEFAULT(now())
);

\d orders

        --                                  Table "public.orders"
        --    Column   |  Type   | Collation | Nullable |           Default            
        -- ------------+---------+-----------+----------+------------------------------
        --  order_id   | integer |           | not null | generated always as identity
        --  product_id | integer |           |          | 
        --  quantity   | integer |           | not null | 
        --  order_date | date    |           | not null | now()
        -- Indexes:
        --     "orders_pkey" PRIMARY KEY, btree (order_id)
        -- Check constraints:
        --     "orders_quantity_check" CHECK (quantity > 0)


INSERT INTO products (product_name, price, category_id, stock_quantity)
VALUES ('Wireless Mouse', 19.99, 1, 150),
('Mechanical Keyboard', 49.99, 1, 80),
('Standing Desk', 249.00, 2, 30),
('Office Chair', 129.50, 2, 45),
('Notebook Pack', 4.99, 3, 300),
('Gel Pens', 6.50, 3, 220),
('PostgreSQL Handbook', 39.00, 4, 60),
('SQL Cookbook', 34.00, 4, 40),
('Building Blocks', 24.99, 5, 60),
('Desk Lamp', 15.50, NULL, 0);

SELECT * FROM products;

        --  product_id |    product_name     | price  | category_id | stock_quantity 
        -- ------------+---------------------+--------+-------------+----------------
        --           1 | Wireless Mouse      |  19.99 |           1 |            150
        --           2 | Mechanical Keyboard |  49.99 |           1 |             80
        --           3 | Standing Desk       | 249.00 |           2 |             30
        --           4 | Office Chair        | 129.50 |           2 |             45
        --           5 | Notebook Pack       |   4.99 |           3 |            300
        --           6 | Gel Pens            |   6.50 |           3 |            220
        --           7 | PostgreSQL Handbook |  39.00 |           4 |             60
        --           8 | SQL Cookbook        |  34.00 |           4 |             40
        --           9 | Building Blocks     |  24.99 |           5 |             60
        --          10 | Desk Lamp           |  15.50 |             |              0


INSERT INTO orders (product_id, quantity, order_date)
VALUES (1, 2, '2026-01-05'),
(1, 1, '2026-01-12'),
(2, 1, '2026-01-12'),
(3, 1, '2026-01-20'),
(4, 2, '2026-01-22'),
(5, 5, '2026-02-01'),
(6, 3, '2026-02-01'),
(7, 1, '2026-02-10'),
(1, 3, '2026-02-15'),
(6, 2, '2026-02-18');

SELECT * FROM orders;

        --  order_id | product_id | quantity | order_date 
        -- ----------+------------+----------+------------
        --         1 |          1 |        2 | 2026-01-05
        --         2 |          1 |        1 | 2026-01-12
        --         3 |          2 |        1 | 2026-01-12
        --         4 |          3 |        1 | 2026-01-20
        --         5 |          4 |        2 | 2026-01-22
        --         6 |          5 |        5 | 2026-02-01
        --         7 |          6 |        3 | 2026-02-01
        --         8 |          7 |        1 | 2026-02-10
        --         9 |          1 |        3 | 2026-02-15
        --        10 |          6 |        2 | 2026-02-18


SELECT p.product_name, p.price, c.category_name 
FROM products AS p
INNER JOIN categories As c 
ON p.category_id = c.category_id;

        --            product_name     | price  | category_name 
        -- ---------------------+--------+---------------
        --  Wireless Mouse      |  19.99 | Electronics
        --  Mechanical Keyboard |  49.99 | Electronics
        --  Standing Desk       | 249.00 | Furniture
        --  Office Chair        | 129.50 | Furniture
        --  Notebook Pack       |   4.99 | Stationery
        --  Gel Pens            |   6.50 | Stationery
        --  PostgreSQL Handbook |  39.00 | Books
        --  SQL Cookbook        |  34.00 | Books
        --  Building Blocks     |  24.99 | Toys & Games

SELECT p.product_name, p.price, c.category_name
FROM products AS p 
LEFT JOIN categories AS c 
ON p.category_id = c.category_id;

        --     product_name     | price  | category_name 
        -- ---------------------+--------+---------------
        --  Wireless Mouse      |  19.99 | Electronics
        --  Mechanical Keyboard |  49.99 | Electronics
        --  Standing Desk       | 249.00 | Furniture
        --  Office Chair        | 129.50 | Furniture
        --  Notebook Pack       |   4.99 | Stationery
        --  Gel Pens            |   6.50 | Stationery
        --  PostgreSQL Handbook |  39.00 | Books
        --  SQL Cookbook        |  34.00 | Books
        --  Building Blocks     |  24.99 | Toys & Games
        --  Desk Lamp           |  15.50 | 


SELECT p.product_name, p.price, p.stock_quantity, o.quantity
FROM products AS p 
LEFT JOIN orders AS o 
On p.product_id = o.product_id;

        --     product_name     | price  | stock_quantity | quantity 
        -- ---------------------+--------+----------------+----------
        --  Wireless Mouse      |  19.99 |            150 |        2
        --  Wireless Mouse      |  19.99 |            150 |        1
        --  Mechanical Keyboard |  49.99 |             80 |        1
        --  Standing Desk       | 249.00 |             30 |        1
        --  Office Chair        | 129.50 |             45 |        2
        --  Notebook Pack       |   4.99 |            300 |        5
        --  Gel Pens            |   6.50 |            220 |        3
        --  PostgreSQL Handbook |  39.00 |             60 |        1
        --  Wireless Mouse      |  19.99 |            150 |        3
        --  Gel Pens            |   6.50 |            220 |        2
        --  Desk Lamp           |  15.50 |              0 |         
        --  SQL Cookbook        |  34.00 |             40 |         
        --  Building Blocks     |  24.99 |             60 |         
        

-- =========================
-- Task 4 - Aggregation
-- =========================

SELECT COUNT(*) FROM products;
        --  count
        -- -------
        --     10

SELECT COUNT(product_name) FROM products WHERE category_id=1;
        --  count 
        -- -------
        --      2

SELECT AVG(price) FROM products;
        --          avg         
        -- ---------------------
        --  57.3460000000000000

SELECT AVG(price) FROM products WHERE category_id=1;

        --          avg         
        -- ---------------------
        --  34.9900000000000000

SELECT  category_id, SUM(stock_quantity) FROM products GROUP BY(category_id);

        --  category_id | sum 
        -- -------------+-----
        --              |   0
        --            3 | 520
        --            5 |  60
        --            4 | 100
        --            2 |  75
        --            1 | 230

SELECT category_id, AVG(stock_quantity) FROM products GROUP BY(category_id);

        --  category_id |          avg           
        -- -------------+------------------------
        --              | 0.00000000000000000000
        --            3 |   260.0000000000000000
        --            5 |    60.0000000000000000
        --            4 |    50.0000000000000000
        --            2 |    37.5000000000000000
        --            1 |   115.0000000000000000


SELECT category_id, SUM(stock_quantity) FROM products GROUP BY(category_id) HAVING SUM(stock_quantity) >= 100;

        --  category_id | sum 
        -- -------------+-----
        --            3 | 520
        --            4 | 100
        --            1 | 230

SELECT category_id, AVG(stock_quantity) FROM products GROUP BY(category_id) HAVING AVG(stock_quantity) >= 50.00;

        --  category_id |         avg          
        -- -------------+----------------------
        --            3 | 260.0000000000000000
        --            5 |  60.0000000000000000
        --            4 |  50.0000000000000000
        --            1 | 115.0000000000000000

SELECT product_id, COUNT(*) FROM orders GROUP BY(product_id) ORDER BY(product_id) desc;

        --  product_id | count 
        -- ------------+-------
        --           7 |     1
        --           6 |     2
        --           5 |     1
        --           4 |     1
        --           3 |     1
        --           2 |     1
        --           1 |     3

SELECT product_id, SUM(quantity) FROM orders GROUP BY(product_id) ORDER BY(SUM) desc;

        --  product_id | sum 
        -- ------------+-----
        --           1 |   6
        --           5 |   5
        --           6 |   5
        --           4 |   2
        --           3 |   1
        --           2 |   1
        --           7 |   1


-- =========================
-- Task 5 - JOIN + Aggregation
-- =========================

SELECT category_name, SUM(quantity * price)
FROM  products 
INNER JOIN categories
ON products.category_id = categories.category_id
INNER JOIN orders
ON products.product_id = orders.product_id GROUP BY(category_name);

        --  category_name |  sum   
        -- ---------------+--------
        --  Furniture     | 508.00
        --  Electronics   | 169.93
        --  Books         |  39.00
        --  Stationery    |  57.45

SELECT product_name, COUNT(quantity) 
FROM products 
LEFT JOIN orders
ON products.product_id = orders.product_id
GROUP BY(product_name) ORDER BY(COUNT);

        --    product_name     | count 
        -- ---------------------+-------
        --  Building Blocks     |     0
        --  SQL Cookbook        |     0
        --  Desk Lamp           |     0
        --  Standing Desk       |     1
        --  Mechanical Keyboard |     1
        --  Notebook Pack       |     1
        --  PostgreSQL Handbook |     1
        --  Office Chair        |     1
        --  Gel Pens            |     2
        --  Wireless Mouse      |     3

SELECT category_id, SUM(price * quantity) 
FROM products 
INNER JOIN orders
ON products.product_id = orders.product_id
GROUP BY(category_id) HAVING(SUM(price * quantity)) > 100;

        --  category_id |  sum   
        -- -------------+--------
        --            2 | 508.00
        --            1 | 169.93


-- =========================
-- Task 6 - Foreign Keys
-- =========================

ALTER TABLE products ADD CONSTRAINT category_id_ref FOREIGN KEY(category_id) REFERENCES categories(category_id);

        --      Column     |     Type     | Collation | Nullable |           Default            
        -- ----------------+--------------+-----------+----------+------------------------------
        --  product_id     | integer      |           | not null | generated always as identity
        --  product_name   | text         |           | not null | 
        --  price          | numeric(8,2) |           | not null | 
        --  category_id    | integer      |           |          | 
        --  stock_quantity | integer      |           | not null | 0
        -- Indexes:
        --     "products_pkey" PRIMARY KEY, btree (product_id)
        -- Check constraints:
        --     "products_price_check" CHECK (price > 0::numeric)
        -- Foreign-key constraints:
        --     "category_id_ref" FOREIGN KEY (category_id) REFERENCES categories(category_id)


ALTER TABLE orders ADD CONSTRAINT product_id_ref FOREIGN KEY(product_id) REFERENCES products(product_id);

        --                           Table "public.orders"
        --    Column   |  Type   | Collation | Nullable |           Default            
        -- ------------+---------+-----------+----------+------------------------------
        --  order_id   | integer |           | not null | generated always as identity
        --  product_id | integer |           |          | 
        --  quantity   | integer |           | not null | 
        --  order_date | date    |           | not null | now()
        -- Indexes:
        --     "orders_pkey" PRIMARY KEY, btree (order_id)
        -- Check constraints:
        --     "orders_quantity_check" CHECK (quantity > 0)
        -- Foreign-key constraints:
        --     "product_id_ref" FOREIGN KEY (product_id) REFERENCES products(product_id)


INSERT INTO products (product_name, price, category_id, stock_quantity) 
VALUES('Classic Denim Jacket', 79.99, 999, 15);

        --  ERROR:  insert or update on table "products" violates foreign key constraint "category_id_ref"
        -- DETAIL:  Key (category_id)=(999) is not present in table "categories"

DELETE FROM categories WHERE category_name = 'Electronics';

        --  ERROR:  update or delete on table "categories" violates foreign key constraint "category_id_ref" on table "products"
        -- DETAIL:  Key (category_id)=(1) is still referenced from table "products".

-- INSERT INTO products (product_name, price, category_id, stock_quantity) 
-- VALUES('Classic Denim Jacket', 79.99, 44, 10);

--Սկզբում products աղյուսակում կարող էր հայտնվել ապրանք որի category_id֊ն գոյություն չուներ categories-ում, 
-- FOREIGN KEY constraint-ի ավելացումից հետո նման ապրանքի ավելացումը մերժվում է։

