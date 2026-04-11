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

