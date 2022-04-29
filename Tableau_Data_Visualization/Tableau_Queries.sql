/*

Queries used for Tableau dataviz project

*/

-- 1. Global death observations

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

-- 2. Total Deaths by continent

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS total_death_count
FROM COVID19Project..[covid-deaths]
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income%' -- removing rows with income status as location
GROUP BY location
ORDER BY total_death_count desc


-- 3. Highest Infection Count vs. Population

SELECT location, population, MAX(total_cases) AS highest_infection_count,  
	MAX((total_cases/population))*100 AS population_infected_percentage
FROM COVID19Project..[covid-deaths]
GROUP BY location, population
ORDER BY population_infected_percentage desc


-- 4. Highest Infection Count vs. Population by Date

SELECT location, population, date, MAX(total_cases) AS highest_infection_count,  
	MAX((total_cases/population))*100 AS population_infected_percentage
FROM COVID19Project..[covid-deaths]
GROUP BY location, population, date
ORDER BY population_infected_percentage desc

-- STORING VIEWS AS TABLES FOR TABLEAU USE

-- 1

-- CTE
WITH TotalCasesvsDeaths(total_cases, total_deaths, death_percentage)  AS
(
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null 
--GROUP BY date
--ORDER BY 1,2
)
SELECT *
FROM TotalCasesvsDeaths

-- TEMP table

DROP TABLE IF exists #TotalCasesvsDeaths
CREATE TABLE #TotalCasesvsDeaths
(
total_cases numeric,
total_deaths numeric,
death_percentage numeric
)

INSERT INTO #TotalCasesvsDeaths
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS bigint)) AS total_deaths, 
	SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS death_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null 
--GROUP BY date
--ORDER BY 1,2

SELECT *
FROM #TotalCasesvsDeaths

GO

CREATE VIEW TotalCasesvsDeaths AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null; 
--GROUP BY date
--ORDER BY 1,2


-- 2
WITH DeathsbyContinent(location, total_death_count)
AS
(
	SELECT location, SUM(CAST(new_deaths AS int)) OVER (PARTITION BY 
	location ORDER BY location, date) AS total_death_count
	FROM COVID19Project..[covid-deaths]
	WHERE continent is null 
	and location not in ('World', 'European Union', 'International')
	and location not like '%income%' -- removing rows with income status as location
	--GROUP BY location
	--ORDER BY total_death_count desc
)
SELECT *
FROM DeathsbyContinent

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
-- 3
WITH PopInfectedbyCountry(location, population, highest_infection_count, population_infected_percentage) 
AS
(
	SELECT location, population, MAX(total_cases) AS highest_infection_count,  
		MAX((total_cases/population))*100 AS population_infected_percentage
	FROM COVID19Project..[covid-deaths]
	--GROUP BY location, population
	--ORDER BY population_infected_percentage desc
)
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
-- 4
WITH MostInfectedbyCountry(location, population, date, highest_infection_count, population_infected_percentage) 
AS
(
	SELECT location, population, date, MAX(total_cases) AS highest_infection_count,  
		MAX((total_cases/population))*100 AS population_infected_percentage
	FROM COVID19Project..[covid-deaths]
	--GROUP BY location, population, date
	--ORDER BY population_infected_percentage desc
)
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