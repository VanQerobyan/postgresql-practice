-- TASK 1
-- PostgreSQL Constraints: PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT

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
