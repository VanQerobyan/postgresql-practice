-- ==================================================
-- TASK 1 — ATOMICITY
-- ==================================================

CREATE DATABASE acid_assignment;

\c acid_assignment;


CREATE TABLE events (
    event_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    total_seats INTEGER NOT NULL CHECK(total_seats > 0),
    seats_available INTEGER NOT NULL CHECK(seats_available >= 0)
);


CREATE TABLE bookings (
    booking_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES events(event_id),
    customer_name TEXT NOT NULL,
    seats INTEGER NOT NULL CHECK(seats > 0),
    booked_at TIMESTAMPTZ NOT NULL DEFAULT(now())
);


INSERT INTO events (name, total_seats, seats_available)
VALUES ('Backend Workshop', 20, 20),
       ('DB Night', 5, 1);


SELECT * FROM events;

        --  event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         1 | Backend Workshop |          20 |              20
        --         2 | DB Night         |           5 |               1


INSERT INTO bookings (event_id, customer_name, seats)
VALUES (2, 'Ana', 3),
       (2, 'Ben', 1);


SELECT * FROM bookings;

        --  booking_id | event_id | customer_name | seats |           booked_at
        -- ------------+----------+---------------+-------+-------------------------------
        --           1 |        2 | Ana           |     3 | 2026-10-09 13:22:17.531158+04
        --           2 |        2 | Ben           |     1 | 2026-10-09 13:22:17.531158+04


-- Step 1: Successful transaction

BEGIN;
UPDATE events
SET seats_available = seats_available - 2
WHERE event_id = 1;

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (1, 'Carla', 2);

COMMIT;


SELECT * FROM events;

        -- event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         2 | DB Night         |           5 |               1
        --         1 | Backend Workshop |          20 |              18


SELECT * FROM bookings;

        --  booking_id | event_id | customer_name | seats |           booked_at
        -- ------------+----------+---------------+-------+-------------------------------
        --           1 |        2 | Ana           |     3 | 2026-10-09 13:22:17.531158+04
        --           2 |        2 | Ben           |     1 | 2026-10-09 13:22:17.531158+04
        --           3 |        1 | Carla         |     2 | 2026-10-09 13:27:34.708075+04


-- Step 2: Failed transaction and rollback

BEGIN;

UPDATE events
SET seats_available = seats_available - 2
WHERE event_id = 1;

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (1, NULL, 2);

SELECT * FROM bookings;

ROLLBACK;


SELECT * FROM events;

        --  event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         2 | DB Night         |           5 |               1
        --         1 | Backend Workshop |          20 |              18


-- Step 3: Same operation without BEGIN

UPDATE events
SET seats_available = seats_available - 2
WHERE event_id = 1;

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (1, NULL, 2);


        -- ERROR:
        -- null value in column "customer_name" of relation "bookings"
        -- violates not-null constraint


SELECT * FROM events;

        --  event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         2 | DB Night         |           5 |               1
        --         1 | Backend Workshop |          20 |              16


-- Repair data manually

UPDATE events
SET seats_available = 18
WHERE event_id = 1;


    -- Step 2-ում `UPDATE` հրամանը սկզբում հաջողվեց բայց այն կատարվում էր transaction-ի ներսում։
    -- Երբ հաջորդ `INSERT` հրամանը ձախողվեց `NULL customer_name`-ի պատճառով transaction-ը ձախողվեց 
    -- և `ROLLBACK`-ը չեղարկեց նաև նախորդ `UPDATE`-ի փոփոխությունը։ Այդ պատճառով `seats_available` 
    -- արժեքը մնաց անփոփոխ։


-- ==================================================
-- TASK 2 — CONSISTENCY
-- ==================================================

-- Step 1: Violate seats_available constraint

UPDATE events
SET seats_available = seats_available - 5
WHERE event_id = 2;

        -- ERROR:
        -- new row for relation "events" violates check constraint
        -- "events_seats_available_check"

        -- DETAIL:
        -- Failing row contains (2, DB Night, 5, -4).


-- Step 2: Insert a booking with seats = 0

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (1, 'Bob', 0);

        -- ERROR:
        -- new row for relation "bookings" violates check constraint
        -- "bookings_seats_check"

        -- DETAIL:
        -- Failing row contains (8, 1, Bob, 0, 2026-10-09 14:05:20.836607+04).


-- Step 3: Check the invariant

