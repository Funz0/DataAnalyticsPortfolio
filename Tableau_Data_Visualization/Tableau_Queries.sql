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

-- Note: fix location values and prevent income categories from storing 