-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Setup Template
-- DESCRIPTION: Pseudo-DDL Template for Table Creation & Data Insertion
-- INSTRUCTIONS: Replace 'TYPE' and the constraint placeholders with your own
--               actual data types, relational keys, and check criteria.
-- =========================================================================

-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
    user_id      INT             NOT NULL,
    full_name    VARCHAR(100)    NOT NULL,
    email        VARCHAR(150)    NOT NULL,
    role         VARCHAR(50)     NOT NULL,
    phone_number VARCHAR(20),

    -- Primary Key constraint on user_id
    CONSTRAINT pk_users PRIMARY KEY (user_id),

    -- Email must be unique across all users
    CONSTRAINT uq_users_email UNIQUE (email),

    -- Role is restricted to exactly two allowed values
    CONSTRAINT chk_users_role CHECK (role IN ('Ticket Manager', 'Football Fan'))
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
    match_id             INT             NOT NULL,
    fixture              VARCHAR(150)    NOT NULL,
    tournament_category  VARCHAR(100)    NOT NULL,
    base_ticket_price    NUMERIC(10, 2)  NOT NULL,
    match_status         VARCHAR(50)     NOT NULL,

    -- Primary Key constraint on match_id
    CONSTRAINT pk_matches PRIMARY KEY (match_id),

    -- Ticket price must be zero or positive (no negative prices)
    CONSTRAINT chk_matches_price CHECK (base_ticket_price >= 0),

    -- match_status is restricted to four allowed operational states
    CONSTRAINT chk_matches_status CHECK (
        match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed')
    )
);

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
    booking_id     INT             NOT NULL,
    user_id        INT,
    match_id       INT,
    seat_number    VARCHAR(20),
    payment_status VARCHAR(50),
    total_cost     NUMERIC(10, 2)  NOT NULL,

    -- Primary Key constraint on booking_id
    CONSTRAINT pk_bookings PRIMARY KEY (booking_id),

    -- Foreign Key: links each booking to a valid user
    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    -- Foreign Key: links each booking to a valid match
    CONSTRAINT fk_bookings_match
        FOREIGN KEY (match_id) REFERENCES Matches (match_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    -- Total cost must be zero or positive
    CONSTRAINT chk_bookings_cost CHECK (total_cost >= 0),

    -- payment_status is restricted to four allowed financial states
    CONSTRAINT chk_bookings_payment CHECK (
        payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
    )
);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);


-- =========================================================================
-- SOLUTION SQL QUERIES
-- =========================================================================

-- -------------------------------------------------------------------------
-- Query 1: Retrieve all Champions League matches where status is 'Available'
-- -------------------------------------------------------------------------
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM Matches
WHERE tournament_category = 'Champions League'
  AND match_status        = 'Available';


-- -------------------------------------------------------------------------
-- Query 2: Users whose name starts with 'Tanvir' OR contains 'Haque'
--          (case-insensitive using ILIKE for PostgreSQL)
-- -------------------------------------------------------------------------
SELECT
    user_id,
    full_name,
    email
FROM Users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';

-- -------------------------------------------------------------------------
-- Query 3: Bookings where payment_status IS NULL;
--          replace NULL with 'Action Required' using COALESCE
-- -------------------------------------------------------------------------
SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM Bookings
WHERE payment_status IS NULL;


-- -------------------------------------------------------------------------
-- Query 4: Booking details with the user's full name and match fixture
--          Concepts: INNER JOIN
-- -------------------------------------------------------------------------
SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM Bookings b
INNER JOIN Users   u ON b.user_id   = u.user_id
INNER JOIN Matches m ON b.match_id  = m.match_id;

-- -------------------------------------------------------------------------
-- Query 5: All users and their booking IDs, including fans with NO bookings
--          Concepts: LEFT JOIN / Full JOIN
-- -------------------------------------------------------------------------
SELECT
    u.user_id,
    u.full_name,
    b.booking_id
FROM Users u
LEFT JOIN Bookings b ON u.user_id = b.user_id
ORDER BY u.user_id, b.booking_id;