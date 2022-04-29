-- First couple of queries will show the deaths and vaccinations tables
-- ordered by location and date

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
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of the population gor Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as population_infected_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rates vs. Population

SELECT location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases)/population)*100 as max_population_infected
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY location, population
ORDER BY max_population_infected desc

-- Showing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, population,  MAX(cast(total_deaths as int)) as total_death_count
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc

-- Global scale

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as new_deaths_percentage
FROM COVID19Project..[covid-deaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2