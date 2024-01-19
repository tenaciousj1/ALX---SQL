SELECT * FROM employee LIMIT 10;

/*
The employee table has info on all the workers, but note that the email addresses have not been added. 
Luckily the emails for our department are easy: first_name.last_name@ndogowater.gov.
We can determine the email address for each employee by:
- selecting the employee_name column
- replacing the space with a full stop
- make it lowercase
- and stitch it all together
*/

/* We have to update the database again with these email addresses, so before we do, let's use a SELECT query 
to get the format right, then use UPDATE and SET to make the changes. */


-- Replace the space with a full stop and make it all lower case
SELECT
CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email
FROM employee LIMIT 5;

 UPDATE employee SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');


/*Employees with the highest number of records*/
SELECT assigned_employee_id, COUNT(visit_count) as number_of_visits
FROM md_water_services.visits
GROUP BY assigned_employee_id ORDER BY number_of_visits DESC LIMIT 3;

/*Getting the names of the employees with the highest record*/
SELECT employee_name, email, phone_number
FROM employee WHERE assigned_employee_id IN (1,30,34);

/*Records per town to get insights on the regions with the bulk of water crisis*/
SELECT COUNT(*) as records_per_town, town_name
FROM md_water_serviceso.location
GROUP BY town_name ORDER BY records_per_town DESC;

/*Province view of water crisis*/
SELECT COUNT(*) as records_per_province, province_name
FROM md_water_serviceso.location GROUP BY province_name ORDER BY records_per_province DESC;

/*Over view on the status of water crisis in the provinces of maji ndogo*/
SELECT province_name, town_name, COUNT(*) AS record_per_town
FROM location GROUP BY province_name, town_name ORDER BY province_name, record_per_town DESC;

/*Water crisis based on location_type*/
SELECT location_type, COUNT(*) AS num_sources
FROM location GROUP BY location_type;

/*Population of maji Ndogo*/
SELECT SUM(number_of_people_served) AS total_population
FROM water_source;

/*Number of water source in maji ndogo*/
SELECT type_of_water_source, COUNT(type_of_water_source) as number_of_water_source
FROM water_source
GROUP BY type_of_water_source ORDER BY number_of_water_source DESC;
    
/*average number of people served by each water source*/
SELECT type_of_water_source, ROUND(AVG(number_of_people_served),0) as avg_num_of_people
FROM water_source GROUP BY type_of_water_source;
    
/*total number of people served by each water source*/
SELECT type_of_water_source, SUM(number_of_people_served) AS total_num_of_people
FROM water_source GROUP BY type_of_water_source ORDER BY total_num_of_people DESC;
    
/*percentage number of people served by each water source*/
SELECT type_of_water_source,
	ROUND((SUM(number_of_people_served) / 
        -- A subquery that gets the total number of people in Maji Ndogo
		(SELECT SUM(number_of_people_served) 
		FROM water_source))*100, 0) percent_of_people_served
FROM water_source GROUP BY type_of_water_source ORDER BY percent_of_people_served DESC;


/*total number of people served by each water source.
This query gives insight to which water source serve for the most people and 
should be given priority*/
SELECT type_of_water_source, SUM(number_of_people_served) AS total_num_of_people,
RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS most_used_source
FROM water_source WHERE type_of_water_source <> "tap_in_home"
GROUP BY type_of_water_source;


/*Using the windows rank function to show areas of priority. The query drills down to each water source.
The query gives engineers insight into which water sources to be repaired first (prioritize). For example:
which of the rivers, well or shared_taps to be repaired first, this will be the ones that serve more people. */
SELECT source_id, type_of_water_source, number_of_people_served,
RANK() OVER (PARTITION BY type_of_water_source
ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source WHERE type_of_water_source <> "tap_in_home";


/*How long the survey took*/
SELECT 
	MAX(DATE(time_of_record)) start_date,
    MIN(DATE(time_of_record)) end_date,
    DATEDIFF(MAX(DATE(time_of_record)), MIN(DATE(time_of_record))) survey_period
FROM visits;


/*Average time in queue to get water*/
SELECT
	ROUND(AVG(time_in_queue),0) avg_time_in_queue
FROM
	visits
-- Excluding time in queue for value = 0
WHERE
	NULLIF(time_in_queue, 0);


/*Average time in queue per day of the week to get water.
The query shows the busiest day to get water in maji ndogo*/
SELECT
	DAYNAME(time_of_record) Days_of_the_week,
    ROUND(AVG(time_in_queue),0) avg_time_in_queue_per_day
FROM
	visits
-- Excluding time in queue for value = 0
WHERE
	NULLIF(time_in_queue, 0)
GROUP BY
	Days_of_the_week
    
ORDER BY 
	avg_time_in_queue_per_day DESC;


/*Average time in queue per hour of day to get water.
The query gives insight on the busiest time to get water in maji ndogo*/
SELECT
	TIME_FORMAT(TIME(time_of_record), "%H:00") Hour_of_the_day,
    ROUND(AVG(time_in_queue),0) avg_time_per_hour_of_day
FROM
	visits
-- Excluding time in queue for value = 0
WHERE
	NULLIF(time_in_queue, 0)
GROUP BY
	Hour_of_the_day
ORDER BY
	avg_time_per_hour_of_day DESC;


/*Average time in queue per hour of day to get water.
This query creates a pivot table using case statement on the average time in queue in hours per day of the week.
This is done in order to give insights into busiest days of the week and drill down into hours of the day*/
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
ROUND(AVG(
CASE
		WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
		ELSE NULL
END),0) AS Sunday,

ROUND(AVG(
CASE
	WHEN DAYNAME(time_of_record) = "Monday" THEN time_in_queue
    ELSE NULL
END), 0) AS Monday,

ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = "Tuesday" THEN time_in_queue
        ELSE NULL
END),0) AS Tuesday,

ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = "Wednesday" THEN time_in_queue
        ELSE NULL
END),0) AS Wednesday,

ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = "Thursday" THEN time_in_queue
        ELSE NULL
END),0) AS Thursday,

ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = "Friday" THEN time_in_queue
        ELSE NULL
END),0) AS Friday,

ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = "Saturday" THEN time_in_queue
        ELSE NULL
END),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;