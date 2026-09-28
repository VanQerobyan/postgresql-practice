-- =========================
-- PART A
-- =========================

CREATE DATABASE joins_aggregation_db;

\c joins_aggregation_db;

CREATE TABLE authors (
    author_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    bio TEXT
);

\d authors

    --                           Table "public.authors"
    --   Column   |  Type   | Collation | Nullable |           Default            
    -- -----------+---------+-----------+----------+------------------------------
    --  author_id | integer |           | not null | generated always as identity
    --  name      | text    |           | not null | 
    --  bio       | text    |           |          | 
    -- Indexes:
    --     "authors_pkey" PRIMARY KEY, btree (author_id)


CREATE TABLE articles (
    article_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    published_on DATE NOT NULL,
    views INTEGER NOT NULL DEFAULT(0)
);

\d articles

    --                            Table "public.articles"
    --     Column    |  Type   | Collation | Nullable |           Default            
    -- --------------+---------+-----------+----------+------------------------------
    --  article_id   | integer |           | not null | generated always as identity
    --  title        | text    |           | not null | 
    --  author_id    | integer |           |          | 
    --  published_on | date    |           | not null | 
    --  views        | integer |           | not null | 0
    -- Indexes:
    --     "articles_pkey" PRIMARY KEY, btree (article_id)
    -- Foreign-key constraints:
    --     "articles_author_id_fkey" FOREIGN KEY (author_id) REFERENCES authors(author_id)

CREATE TABLE comments (
    comment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    article_id INTEGER REFERENCES articles(article_id),
    commenter_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT(now())
);

\d comments

    --                                    Table "public.comments"
    --      Column     |           Type           | Collation | Nullable |           Default            
    -- ----------------+--------------------------+-----------+----------+------------------------------
    --  comment_id     | integer                  |           | not null | generated always as identity
    --  article_id     | integer                  |           |          | 
    --  commenter_name | text                     |           | not null | 
    --  created_at     | timestamp with time zone |           | not null | now()
    -- Indexes:
    --     "comments_pkey" PRIMARY KEY, btree (comment_id)
    -- Foreign-key constraints:
    --     "comments_article_id_fkey" FOREIGN KEY (article_id) REFERENCES articles(article_id)

INSERT INTO authors (name, bio)
VALUES ('Maria Chen', 'Writes about frontend performance'),
('David Okafor', 'Backend and databases'),
('Sana Malik', 'DevOps and infrastructure'),
('Tom Reyes', 'Career advice for developers');

SELECT * FROM authors;

    --  author_id |     name     |                bio                
    -- -----------+--------------+-----------------------------------
    --          1 | Maria Chen   | Writes about frontend performance
    --          2 | David Okafor | Backend and databases
    --          3 | Sana Malik   | DevOps and infrastructure
    --          4 | Tom Reyes    | Career advice for developers

INSERT INTO articles (title, author_id, published_on, views)
VALUES ('Speeding Up Your CSS', 1, '2026-01-05', 820),
('Lazy Loading Images', 1, '2026-01-20', 410),
('Indexing 101', 2, '2026-01-10', 1500),
('Understanding Joins', 2, '2026-02-01',2100),
('Zero-Downtime Deploys', 3, '2026-01-15',690),
('Docker for Beginners', 3, '2026-02-05', 950),
('Writing a Great Resume', 4, '2026-01-25', 300),
('Acing the Interview', 4, '2026-02-10', 0);


    -- article_id |         title          | author_id | published_on | views 
    -- ------------+------------------------+-----------+--------------+-------
    --           1 | Speeding Up Your CSS   |         1 | 2026-01-05   |   820
    --           2 | Lazy Loading Images    |         1 | 2026-01-20   |   410
    --           3 | Indexing 101           |         2 | 2026-01-10   |  1500
    --           4 | Understanding Joins    |         2 | 2026-02-01   |  2100
    --           5 | Zero-Downtime Deploys  |         3 | 2026-01-15   |   690
    --           6 | Docker for Beginners   |         3 | 2026-02-05   |   950
    --           7 | Writing a Great Resume |         4 | 2026-01-25   |   300
    --           8 | Acing the Interview    |         4 | 2026-02-10   |     0


SELECT * FROM articles;

