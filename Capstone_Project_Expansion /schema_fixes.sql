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
