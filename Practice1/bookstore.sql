-- ============================================
-- TASK 1
-- PostgreSQL Constraints:
-- PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT
-- ============================================

CREATE DATABASE bookstore_db;
\c bookstore_db

CREATE TABLE authors (
author_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
full_name TEXT NOT NULL,
email TEXT NOT NULL UNIQUE,
country VARCHAR(50) DEFAULT 'Unknown',
joined_at TIMESTAMPTZ NOT NULL DEFAULT now() 
);

-- Check table structure

\d authors

        --                                    Table "public.authors"
        --   Column   |           Type           | Collation | Nullable |           Default            
        -- -----------+--------------------------+-----------+----------+------------------------------
        --  author_id | integer                  |           | not null | generated always as identity
        --  full_name | text                     |           | not null | 
        --  email     | text                     |           | not null | 
        --  country   | character varying(50)    |           |          | 'Unknown'::character varying
        --  joined_at | timestamp with time zone |           | not null | now()
        -- Indexes:
        --     "authors_pkey" PRIMARY KEY, btree (author_id)
        --     "authors_email_key" UNIQUE CONSTRAINT, btree (email)


INSERT INTO authors (full_name, email, country)
VALUES ('George Orwell', 'george.orwell@example.com', 'United Kingdom'),
('Agatha Christie', 'agatha.christie@example.com', 'United Kingdom');

INSERT INTO authors (full_name, email)
VALUES ('Carcia Marquez', 'carcia.marquez@example.com');


-- Check inserted data:

SELECT * FROM authors;

        -- 1 | George Orwell   | george.orwell@example.com   | United Kingdom | 2026-09-22 13:52:35.301314+04
        -- 2 | Agatha Christie | agatha.christie@example.com | United Kingdom | 2026-09-22 13:52:35.301314+04
        -- 3 | Carcia Marquez  | carcia.marquez@example.com  | Unknown        | 2026-09-22 13:54:12.923262+04


-- Test UNIQUE constraint
-- This should fail because the email already exists.

INSERT INTO authors (full_name, email, country)
VALUES ('Leo Tolstoy', 'carcia.marquez@example.com', 'Russia');

        -- ERROR:  duplicate key value violates unique constraint "authors_email_key"
        -- DETAIL:  Key (email)=(carcia.marquez@example.com) already exists.



-- ============================================
-- TASK 2
-- PostgreSQL Constraints:
-- PRIMARY KEY, FOREIGN KEY, NOT NULL, CHECK
-- ============================================

CREATE TABLE books (
book_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
author_id INTEGER NOT NULL REFERENCES authors(author_id),
title TEXT NOT NULL,
price numeric(8, 2) NOT NULL CHECK (price > 0),
pages INTEGER CHECK (pages > 0),
tags TEXT[],
published_on date NOT NULL
);

INSERT INTO books (author_id, title, price, pages, tags, published_on)
VALUES (1,'Animal Farm', 20.15, 400, ARRAY['Classics', 'Fiction Political', 'Satire'], '1945-08-17'),
(2,'Death on the Nile', 24.20, 510, ARRAY['Mystery', 'Crime', 'Detective'], '1937-11-01'),
(1,'Burmese Days', 22.70, 470, ARRAY['Colonialism', 'Racism', 'Imperialism'], '1934-10-25'),
(3,'War and Peace', 20.70, 385, ARRAY['Historical Fiction', 'War', 'Romance'], '1869-07-15'),
(2,'The Murder of Roger Ackroyd', 18.66, 420, ARRAY['Mystery', 'Crime', 'Detective'], '1926-06-18');


-- Test CHECK constraint
-- This should fail because price must be greater than 0.

INSERT INTO books (author_id, title, price, pages, tags, published_on)
VALUES (2, 'The Mysterious Affair at Styles', -22.40, 420, ARRAY['Mystery', 'Crime', 'Detective'], '1924-10-25');

        -- ERROR:  new row for relation "books" violates check constraint "books_price_check"
        -- DETAIL:  Failing row contains (6, 2, The Mysterious Affair at Styles, -22.40, 420, {Mystery,Crime,Detective}, 1924-10-25).


-- Test FOREIGN KEY constraint
-- This should fail because author_id 44 does not exist in authors.        

INSERT INTO books (author_id, title, price, pages, tags, published_on)
VALUES (44, 'The Mysterious Affair at Styles', 22.40, 420, ARRAY['Mystery', 'Crime', 'Detective'], '1924-10-25');

        -- ERROR:  insert or update on table "books" violates foreign key constraint "books_author_id_fkey"
        -- DETAIL:  Key (author_id)=(44) is not present in table "authors".



-- ============================================
-- TASK 3
-- B-tree Index
-- ============================================

