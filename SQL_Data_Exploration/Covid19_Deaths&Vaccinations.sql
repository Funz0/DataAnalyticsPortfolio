-- Beginning with looking at the data I have loaded and their attributes

SELECT *
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM COVID19Project..[covid-vaccinations]
--WHERE continent is not null
--ORDER BY 3,4


-- Select relevant columns from the covid-deaths data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of death by contracting Covid in a given country

SELECT location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of the population gor Covid

SELECT location, date, population, total_cases, 
	(total_cases/population)*100 AS population_infected_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Looking at countries with Highest Infection Rates vs. Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, 
	(MAX(total_cases)/population)*100 AS max_population_infected
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY location, population
ORDER BY max_population_infected desc

-- Showing countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, population,  MAX(CAST(total_deaths AS int)) AS total_death_count
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc

-- Global scale

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS new_deaths_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs. Vaccinations

SELECT dths.continent, dths.location, dths.date, dths.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY dths.location ORDER BY dths.location,
	dths.date) AS rolling_vaccinations
FROM COVID19Project..[covid-deaths] dths
JOIN COVID19Project..[covid-vaccinations] vacc
	ON dths.location = vacc.location
	and dths.date = vacc.date
WHERE dths.continent is not null
ORDER BY 2,3

-- USING CTE

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
-- ORDER BY 2,3
)
SELECT *, (rolling_vaccinations/population)*100 AS rolling_vaccs_percentage
FROM PopvsVacc

-- TEMP TABLE

DROP TABLE IF exists #percent_population_vaccinated -- For easier query testing
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
WHERE dths.continent is not null
-- ORDER BY 2,3

SELECT *, (rolling_vaccinations/population)*100 AS rolling_vaccs_percentage
FROM #percent_population_vaccinated


-- Creating view to store data for visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT dths.continent, dths.location, dths.date, dths.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY dths.location ORDER BY dths.location,
	dths.date) AS rolling_vaccinations
FROM COVID19Project..[covid-deaths] dths
JOIN COVID19Project..[covid-vaccinations] vacc
	ON dths.location = vacc.location
	and dths.date = vacc.date
WHERE dths.continent is not null
-- ORDER BY 2,3

-- Looking at the created view and its contents

SELECT *
FROM percent_population_vaccinated
