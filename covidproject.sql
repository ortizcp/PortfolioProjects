SELECT *
FROM covid.covid_deaths
WHERE continent is not null 
ORDER BY 3,4;

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid.covid_deaths
WHERE continent is not null 
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid.covid_deaths
WHERE location like 'United States' and continent is not null 
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM covid.covid_deaths
-- WHERE location like 'United States'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid.covid_deaths
-- WHERE location like 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths as SIGNED)) as TotalDeathCount
FROM covid.covid_deaths
-- WHERE location like 'United States'
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as SIGNED)) as TotalDeathCount
FROM covid.covid_deaths
-- WHERE location like 'United States'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as SIGNED)) as total_deaths, SUM(CAST(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM covid.covid_deaths
-- WHERE location like 'United States'
WHERE continent is not null 
-- GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM covid.covid_deaths dea
JOIN covid.covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM
        covid.covid_deaths dea
    JOIN
        covid.covid_vaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)

SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingPeopleVaccinated,
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM
    PopvsVac;


-- TEMP TABLE

USE covid;

CREATE TABLE IF NOT EXISTS PercentPopulationVaccinated (
  continent VARCHAR(255),
  location VARCHAR(255),
  date DATETIME,
  population NUMERIC,
  new_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  STR_TO_DATE(dea.date, '%m/%d/%Y') AS date,
  dea.population,
  CASE WHEN vac.new_vaccinations != '' THEN vac.new_vaccinations ELSE '0' END AS new_vaccinations,
  SUM(CAST(CASE WHEN vac.new_vaccinations != '' THEN vac.new_vaccinations ELSE '0' END AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%Y')) AS RollingPeopleVaccinated
FROM
  covid.covid_deaths dea
JOIN
  covid.covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL;

SELECT
  *,
  (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM
  PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE OR REPLACE VIEW PercentPopulationVaccinated AS
SELECT
  dea.continent,
  dea.location,
  STR_TO_DATE(dea.date, '%m/%d/%Y') AS date,
  dea.population,
  CASE WHEN vac.new_vaccinations != '' THEN vac.new_vaccinations ELSE '0' END AS new_vaccinations,
  SUM(CAST(CASE WHEN vac.new_vaccinations != '' THEN vac.new_vaccinations ELSE '0' END AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%Y')) AS RollingPeopleVaccinated
FROM
  covid.covid_deaths dea
JOIN
  covid.covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL;
  
  
  SELECT *
  FROM PercentPopulationVaccinated
  
  
