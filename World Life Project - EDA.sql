# World Life Expectancy (Exploratory Data Analysis)

SELECT *
FROM world_life_expectancy.worldlifexpectancy
;

-- Looking at Each Country Life Expectancy -- How they have increased

SELECT Country, MIN(Lifeexpectancy), 
MAX(Lifeexpectancy),
ROUND(MAX(Lifeexpectancy) - MIN(Lifeexpectancy), 1) AS Life_Increase_15_Years
FROM world_life_expectancy.worldlifexpectancy
GROUP BY Country
HAVING MIN(Lifeexpectancy) <> 0
AND MAX(Lifeexpectancy) <> 0
ORDER BY Life_Increase_15_Years DESC
;

-- Average Life Expectancy For Each Year

SELECT Year, ROUND(AVG(Lifeexpectancy), 2) AS Average_Life_Per_Year
FROM world_life_expectancy.worldlifexpectancy
WHERE Lifeexpectancy <> 0
AND Lifeexpectancy <> 0
GROUP BY Year
ORDER BY Year 
;

-- Looking at Correlation Between Life Expectancy and GDP

SELECT *
FROM world_life_expectancy.worldlifexpectancy
;

SELECT Country, ROUND(AVG(Lifeexpectancy),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy.worldlifexpectancy
GROUP BY Country
HAVING Life_exp > 0
AND GDP > 0
ORDER BY GDP DESC
;



SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN Lifeexpectancy ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN Lifeexpectancy ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy.worldlifexpectancy
;

-- Looking at Average Life Expectancy and Status

SELECT *
FROM world_life_expectancy.worldlifexpectancy
;

SELECT Status, ROUND(AVG(Lifeexpectancy),1)
FROM world_life_expectancy.worldlifexpectancy
GROUP BY Status
;

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(Lifeexpectancy),1)
FROM world_life_expectancy.worldlifexpectancy
GROUP BY Status
;

-- Looking at BMI and Life Expectancy

SELECT *
FROM world_life_expectancy.worldlifexpectancy
;

SELECT Country, ROUND(AVG(Lifeexpectancy),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy.worldlifexpectancy
GROUP BY Country
HAVING Life_exp > 0
AND BMI > 0
ORDER BY BMI ASC
;

-- Looking at Adult Mortality Compared to Life Expectancy

SELECT Country, 
Year, 
Lifeexpectancy, 
AdultMortality,
SUM(AdultMortality) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy.worldlifexpectancy
WHERE Country LIKE '%United%'
;
