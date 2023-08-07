/*

DISCLAIMER: This work is modified from Alex Freberg's "SQL Queries for Tableau Project" available here: https://bit.ly/3fkqEij
and has been tweaked to work on a M1 Pro MacBook Pro running Docker and Azure Data Studio.

*/

-- 1. Overall global numbers 

SELECT 
SUM(CAST(new_cases AS BIGINT)) AS total_cases, 
SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths as NUMERIC))/SUM(CAST(New_Cases AS BIGINT)) * 100 as death_percentage
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- 2. Total death count by county.  
-- We take these out as they are not inluded in query "1" and want to stay consistent
-- European Union is part of Europe

SELECT
location,
SUM(cast(new_deaths AS INT)) AS total_death_count
FROM dbo.coviddeaths
WHERE continent IS NULL
AND location NOT IN  ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC;

-- 3.  Infection numbers by location, population, and percentage of population infected with COVID-19
-- We take these out as they are not inluded in query "1" and want to stay consistent
-- European Union is part of Europe

SELECT
location, 
population, 
MAX(CAST(total_cases AS BIGINT)) AS highest_infection_count,  
MAX(CAST(total_cases AS BIGINT))/CAST(population AS NUMERIC) * 100 AS percent_population_infected
FROM dbo.coviddeaths
WHERE location NOT IN  ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- 4.  Infection numbers by location, population, date, higest infection count, and percentage of population infected
-- with COVID-19.

SELECT 
location,
population,
date, 
MAX(CAST(total_cases AS BIGINT)) as highest_infection_count,
MAX(CAST(total_cases AS BIGINT))/CAST(population AS NUMERIC) * 100 AS percent_population_infected
FROM dbo.coviddeaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;