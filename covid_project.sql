-- replacing '' with NULL in continent column of both deaths and vaccinations tables
UPDATE portfolio_project.deaths 
SET continent = NULL WHERE continent = '';

UPDATE portfolio_project.vaccinations 
SET continent = NULL WHERE continent = '';

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.deaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths (death rate
-- Shows likelihood of dying if you contract covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM portfolio_project.deaths
WHERE location like '%states%'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as infection_rate
FROM portfolio_project.deaths
WHERE location like '%states%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population)*100) as infection_rate
FROM portfolio_project.deaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY infection_rate DESC;


-- Showing Countries with highest death count per population
SELECT location, MAX(total_deaths) as totalDeathCount
FROM portfolio_project.deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC;


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as totalDeathCount
FROM portfolio_project.deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC;

-- Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_rate 
FROM portfolio_project.deaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;


-- Looking at total population vs vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM portfolio_project.deaths d 
JOIN portfolio_project.vaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY 2, 3;

-- Use Temporary Table to store result of join
DROP TABLE IF exists PPV;
CREATE TABLE PPV
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM portfolio_project.deaths d 
JOIN portfolio_project.vaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT *, ((rollingPeopleVaccinated/2)/population)*100 AS approxPercentFullyVaccinated
FROM PPV
WHERE location LIKE '%states%'
ORDER BY 2, 3;   



-- Creating a view to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM portfolio_project.deaths d 
JOIN portfolio_project.vaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

SELECT * 
FROM PercentPopulationVaccinated;


   
   