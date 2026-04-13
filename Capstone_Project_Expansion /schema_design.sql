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

CREATE TABLE dim_date (
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
  date_id            INTEGER NOT NULL REFERENCES dim_date(date_id),
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

/* Now let's create two new tables: 1 dimension table for weather and 1 fact table for maintenance events. 

Why: the business problem mentions "fluctuating revenue" and "overcrowding during peak hours." 
Weather is one of the strongest external drivers of theme park attendance and spending. 
Adding weather data lets the Operations Director understand why certain days are busier, not just that they are. 

Also, the business problem explicitly mentions "inconsistent ride availability due to maintenance issues." But there's no maintenance data in the schema.
Adding this table lets the Operations Director correlate downtime with guest satisfaction drops and revenue loss.*/

CREATE TABLE IF NOT EXISTS dim_weather (
  date_id          INTEGER PRIMARY KEY REFERENCES dim_date(date_id),
  high_temp_f      INTEGER NOT NULL,
  low_temp_f       INTEGER NOT NULL,
  condition_code   TEXT NOT NULL CHECK (condition_code IN (
    'Clear', 'Partly Cloudy', 'Cloudy', 'Rain', 'Storm', 'Overcast'
  )),
  precipitation_in REAL DEFAULT 0,
  humidity_pct     INTEGER CHECK (humidity_pct BETWEEN 0 AND 100)
);

-- insert some sample weather data for testing
INSERT INTO dim_weather VALUES
  (20250701, 88, 72, 'Clear',         0.0,  55),
  (20250702, 91, 74, 'Partly Cloudy', 0.0,  60),
  (20250703, 85, 70, 'Cloudy',        0.1,  72),
  (20250704, 93, 76, 'Clear',         0.0,  58),
  (20250705, 89, 73, 'Partly Cloudy', 0.0,  62),
  (20250706, 78, 68, 'Rain',          0.8,  85),
  (20250707, 82, 69, 'Partly Cloudy', 0.0,  65),
  (20250708, 90, 75, 'Clear',         0.0,  57);


CREATE TABLE IF NOT EXISTS fact_maintenance (
  maintenance_id   INTEGER PRIMARY KEY AUTOINCREMENT,
  attraction_id    INTEGER NOT NULL REFERENCES dim_attraction(attraction_id),
  date_id          INTEGER NOT NULL REFERENCES dim_date(date_id),
  start_time       TEXT NOT NULL,
  end_time         TEXT NOT NULL,
  downtime_minutes INTEGER NOT NULL,
  maintenance_type TEXT NOT NULL CHECK (maintenance_type IN (
    'Scheduled', 'Unscheduled', 'Emergency'
  )),
  description      TEXT
);

-- insert some sample maintenance data for testing
INSERT INTO fact_maintenance (attraction_id, date_id, start_time, end_time, downtime_minutes, maintenance_type, description) VALUES
  (1, 20250701, '08:00', '09:30',  90, 'Scheduled',   'Pre-open safety inspection'),
  (4, 20250702, '14:15', '15:45',  90, 'Unscheduled', 'Hydraulic leak in steering mechanism'),
  (3, 20250703, '11:00', '11:30',  30, 'Scheduled',   'Routine harness check'),
  (8, 20250704, '13:00', '16:00', 180, 'Emergency',   'Pump failure — ride closed for holiday peak'),
  (2, 20250705, '10:00', '10:45',  45, 'Scheduled',   'Water quality testing'),
  (1, 20250706, '12:30', '14:00',  90, 'Unscheduled', 'Sensor malfunction on launch track'),
  (5, 20250707, '09:00', '09:15',  15, 'Scheduled',   'Audio/lighting pre-show check'),
  (4, 20250708, '15:00', '16:30',  90, 'Unscheduled', 'Seatbelt replacement on unit 3');