INSERT INTO comments (article_id, commenter_name)
VALUES (1, 'Alex'),
(1, 'Priya'),
(3, 'Jordan'),
(3, 'Sam'), 
(3, 'Lee'), 
(4, 'Alex'),
(4, 'Priya'),
(4, 'Jordan'),
(4, 'Sam'), 
(5, 'Lee'),
(6, 'Alex'),
(7, 'Priya');

SELECT * FROM comments;


    --  comment_id | article_id | commenter_name |          created_at           
    -- ------------+------------+----------------+-------------------------------
    --           1 |          1 | Alex           | 2026-09-28 11:31:44.506079+04
    --           2 |          1 | Priya          | 2026-09-28 11:31:44.506079+04
    --           3 |          3 | Jordan         | 2026-09-28 11:31:44.506079+04
    --           4 |          3 | Sam            | 2026-09-28 11:31:44.506079+04
    --           5 |          3 | Lee            | 2026-09-28 11:31:44.506079+04
    --           6 |          4 | Alex           | 2026-09-28 11:31:44.506079+04
    --           7 |          4 | Priya          | 2026-09-28 11:31:44.506079+04
    --           8 |          4 | Jordan         | 2026-09-28 11:31:44.506079+04
    --           9 |          4 | Sam            | 2026-09-28 11:31:44.506079+04
    --          10 |          5 | Lee            | 2026-09-28 11:31:44.506079+04
    --          11 |          6 | Alex           | 2026-09-28 11:31:44.506079+04
    --          12 |          7 | Priya          | 2026-09-28 11:31:44.506079+04


-- =========================
-- Task 1 - Join Articles to Authors and Comments
-- =========================

SELECT articles.title, articles.views, authors.name
FROM articles
INNER JOIN authors
ON articles.author_id = authors.author_id;

    --          title          | views |     name     
    -- ------------------------+-------+--------------
    --  Speeding Up Your CSS   |   820 | Maria Chen
    --  Lazy Loading Images    |   410 | Maria Chen
    --  Indexing 101           |  1500 | David Okafor
    --  Understanding Joins    |  2100 | David Okafor
    --  Zero-Downtime Deploys  |   690 | Sana Malik
    --  Docker for Beginners   |   950 | Sana Malik
    --  Writing a Great Resume |   300 | Tom Reyes
    --  Acing the Interview    |     0 | Tom Reyes


SELECT a.title, c.commenter_name 
FROM articles AS a
LEFT JOIN comments AS c 
ON a.article_id = c.article_id;

    --          title          | commenter_name 
    -- ------------------------+----------------
    --  Speeding Up Your CSS   | Alex
    --  Speeding Up Your CSS   | Priya
    --  Indexing 101           | Jordan
    --  Indexing 101           | Sam
    --  Indexing 101           | Lee
    --  Understanding Joins    | Alex
    --  Understanding Joins    | Priya
    --  Understanding Joins    | Jordan
    --  Understanding Joins    | Sam
    --  Zero-Downtime Deploys  | Lee
    --  Docker for Beginners   | Alex
    --  Writing a Great Resume | Priya
    --  Acing the Interview    | 
    --  Lazy Loading Images    | 

INSERT INTO authors(name) VALUES('Joe Doe');

SELECT  authors.name, articles.title
FROM authors
LEFT JOIN articles
ON articles.author_id = authors.author_id;


    --      name     |         title          
    -- --------------+------------------------
    --  Maria Chen   | Speeding Up Your CSS
    --  Maria Chen   | Lazy Loading Images
    --  David Okafor | Indexing 101
    --  David Okafor | Understanding Joins
    --  Sana Malik   | Zero-Downtime Deploys
    --  Sana Malik   | Docker for Beginners
    --  Tom Reyes    | Writing a Great Resume
    --  Tom Reyes    | Acing the Interview
    --  Joe Doe      | 

DELETE from authors WHERE authors.name = 'Joe Doe';


-- =========================
-- Task 2 - Aggregate Views and Comments
-- =========================

SELECT authors.name, SUM(views)
FROM authors 
LEFT JOIN articles 
ON authors.author_id = articles.author_id
GROUP BY name
ORDER BY SUM desc;

    --          name     | sum  
    -- --------------+------
    --  David Okafor | 3600
    --  Sana Malik   | 1640
    --  Maria Chen   | 1230
    --  Tom Reyes    |  300

