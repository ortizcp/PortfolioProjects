# US Household Income Project - Data Cleaning

SELECT * 
FROM us_project.USHouseholdIncome;

SELECT * 
FROM us_project.us_household_income_statistics;

SELECT COUNT(id) 
FROM us_project.USHouseholdIncome;

SELECT COUNT(id) 
FROM us_project.us_household_income_statistics;

-- US Household Income - Identify/Remove Duplicates

SELECT id, COUNT(id)
FROM us_project.USHouseholdIncome
GROUP BY id
HAVING COUNT(id) >1
;

SELECT *
FROM (
SELECT row_id,
id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM us_project.USHouseholdIncome
) duplicates
WHERE row_num > 1
;

DELETE FROM us_project.USHouseholdIncome
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_project.USHouseholdIncome
		) duplicates
	WHERE row_num > 1)
;

-- US Household Income Statistics - Identify/Remove Duplicates (No Duplicates)

SELECT id, COUNT(id)
FROM us_project.us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;

-- Formatting State Name

SELECT State_Name, COUNT(State_Name)
FROM us_project.USHouseholdIncome
GROUP BY State_Name
;

SELECT DISTINCT State_Name
FROM us_project.USHouseholdIncome
GROUP BY 1
;

UPDATE us_project.USHouseholdIncome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_project.USHouseholdIncome
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;

-- Looking at NULL/Missing Values

SELECT *
FROM us_project.USHouseholdIncome
WHERE Place IS NULL
ORDER BY 1
;

UPDATE us_project.USHouseholdIncome
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;

-- Looking at Type Column

SELECT Type, COUNT(Type)
FROM us_project.USHouseholdIncome
GROUP BY Type
;

UPDATE us_project.USHouseholdIncome
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

-- Looking at AWater and ALand Columns

SELECT ALand, AWater
FROM us_project.USHouseholdIncome
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
AND (ALand = 0 OR ALand = '' OR ALand IS NULL)
;

SELECT ALand, AWater
FROM us_project.USHouseholdIncome
WHERE (ALand = 0 OR ALand = '' OR ALand IS NULL)
;