--Verify both tables are working
SELECT *
FROM dbo.coviddeaths
ORDER BY 3,4;

SELECT *
FROM dbo.covidvaccinations
ORDER BY 3,4;

--Select the data we are going to be using.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.coviddeaths
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
--Shows the likelihoop of dying if you contract COVID-19 in your country
SELECT 
	location, 
	date,
	total_cases,
	total_deaths,
	CAST(total_deaths AS INT) / CAST(total_cases AS NUMERIC) * 100 AS death_percentage
FROM dbo.coviddeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Shows what percentage of US population contracted COVID-19
SELECT 
	location, 
	date,
	population,
	total_cases,
	CAST(total_cases AS INT) / CAST(population AS NUMERIC) * 100 AS infection_rate
FROM dbo.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population
--Shows what percentage of world population contracted COVID-19
SELECT
	location, 
	population,
	--total_cases,
	MAX(CAST(total_cases AS INT)) AS highest_infection_count,
	MAX(CAST(total_cases AS INT) / CAST(population AS NUMERIC)) * 100 AS infection_rate
FROM dbo.coviddeaths
--WHERE location <> '%states%'
GROUP BY location, population

--LET's BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
SELECT
	continent, 
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Showing Countries with Highest Death Count per Population
SELECT
	location, 
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM dbo.coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

--GLOBAL DATA
--Showing global death percentage
SELECT 
	--date,
	SUM(CAST(new_cases AS INT)) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT)) / SUM(CAST(new_cases AS NUMERIC)) * 100 AS death_percentage
FROM dbo.coviddeaths
--WHERE location LIKE '%states%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--COVID Vaccinations Data Refresh
SELECT *
FROM dbo.covidvaccinations
ORDER BY 3,4;

--Time for some JOINS!
--Ensuring tables joined properly
SELECT *
FROM dbo.coviddeaths dea
JOIN dbo.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

--Looking at Total Population vs Vaccinations
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM dbo.coviddeaths dea
JOIN dbo.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM dbo.coviddeaths dea
JOIN dbo.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (rolling_people_vaccinated/CONVERT(NUMERIC,population))*100
FROM popvsvac;

--TEMP TABLE EXAMPLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
	continent nvarchar (255),
	location nvarchar (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
)
INSERT INTO #percent_population_vaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM dbo.coviddeaths dea
JOIN dbo.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
SELECT *, (rolling_people_vaccinated/CONVERT(NUMERIC,population))*100
FROM #percent_population_vaccinated;

--Creating VIEW to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM dbo.coviddeaths dea
JOIN dbo.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;