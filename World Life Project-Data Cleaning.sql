# World Life Expectancy (Data Cleaning) -- ** ALWAYS HAVE A DUPLICATE BACK-UP TABLE THAT YOU WORK WITH TO CLEAN DATA, SO THAT YOU HAVE THE ORIGINAL TO REFER TO INCASE OF MISTAKES

SELECT * 
FROM world_life_expectancy.worldlifexpectancy;

-- Identifying/Removing Duplicates
-- Identifying Duplicates

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy.worldlifexpectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

-- Identify Row_ID of the Duplicates

SELECT *
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy.worldlifexpectancy
    ) AS Row_Table
WHERE Row_Num > 1
;

-- Removing Duplicates

DELETE FROM world_life_expectancy.worldlifexpectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy.worldlifexpectancy
    ) AS Row_Table
WHERE Row_Num > 1
)
;

-- Identifying/Working with Missing or NULL Values

SELECT *
FROM world_life_expectancy.worldlifexpectancy
WHERE Status = ''
;

SELECT DISTINCT(Status)
FROM world_life_expectancy.worldlifexpectancy
WHERE Status <> ''
;

SELECT DISTINCT(Country) -- Here we identified which countries have the status of 'developing'
FROM world_life_expectancy.worldlifexpectancy
WHERE Status = 'Developing'
;

UPDATE world_life_expectancy.worldlifexpectancy -- Filling missing values from the 'Status' column with 'Developing'
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
			FROM world_life_expectancy.worldlifexpectancy
			WHERE Status = 'Developing')
;

UPDATE world_life_expectancy.worldlifexpectancy t1 -- joining the table to itself (self join) to filter the missing values and fill with the 'developing' status
JOIN world_life_expectancy.worldlifexpectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

-- Now fill missing values with status of 'developed'

SELECT *
FROM world_life_expectancy.worldlifexpectancy
WHERE Country = 'United States of America'
;

UPDATE world_life_expectancy.worldlifexpectancy t1
JOIN world_life_expectancy.worldlifexpectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

-- Double Checking for NULL Values in Status Column

SELECT *
FROM world_life_expectancy.worldlifexpectancy
WHERE Status IS NULL
;

-- Missing/NULL Values in Life Expectancy Column

SELECT *
FROM world_life_expectancy.worldlifexpectancy
WHERE Lifeexpectancy = ''
;

SELECT Country, Year, Lifeexpectancy
FROM world_life_expectancy.worldlifexpectancy
;

 -- Attempting to use a self-join to fill the missing value with an average life expectancy
 
 SELECT t1.Country, t1.Year, t1.Lifeexpectancy, 
 t2.Country, t2.Year, t2.Lifeexpectancy,
 t3.Country, t3.Year, t3.Lifeexpectancy,
 ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2, 1)
FROM world_life_expectancy.worldlifexpectancy t1
JOIN world_life_expectancy.worldlifexpectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy.worldlifexpectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.Lifeexpectancy = ''
;

UPDATE world_life_expectancy.worldlifexpectancy t1
JOIN world_life_expectancy.worldlifexpectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy.worldlifexpectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.Lifeexpectancy = ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2, 1)
WHERE t1.Lifeexpectancy = ''
;

SELECT * 
FROM world_life_expectancy.worldlifexpectancy;