CREATE INDEX idx_books_published_on 
ON books USING BTREE(published_on);

EXPLAIN ANALYZE
SELECT * FROM books
WHERE published_on BETWEEN '1925-01-01' AND '1950-01-01';

        -- Seq Scan on books  (cost=0.00..1.07 rows=1 width=94) (actual time=0.012..0.014 rows=4 loops=1)
        -- Filter: ((published_on >= '1925-01-01'::date) AND (published_on <= '1950-01-01'::date))
        -- Rows Removed by Filter: 1
        --  Planning Time: 0.331 ms 
        --  Execution Time: 0.039 ms



-- ============================================
-- TASK 4
-- GIN Index
-- ============================================

CREATE INDEX gin_tags 
ON books USING GIN (tags);

EXPLAIN ANALYZE 
SELECT * FROM books 
WHERE tags @> ARRAY['Mystery'];


        -- EXPLAIN ANALYZE output:

        -- Seq Scan on books  (cost=0.00..1.06 rows=1 width=94) (actual time=0.014..0.017 rows=2 loops=1)     
        --    Filter: (tags @> '{Mystery}'::text[])
        --    Rows Removed by Filter: 3
        --  Planning Time: 0.279 ms
        --  Execution Time: 0.034 ms



-- ============================================
-- TASK 5
-- PostgreSQL GiST Index + EXCLUDE Constraint
-- Prevent overlapping book signings for the same author
-- ============================================

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE book_signings (
signing_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
author_id INTEGER NOT NULL REFERENCES authors(author_id), 
store_location TEXT NOT NULL, 
during TSTZRANGE NOT NULL
);

ALTER TABLE  book_signings 
ADD CONSTRAINT no_overlapping_signings
EXCLUDE USING GIST(
        author_id WITH =,
        during WITH &&
);


INSERT INTO book_signings (author_id, store_location, during)
VALUES (1, 'YEREVAN BOOKSTORE', '[2026-10-01 10:00:00+04, 2026-10-05 10:00:00+04]');

INSERT INTO book_signings (author_id, store_location, during)
VALUES (1, 'YEREVAN BOOKSTORE', '[2026-05-05 15:30:00+04, 2026-09-09 10:00:00+04]');

SELECT * FROM book_signings;

        --  1 |         1 | YEREVAN BOOKSTORE | ["2026-10-01 10:00:00+04","2026-10-05 10:00:00+04"]
        --  2 |         1 | YEREVAN BOOKSTORE | ["2026-05-05 15:30:00+04","2026-09-09 10:00:00+04"]


INSERT INTO book_signings (author_id, store_location, during)
VALUES (1,'YEREVAN BOOKSTORE', '[2026-06-15 14:20:00+04, 2026-06-20 10:20:00+04]');

        -- ERROR:  conflicting key value violates exclusion constraint "no_overlapping_signings"
        -- DETAIL:  Key (author_id, during)=(1, ["2026-06-15 14:20:00+04","2026-06-20 10:20:00+04"]) 
        -- conflicts with existing key (author_id, during)=(1, ["2026-05-05 15:30:00+04","2026-09-09 10:00:00+04"]).



-- ============================================
-- TASK 6
-- CHECK Constraint for Secure Website URLs
-- ============================================


ALTER TABLE authors 
ADD COLUMN 
website TEXT;


ALTER TABLE authors
ADD CONSTRAINT website_secure
CHECK (website IS NULL OR website  LIKE 'https://%');

INSERT INTO authors (full_name, email, country, website)
VALUES ('J. K. Rowling', 'jk.rowling@example.com', 'United Kingdom', 'https://www.jkrowling.com');


SELECT * FROM authors;
        --  1 | George Orwell   | george.orwell@example.com   | United Kingdom | 2026-09-22 13:52:35.301314+04 | 
        --  2 | Agatha Christie | agatha.christie@example.com | United Kingdom | 2026-09-22 13:52:35.301314+04 | 
        --  3 | Carcia Marquez  | carcia.marquez@example.com  | Unknown        | 2026-09-22 13:54:12.923262+04 | 
        --  5 | J. K. Rowling   | jk.rowling@example.com      | United Kingdom | 2026-09-22 14:29:51.711314+04 | https://www.jkrowling.com


INSERT INTO authors (full_name, email, country, website) 
VALUES ('Ernest Hemingway', 'ernest.hemingway@example.com', 'United States', 'http://www.ernesthemingway.com/');

        -- ERROR:  new row for relation "authors" violates check constraint "website_secure"
        -- DETAIL:  Failing row contains (6, Ernest Hemingway, ernest.hemingway@example.com, United States, 2026-09-22 14:30:48.35682+04, http://www.ernesthemingway.com/).