SELECT authors.name, SUM(views)
FROM authors 
INNER JOIN articles 
ON authors.author_id = articles.author_id
GROUP BY name HAVING SUM(views) > 1000;

    --      name     | sum  
    -- --------------+------
    --  Sana Malik   | 1640
    --  Maria Chen   | 1230
    --  David Okafor | 3600


SELECT title, COUNT(commenter_name)
FROM articles 
LEFT JOIN comments 
ON articles.article_id = comments.article_id
GROUP BY title
ORDER BY COUNT(commenter_name) desc;

    --          title          | count 
    -- ------------------------+-------
    --  Understanding Joins    |     4
    --  Indexing 101           |     3
    --  Speeding Up Your CSS   |     2
    --  Writing a Great Resume |     1
    --  Docker for Beginners   |     1
    --  Zero-Downtime Deploys  |     1
    --  Lazy Loading Images    |     0
    --  Acing the Interview    |     0


SELECT title, COUNT(commenter_name)
FROM articles
LEFT JOIN comments
ON articles.article_id = comments.article_id
GROUP BY title
ORDER BY COUNT(commenter_name) desc LIMIT 1;

    --         title        | count 
    -- ---------------------+-------
    --  Understanding Joins |     4


-- ========================= 
-- PART B 
-- =========================

CREATE TABLE writers (
    writer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    country TEXT
    );


CREATE TABLE books (
    book_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    writer_id INTEGER REFERENCES writers(writer_id),
    published_year INTEGER,
    price NUMERIC(6,2) NOT NULL CHECK(price > 0)
);

CREATE TABLE reviews (
    review_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INTEGER REFERENCES books(book_id),
    rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
    review_text TEXT
);


INSERT INTO writers (name, country)
VALUES ('Elena Vasquez', 'Spain'),
('Kenji Watanabe', 'Japan'),
('Grace Okonkwo', 'Nigeria');


INSERT INTO books (title, writer_id, published_year, price)
VALUES('The Long Horizon', 1, '2019', 18.99),
('Small Fires', 1, 2022, 16.50),
('Paper Lanterns', 2, 2018, 14.00),
('The Quiet Station', 2, 2021, 19.50),
('River of Names', 3, 2020, 15.75),
('Unfinished Maps', 3, 2023, 21.00);

INSERT INTO reviews (book_id, rating)
VALUES(1, 5),
(1, 4),
(1, 5),
(2, 3),
(2, 4),
(3, 5),
(3, 5),
(4, 2),
(4, 3),
(5, 4),
(5, 5),
(5, 4);


-- ========================= 
-- Task 3 - Join Books to Writers and Reviews 
-- =========================

SELECT b.title, b.price, w.name
FROM books AS b
INNER JOIN writers AS w 
ON b.writer_id = w.writer_id;

    --        title       | price |      name      
    -- -------------------+-------+----------------
    --  The Long Horizon  | 18.99 | Elena Vasquez
    --  Small Fires       | 16.50 | Elena Vasquez
    --  Paper Lanterns    | 14.00 | Kenji Watanabe
    --  The Quiet Station | 19.50 | Kenji Watanabe
    --  River of Names    | 15.75 | Grace Okonkwo
    --  Unfinished Maps   | 21.00 | Grace Okonkwo

SELECT b.title, r.rating 
FROM books AS b 
LEFT JOIN reviews AS r 
ON b.book_id = r.book_id;

    --        title       | rating 
    -- -------------------+--------
    --  The Long Horizon  |      5
    --  The Long Horizon  |      4
    --  The Long Horizon  |      5
    --  Small Fires       |      3
    --  Small Fires       |      4
    --  Paper Lanterns    |      5
    --  Paper Lanterns    |      5
    --  The Quiet Station |      2
    --  The Quiet Station |      3
    --  River of Names    |      4
    --  River of Names    |      5
    --  River of Names    |      4
    --  Unfinished Maps   |      

INSERT INTO writers (name, country) VALUES ('Leo Tolstoy', 'Russia');

