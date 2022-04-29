/*
COVID-19 Data Exploration

The main purpose I hope to get out of this project is to create queries to then use 
in Tableau for visualizations and future work on the data.

Data collection date: 4/28/2022
*/

-- Beginning with looking at the deaths data I have loaded and their attributes

SELECT *
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 3,4

-- Select data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs. Total Deaths
-- Shows the likelihood of death by contracting COVID in the US

SELECT location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM COVID19Project..[covid-deaths]
WHERE location = 'United States'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of the population contracted COVID

SELECT location, date, population, total_cases, 
	(total_cases/population)*100 AS population_infected_percentage
FROM COVID19Project..[covid-deaths]
--WHERE location = 'United States'
WHERE continent is not null
ORDER BY 1,2

-- Countries with Highest Infection Rates compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, 
	MAX((total_cases/population))*100 AS population_infected_percentage
FROM COVID19Project..[covid-deaths]
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY location, population
ORDER BY population_infected_percentage desc

-- Countries with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM COVID19Project..[covid-deaths]
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc


-- GROUPING THINGS BY CONTINENT

-- Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM COVID19Project..[covid-deaths]
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc

-- Global scale

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS new_deaths_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Total Population vs. Vaccinations
-- Shows the Percentage of the Population that has at least ne COVID vaccine

SELECT dths.continent, dths.location, dths.date, dths.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY dths.location ORDER BY dths.location,
	dths.date) AS rolling_vaccinations
FROM COVID19Project..[covid-deaths] dths
JOIN COVID19Project..[covid-vaccinations] vacc
	ON dths.location = vacc.location
	and dths.date = vacc.date
WHERE dths.continent is not null
ORDER BY 2,3

-- Using CTE to calculate on the PARTITION BY in the query

WITH PopvsVacc (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT dths.continent, dths.location, dths.date, dths.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY dths.location ORDER BY dths.location,
	dths.date) AS rolling_vaccinations
FROM COVID19Project..[covid-deaths] dths
JOIN COVID19Project..[covid-vaccinations] vacc
	ON dths.location = vacc.location
	and dths.date = vacc.date
WHERE dths.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_vaccinations/population)*100 AS rolling_vaccs_percentage
FROM PopvsVacc

-- Using a TEMP table to calculate on the PARTITION BY in the query

DROP TABLE IF exists #percent_population_vaccinated -- For easier table editing
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dths.continent, dths.location, dths.date, dths.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY dths.location ORDER BY dths.location,
	dths.date) AS rolling_vaccinations
FROM COVID19Project..[covid-deaths] dths
JOIN COVID19Project..[covid-vaccinations] vacc
	ON dths.location = vacc.location
	and dths.date = vacc.date
--WHERE dths.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_vaccinations/population)*100 AS rolling_vaccs_percentage
FROM #percent_population_vaccinated


-- Creating View to store data for future visualizations
GO --Ensuring the correct view is created based on the CTE above

CREATE VIEW percent_vaccinated AS
SELECT dths.continent, dths.location, dths.date, dths.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY dths.location ORDER BY dths.location,
	dths.date) AS rolling_vaccinations
FROM COVID19Project..[covid-deaths] dths
JOIN COVID19Project..[covid-vaccinations] vacc
	ON dths.location = vacc.location
	and dths.date = vacc.date
WHERE dths.continent is not null
--ORDER BY 2,3

-- Looking at the created view and its contents

--SELECT *
--FROM percent_population_vaccinated
