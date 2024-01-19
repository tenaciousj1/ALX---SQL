SHOW TABLES; -- To get a list of all the tables in the database.

SELECT * FROM location limit 6;
SELECT * FROM visits LIMIT 5;
SELECT * FROM water_source LIMIT 5;
SELECT DISTINCT type_of_water_source FROM water_source; -- to find all the unique types of water sources.

SELECT * FROM visits WHERE time_in_queue > 500;-- Records from this table where the time_in_queue is more 500 mins.
SELECT * FROM water_source WHERE source_id IN ('AkRu05234224', 'HaZa21742224' );

SELECT * FROM water_quality WHERE subjective_quality_score = 10 AND visit_count = 2; 
-- Error visits made to sources that are clean (subjective_quality_score = 10)
    

SELECT * FROM well_pollution; -- Investigating pollution issues
SELECT * FROM well_pollution WHERE results = 'Clean' AND biological > 0.01;
SELECT * FROM well_pollution WHERE description LIKE 'Clean%'AND biological > 0.01 LIMIT 40;
/*
Looking at the results we can see two different descriptions that we need to fix:
1. All records that mistakenly have 'Clean Bacteria: E. coli' should updated to 'Bacteria: E. coli'
2. All records that mistakenly have 'Clean Bacteria: Giardia Lamblia' should updated to 'Bacteria: Giardia 
Lamblia'

The second issue we need to fix is in our results column. We need to update the results column from 
'Clean' to 'Contaminated: Biological' where the biological column has a value greater than 0.01.

Now, when we change any data on the database, we need to be SURE there are no errors, as this could fill the database with incorrect
values. A safer way to do the UPDATE is by testing the changes on a copy of the table first.

The CREATE TABLE new_table AS (query) approach is a neat trick that allows you to create a new table from the results set of a query.
This method is especially useful for creating backup tables or subsets without the need for a separate CREATE TABLE and INSERT INTO
statement.
*/
CREATE TABLE md_water_services.well_pollution_copy 
AS (SELECT * FROM md_water_services.well_pollution);

SET SQL_SAFE_UPDATES=0; -- Disable safe update mode, to allow updates or deletes

UPDATE well_pollution_copy SET description = 'Bacteria: E. coli' 
WHERE description = 'Clean Bacteria: E. coli'; 

UPDATE well_pollution_copy SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy SET results = 'Contaminated: Biological' 
WHERE biological > 0.01 AND results = 'Clean';

SELECT * FROM well_pollution_copy WHERE description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

UPDATE well_pollution SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution SET results = 'Contaminated: Biological' 
WHERE biological > 0.01 AND results = 'Clean';

SET SQL_SAFE_UPDATES=1; -- enable safe update mode