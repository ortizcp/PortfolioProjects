# US Household Income Project (Exploratory Data Analysis)

SELECT * 
FROM us_project.USHouseholdIncome;

SELECT * 
FROM us_project.us_household_income_statistics;

-- Looking at ALand and AWater Per State

SELECT * 
FROM us_project.USHouseholdIncome;

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.USHouseholdIncome
GROUP BY State_Name
ORDER BY 3 DESC
;

-- Identify Top 10 Largest States by Land

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.USHouseholdIncome
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;

-- Joining Statistics to Income Table

SELECT * 
FROM us_project.USHouseholdIncome;

SELECT * 
FROM us_project.us_household_income_statistics;

SELECT * 
FROM us_project.USHouseholdIncome u
RIGHT JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0
;

SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_project.USHouseholdIncome u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0
;

-- Looking at Household AVG Income and Median Income Per State

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.USHouseholdIncome u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3 DESC
LIMIT 10
;

-- Looking a AVG and Median Household Income by Type

SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.USHouseholdIncome u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
LIMIT 20
;

SELECT *
FROM us_project.USHouseholdIncome
WHERE Type = 'Community'
;

-- Looking at Income on a City Level

SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.USHouseholdIncome u
JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
GROUP BY u.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC
;