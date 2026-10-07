-- =====================================================================
--                             QUERIES
-- =====================================================================

-- Tables available in the database
SHOW TABLES;

-- First 10 rows in the trips table
SELECT *
FROM trips
LIMIT 10;

-- First 10 rows in the drivers table
SELECT *
FROM drivers
LIMIT 10;

-- First 10 rows in the customers table
SELECT *
FROM customers
LIMIT 10;


-- Q1: Total  rows in the trip table
SELECT
  COUNT(*) AS total_trips_covered
FROM trips;

-- Q2: 5 longest trips completed 
SELECT
  trip_id, 
  city, 
  distance_km,
  fare
FROM trips
WHERE status = 'Completed'
ORDER BY distance_km DESC
LIMIT 5;

-- Q3: Trips by City
SELECT
  city,
  COUNT(*) AS total_trips
FROM trips
GROUP BY city
ORDER BY total_trips DESC;

/* OBSERVATION: Several cities were grouped multiple times due to data-entry
inconsistencies. Lagos and Accra had trailing spaces, while Nairobi and 
Kampala had spelling errors. Port Harcourt appeared in three different 
forms: Port Harcourt, Port-Harcourt, and PH. These inconsistencies caused
the same cities to be counted separately and should be cleaned before analysis.*/

-- Q4a: Duplicate trips
SELECT
  customer_id,
  driver_id,
  trip_date,
  fare,
  MIN(trip_id) AS trip_id_1,
  MAX(trip_id) AS trip_id_2
FROM trips
GROUP BY
  customer_id,
  driver_id,
  trip_date,
  fare
HAVING COUNT(*) > 1;

-- Q4a: Total Completed trips with a missing fare
SELECT
  COUNT(*) AS Total_trips_completed_with_missing_fare
FROM trips
WHERE status = 'Completed' 
AND fare IS NULL;

  
-- Q5:  Fix the data anomalies

-- Remove trailing spaces
UPDATE trips
SET city = TRIM(city);

-- Correct the spelling
UPDATE trips
SET city = 'Nairobi'
WHERE city = 'Nairobbi';

UPDATE trips
SET city = 'Kampala'
WHERE city = 'Kampla';

UPDATE trips
SET city = 'Port Harcourt'
WHERE city = 'Port-Harcourt';

UPDATE trips
SET city = 'Port Harcourt'
WHERE city = 'PH';

-- Remove Duplicate
DELETE FROM trips
WHERE trip_id IN (299, 300);
  
-- Confirming of Trips by City table after data cleaning
SELECT 
  city,
  COUNT(*) AS total_trips
FROM trips
GROUP BY city
ORDER BY total_trips DESC;

-- Q6: Revenue by City
SELECT
  city,
  COUNT(*) AS total_trips,
  SUM(fare) AS revenue,
  ROUND(AVG(fare), 2) AS average_fare
FROM trips
WHERE status = 'Completed'
AND fare IS NOT NULL
GROUP BY city
ORDER BY revenue DESC;

-- Q7:  Revenue by Month
SELECT
  DATE_FORMAT(trip_date, '%Y-%M') AS month,
  COUNT(*) AS total_trips,
  SUM(fare) AS revenue
FROM trips
WHERE status = 'Completed'
GROUP BY month
ORDER BY revenue DESC;

-- December 2025 has the highest revenue with a total of NGN 66,980.00
 

-- Q8: Revenue by Vehicle Type
SELECT
  d.vehicle_type,
  COUNT(*) AS total_trips,
  SUM(t.fare) AS revenue
FROM trips t
INNER JOIN drivers d
  ON t.driver_id = d.driver_id
WHERE t.status = 'Completed'
GROUP BY d.vehicle_type
ORDER BY revenue DESC;


-- Bonus questions (extra marks)

-- Q9: customers who have never booked a trip
SELECT
  c.customer_id,
  c.customer_name,
  c.home_city,
  c.signup_date
FROM customers c
LEFT JOIN trips t
  ON c.customer_id = t.customer_id
WHERE trip_id IS NULL;

-- Q10: top 3 customers by total spent
SELECT
  c.customer_name,
  COUNT(*) AS total_trips,
  SUM(t.fare) AS total_spent
FROM trips t
INNER JOIN customers c
  ON t.customer_id = c.customer_id
WHERE status = 'Completed'
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 3;

-- Exploring Vehicle_type preference by city
SELECT
  t.city,
  d.vehicle_type,
  COUNT(*) AS total_trips
FROM trips t
INNER JOIN drivers d
  ON t.driver_id = d.driver_id
GROUP BY t.city, d.vehicle_type
ORDER BY t.city, total_trips DESC;

/* Message to the manager
ZoomRide should invest in Lagos, which generated the highest revenue at 
₦218,890 from 91 completed trips, compared with Accra’s ₦92,640 from 33 trips.
I found 9 completed trips with missing fares and 2 confirmed duplicate trips;
if left unfixed, these could distort fare calculations and inflate trip counts
and revenue. 
Before making a major investment decision, I would like to know
whether Lagos’s higher demand is sustainable and what is driving it—more 
customers, higher trip frequency, or stronger demand for particular vehicle 
types. This would help determine whether Lagos offers the strongest long-term 
growth opportunity. */
