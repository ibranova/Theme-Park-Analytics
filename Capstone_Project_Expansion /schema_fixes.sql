/* this file is for fixing any schema issues that exist in the database,
such as adding new columns or changing data types and adding constraints between tables */

-- In the dim_attraction table, two attractions appear twice with slight name variations like upper or lower case and character differences.
-- To fix this, we can standardize the names by converting them in the same format and removing any leading or trailing spaces, so that every attraction is unique. */

-- first, let's check the attractions that appear more than once in the dim_attraction table:
SELECT attraction_id, attraction_name, category, min_height_cm, opened_date
FROM dim_attraction
ORDER BY LOWER(attraction_name);

/* we can see that there are two attractions with the same name 
but different cases and characters: "Roller Coaster" and "roller coaster".*/


/* Now, let's remap ride events from duplicate IDs to canonical IDs */

UPDATE fact_ride_events
SET attraction_id = 1
WHERE attraction_id = 6;

UPDATE fact_ride_events
SET attraction_id = 2
WHERE attraction_id = 7;

SELECT COUNT(*) AS orphaned_rides_to_6
FROM fact_ride_events WHERE attraction_id = 6;

SELECT COUNT(*) AS orphaned_rides_to_7
FROM fact_ride_events WHERE attraction_id = 7;

/* Now let's remove the duplicate attractions and update the attraction names to be in a consistent format,
 such as all title case and trimmed of any leading or trailing spaces. */

DELETE FROM dim_attraction WHERE attraction_id IN (6, 7);

UPDATE dim_attraction
SET attraction_name = TRIM(attraction_name);

update dim_attraction
set attraction_name = 'Pirate Splash'
where attraction_id = 2;

-- Verification of the changes made to the dim_attraction table:
SELECT * FROM dim_attraction ORDER BY attraction_id;

/* After removing the duplicate attraction, I noticed I have a gap in the attraction_id sequence,
so I will update the remaining attraction_id to fill the gap and maintain a continuous sequence. */
update fact_ride_events
set attraction_id = 6
where attraction_id = 8;

/* Now let's update the attraction_id in the dim_attraction table to fill the gap as well. */
update dim_attraction
set attraction_id = 6
where attraction_id = 8;