SELECT e.name, e.total_seats, e.seats_available + COALESCE(SUM(b.seats), 0) AS seats
FROM events AS e
LEFT JOIN bookings AS b
ON e.event_id = b.event_id
GROUP BY (e.name, e.total_seats, e.seats_available);


-- ==================================================
-- TASK 3 — ISOLATION
-- ==================================================

-- --------------------------------------------------
-- TASK 3a — NO DIRTY READS
-- --------------------------------------------------

-- SESSION A

BEGIN;

UPDATE events
SET seats_available = seats_available - 1
WHERE event_id = 1;


-- SESSION B

SELECT * FROM events;

        --  event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         2 | DB Night         |           5 |               1
        --         1 | Backend Workshop |          20 |              18


-- SESSION A

COMMIT;


-- SESSION B

SELECT * FROM events;

        --  event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         2 | DB Night         |           5 |               1
        --         1 | Backend Workshop |          20 |              17


        -- Session B-ն առաջին SELECT-ի ժամանակ տեսավ 18, որովհետև Session A-ի փոփոխությունը դեռ commit չէր եղել
        -- և PostgreSQL-ը չցուցադրեց uncommitted փոփոխությունը։Session A-ի `COMMIT`-ից հետո Session B-ի հաջորդ 
        -- SELECT-ը արդեն տեսավ նոր `17` արժեքը։Սա ցույց է տալիս որ dirty read տեղի չունեցավ։


-- --------------------------------------------------
-- TASK 3b — NON-REPEATABLE READS
-- --------------------------------------------------

-- SESSION B — READ COMMITTED

BEGIN;

SELECT seats_available
FROM events
WHERE event_id = 1;

        -- First read:
        -- seats_available
        -- ----------------
        --              17


-- SESSION A

BEGIN;

UPDATE events
SET seats_available = seats_available - 1
WHERE event_id = 1;

COMMIT;


-- SESSION B

SELECT seats_available
FROM events
WHERE event_id = 1;

        -- Second read:
        -- seats_available
        -- ----------------
        --              16

COMMIT;


-- SESSION B — REPEATABLE READ

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT seats_available
FROM events
WHERE event_id = 1;

        -- First read:
        -- seats_available
        -- ----------------
        --              16


-- SESSION A

BEGIN;

UPDATE events
SET seats_available = seats_available - 1
WHERE event_id = 1;

COMMIT;


-- SESSION B

SELECT seats_available
FROM events
WHERE event_id = 1;

        -- Second read:
        -- seats_available
        -- ----------------
        --              16

COMMIT;


-- --------------------------------------------------
-- TASK 3c — LAST-SEAT RACE
-- --------------------------------------------------

-- SESSION B

BEGIN;

SELECT seats_available
FROM events
WHERE event_id = 2;

        -- seats_available
        -- ----------------
        --                1


-- SESSION A

BEGIN;

SELECT seats_available
FROM events
WHERE event_id = 2;

        -- seats_available
        -- ----------------
        --                1


-- SESSION A

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (2, 'Dana', 1);

UPDATE events
SET seats_available = 0
WHERE event_id = 2;

COMMIT;


-- SESSION B

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (2, 'Eli', 1);

UPDATE events
SET seats_available = 0
WHERE event_id = 2;

COMMIT;


-- Check the invariant after the race

SELECT e.name, e.total_seats, e.seats_available + COALESCE(SUM(b.seats), 0) AS seats
FROM events AS e
LEFT JOIN bookings AS b
ON e.event_id = b.event_id
GROUP BY (e.name, e.total_seats, e.seats_available);

        --        name       | total_seats | seats
        -- ------------------+-------------+-------
        --  Backend Workshop |          20 |    17
        --  DB Night         |           5 |     6


-- Reset DB Night after the race

DELETE FROM bookings WHERE booking_id = 9;
DELETE FROM bookings WHERE booking_id = 10;

UPDATE events
SET seats_available = 1
WHERE event_id = 2;


SELECT * FROM events;

        --  event_id |       name       | total_seats | seats_available
        -- ----------+------------------+-------------+-----------------
        --         1 | Backend Workshop |          20 |              15
        --         2 | DB Night         |           5 |               1


-- Check the invariant after resetting the data

SELECT e.name, e.total_seats, e.seats_available + COALESCE(SUM(b.seats), 0) AS seats
FROM events AS e
LEFT JOIN bookings AS b
ON e.event_id = b.event_id
GROUP BY (e.name, e.total_seats, e.seats_available);