SELECT w.name, COUNT(b.writer_id)
FROM writers AS w 
LEFT JOIN books AS b 
ON w.writer_id = b.writer_id
GROUP BY(w.name) ORDER BY COUNT(b.writer_id) desc;

    --       name      | count 
    -- ----------------+-------
    --  Grace Okonkwo  |     2
    --  Elena Vasquez  |     2
    --  Kenji Watanabe |     2
    --  Leo Tolstoy    |     0


-- ========================= 
-- Task 4 - Aggregate Ratings per Book
-- =========================

SELECT b.title, AVG(r.rating), COUNT(r.review_id)
FROM books AS b 
LEFT JOIN reviews AS r 
ON b.book_id = r.book_id
GROUP BY(b.title);

    --         title       |        avg         | count 
    -- -------------------+--------------------+-------
    --  River of Names    | 4.3333333333333333 |     3
    --  The Quiet Station | 2.5000000000000000 |     2
    --  The Long Horizon  | 4.6666666666666667 |     3
    --  Unfinished Maps   |                    |     0
    --  Small Fires       | 3.5000000000000000 |     2
    --  Paper Lanterns    | 5.0000000000000000 |     2

SELECT b.title, AVG(r.rating)
FROM books AS b 
INNER JOIN reviews AS r 
ON b.book_id = r.book_id
GROUP BY(b.title) HAVING AVG(r.rating) >= 4 
ORDER BY AVG desc;

    --       title       |        avg         
    -- ------------------+--------------------
    --  Paper Lanterns   | 5.0000000000000000
    --  The Long Horizon | 4.6666666666666667
    --  River of Names   | 4.3333333333333333


SELECT b.title, COUNT(r.book_id)
FROM books AS b 
LEFT JOIN reviews AS r 
ON b.book_id = r.book_id
GROUP BY(b.title) HAVING COUNT(r.book_id) >= 2;

    --        title       | count 
    -- -------------------+-------
    --  River of Names    |     3
    --  The Quiet Station |     2
    --  The Long Horizon  |     3
    --  Small Fires       |     2
    --  Paper Lanterns    |     2


-- ========================= 
-- Task 5 — Aggregate Ratings per Writer
-- =========================

SELECT w.name, AVG(r.rating)
FROM writers AS w 
LEFT JOIN books AS b 
ON w.writer_id = b.writer_id
LEFT JOIN reviews AS r 
ON b.book_id = r.book_id
GROUP BY (w.name);

    --       name      |        avg
    -- ----------------+--------------------
    --  Grace Okonkwo  | 4.3333333333333333
    --  Elena Vasquez  | 4.2000000000000000
    --  Kenji Watanabe | 3.7500000000000000

SELECT w.name, AVG(r.rating)
FROM writers AS w 
INNER JOIN books AS b 
ON w.writer_id = b.writer_id
INNER JOIN reviews AS r 
ON b.book_id = r.book_id
GROUP BY(w.name) HAVING AVG(r.rating) > 4;

    --      name      |        avg         
    -- ---------------+--------------------
    --  Grace Okonkwo | 4.3333333333333333
    --  Elena Vasquez | 4.2000000000000000


-- Ձեր խոսքերով՝ ինչո՞ւ է սրա համար անհրաժեշտ միավորել երեք աղյուսակ, մինչդեռ 4-րդ առաջադրանքի դեպքում պահանջվում էր ընդամենը երկուսը։

--Այս դեպքերում անհրաժեշտ է օգտագործել երեք աղյուսակ քանի որ writers աղյուսակը կապված է books աղյուսակի հետ, իսկ reviews-ը կապված է books աղյուսակի հետ;


-- ========================= 
-- Task 6 — Cross-Domain Leaderboard
-- =========================

SELECT name, SUM(articles.views) 
FROM authors
LEFT JOIN articles
ON authors.author_id = articles.author_id
GROUP BY(name) 
ORDER BY SUM(articles.views) desc LIMIT 1;

    --      name     | sum  
    -- --------------+------
    --  David Okafor | 3600


SELECT b.title, AVG(r.rating), COUNT(r.review_id)
FROM books AS b 
INNER JOIN reviews AS r 
ON b.book_id = r.book_id
GROUP BY(b.title) HAVING COUNT(r.review_id) >= 2
ORDER BY AVG(r.rating) desc LIMIT 1;

    --       title       |        avg         | count 
    -- ------------------+--------------------+-------
    --  The Long Horizon | 4.6666666666666667 |     3