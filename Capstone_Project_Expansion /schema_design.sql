/* This file is for creating a proper schema desing for my database with Foreing keys 
because there are not foreign key constraint defined in any table before.
Instead of editing the existing table, I will write and document the DDL fron scratch directly in this file. */

-- First, let's create all the dimension tables with their primary keys and necessary columns (No FK dependency between dimension tables):
CREATE TABLE dim_guest (
  guest_id              INTEGER PRIMARY KEY,
  first_name            TEXT NOT NULL,
  last_name             TEXT NOT NULL,
  email                 TEXT,
  birthdate             TEXT,
  home_state            TEXT,
  marketing_opt_in INTEGER CHECK (marketing_opt_in IN (0, 1))
);

CREATE TABLE dim_ticket (
  ticket_type_id   INTEGER PRIMARY KEY,
  ticket_type_name TEXT NOT NULL,
  base_price_cents INTEGER NOT NULL,
  restrictions     TEXT
);

CREATE TABLE dim_attraction (
  attraction_id    INTEGER PRIMARY KEY,
  attraction_name  TEXT NOT NULL UNIQUE,  -- UNIQUE prevents future duplicates
  category         TEXT NOT NULL,
  min_height_cm    INTEGER DEFAULT 0,
  opened_date      TEXT
);

CREATE TABLE dim_date_ (
  date_id    INTEGER PRIMARY KEY,
  date_iso   TEXT NOT NULL UNIQUE,
  day_name   TEXT NOT NULL,
  is_weekend INTEGER NOT NULL CHECK (is_weekend IN (0, 1)),
  season     TEXT NOT NULL
);

-- Now, let's create the fact table with foreign key constraints referencing the dimension tables:
CREATE TABLE fact_visits(
  visit_id           INTEGER PRIMARY KEY,
  guest_id           INTEGER NOT NULL REFERENCES dim_guest(guest_id),
  ticket_type_id     INTEGER NOT NULL REFERENCES dim_ticket(ticket_type_id),
  date_id            INTEGER NOT NULL REFERENCES dim_date_(date_id),
  visit_date         TEXT NOT NULL,
  party_size         INTEGER,
  entry_time         TEXT NOT NULL,
  exit_time          TEXT NOT NULL,
  spend_cents_clean  INTEGER,
  promotion_code_norm TEXT
);

CREATE TABLE fact_ride_events (
  ride_event_id       INTEGER PRIMARY KEY,
  visit_id            INTEGER NOT NULL REFERENCES fact_visits(visit_id),
  attraction_id       INTEGER NOT NULL REFERENCES dim_attraction(attraction_id),
  ride_time           TEXT NOT NULL,
  wait_minutes        INTEGER CHECK (wait_minutes >= 0 OR wait_minutes IS NULL),
  satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
  photo_purchase      TEXT CHECK (photo_purchase IN ('Y', 'N') OR photo_purchase IS NULL)
);

CREATE TABLE fact_purchases (
  purchase_id        INTEGER PRIMARY KEY,
  visit_id           INTEGER NOT NULL REFERENCES fact_visits(visit_id),
  category           TEXT NOT NULL CHECK (category IN ('Food', 'Merch')),
  item_name          TEXT NOT NULL,
  amount_cents       INTEGER CHECK (amount_cents > 0),
  payment_method     TEXT
);

/* Summary of the schema design:
1. Created dimension tables: dim_guest, dim_ticket, dim_attraction, and dim_date_ with appropriate columns and primary keys. The attraction_name in dim_attraction is set to UNIQUE to prevent future duplicates.
2. Created fact tables: fact_visits, fact_ride_events, and fact_purchases with foreign key constraints referencing the dimension tables to ensure referential integrity.
3. Added necessary constraints such as CHECK constraints to ensure data quality and consistency across the tables. 
4. This schema design allows for efficient querying and analysis of the theme park data while maintaining data integrity through the use of foreign keys and constraints. */