-- Repeat with SELECT FOR UPDATE

-- SESSION A

BEGIN;

SELECT seats_available
FROM events
WHERE event_id = 2
FOR UPDATE;

        -- seats_available
        -- ----------------
        --                1


-- SESSION B

BEGIN;

SELECT seats_available
FROM events
WHERE event_id = 2
FOR UPDATE;


-- SESSION A

INSERT INTO bookings (event_id, customer_name, seats)
VALUES (2, 'Dana', 1);

UPDATE events
SET seats_available = 0
WHERE event_id = 2;

COMMIT;


-- SESSION B

-- After Session A commits, Session B sees:

        -- seats_available
        -- ----------------
        --                0

ROLLBACK;


-- ==================================================
-- TASK 4 — DURABILITY
-- ==================================================

BEGIN;
INSERT INTO bookings (event_id, customer_name, seats) VALUES (1,'Farah', 1);
COMMIT;

SELECT * FROM bookings;

        --  booking_id | event_id | customer_name | seats |           booked_at           
        -- ------------+----------+---------------+-------+-------------------------------
        --           1 |        2 | Ana           |     3 | 2026-10-09 13:22:17.531158+04
        --           2 |        2 | Ben           |     1 | 2026-10-09 13:22:17.531158+04
        --           3 |        1 | Carla         |     2 | 2026-10-09 13:27:34.708075+04
        --          11 |        2 | Dana          |     1 | 2026-10-09 15:37:26.161084+04
        --          12 |        1 | Farah         |     1 | 2026-10-13 11:16:36.489278+04



SHOW fsync;
        --  fsync 
        -- -------
        --  on
        

SHOW synchronous_commit;
        --  synchronous_commit 
        -- --------------------
        --  on
    

 show checkpoint_timeout;
        --  checkpoint_timeout 
        -- --------------------
        --  5min

-- \q

sudo systemctl restart postgresql
sudo -u postgres psql 

\c acid_assignment 

SELECT * FROM bookings;

        --  booking_id | event_id | customer_name | seats |           booked_at           
        -- ------------+----------+---------------+-------+-------------------------------
        --           1 |        2 | Ana           |     3 | 2026-10-09 13:22:17.531158+04
        --           2 |        2 | Ben           |     1 | 2026-10-09 13:22:17.531158+04
        --           3 |        1 | Carla         |     2 | 2026-10-09 13:27:34.708075+04
        --          11 |        2 | Dana          |     1 | 2026-10-09 15:37:26.161084+04
        --          12 |        1 | Farah         |     1 | 2026-10-13 11:16:36.489278+04


        -- Write-Ahead Log-ի (WAL) դերը կայանում է նրանում որ տվյալների փոփոխությունների մասին տեղեկությունը նախ գրանցվում է WAL-ում
        -- իսկ հետո տվյալները կարող են գրվել հիմնական database files-ում։Դրա շնորհիվ crash-ի դեպքում PostgreSQL-ը կարող է WAL-ի միջոցով
        -- վերականգնել commit եղած փոփոխությունները։

-- ==================================================
-- Task 5 - Synthesis 
-- ==================================================

        -- |     Property    |                       Task and step where I saw it                                      |                       What would have gone wrong without it                                       |

        -- | **Atomicity**   | Task 1, Step 2-ում failed `INSERT`-ից հետո `ROLLBACK`-ը չեղարկեց նաև նախորդ `UPDATE`-ը։ | Առանց atomicity-ի `seats_available`-ը կարող էր նվազել բայց booking-ը չստեղծվել։                   |
        -- | **Consistency** | Task 2, Steps 1 և 2-ում `CHECK` constraints-ը կանխեցին invalid արժեքների պահպանումը։    | Առանց constraints-ի database-ում կարող էին պահպանվելբացասական seats կամ `seats = 0` booking       |
        -- | **Isolation**   | Task 3c-ում `SELECT ... FOR UPDATE`-ը ստիպեց Session B-ին սպասել Session A-ին։          | Առանց locking-ի երկու session-ներն էլ կարող էին վաճառել նույն վերջին seat-ը և ստեղծել overbooking |
        -- | **Durability**  | Task 4-ում Farah-ի booking-ը `COMMIT`-ից և server restart-ից հետո պահպանվեց։            | Առանց durability-ի commit եղած տվյալը կարող էր crash-ից կամ restart-ից հետո կորել։                |