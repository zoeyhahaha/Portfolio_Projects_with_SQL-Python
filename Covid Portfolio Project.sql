
SELECT * 
FROM PortfolioProject.coviddeaths
ORDER BY 3,4;

SELECT * 
FROM PortfolioProject.covidvaccinations
ORDER BY 3,4;

-- Data about CovidDeaths

SELECT location, date, total_cases, total_deaths, population_density
FROM PortfolioProject.coviddeaths
ORDER BY 1,2;

-- Data about death rate

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE location LIKE '%British%'
ORDER BY DeathPercentage DESC;

-- Looking at Total cases VS Population

SELECT location, date, total_cases, population_density, (total_cases/population_density)*100 AS CovidPercentage
FROM PortfolioProject.coviddeaths
WHERE date>01/01/22
ORDER BY CovidPercentage DESC;

-- Looking at countries with highest infection rate compared to population

SELECT 
	location, 
	population_density, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population_density))*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
GROUP BY location, population_density
ORDER BY PercentPopulationInfected DESC;

-- Looking at countries with highest death count per population
-- SQL Server uses 'INT', while Mysql uses 'SIGNED'

SELECT 
 	location, 
	MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Break things down by continent

SELECT 
 	continent,
	MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent LIKE'%America%'
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT 
 	continent,
    SUM(total_cases) AS TotalCases,
    SUM(CAST(total_deaths AS SIGNED)) AS TotalDeaths,
	SUM(CAST(total_deaths AS SIGNED))/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
GROUP BY continent
ORDER BY DeathPercentage DESC;

-- Looking at total population VS vaccinations
-- Use CTE & Window function

WITH PopvsVac (continent, location, date, population_density, new_vaccinations, RollingPeopleVaccinated)
AS(
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population_density, 
		vac.new_vaccinations,
		SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject.coviddeaths dea
	JOIN PortfolioProject.covidvaccinations vac
		ON dea.location=vac.location
		AND dea.date=vac.date
)
SELECT *, (RollingPeopleVaccinated/population_density)*100
FROM PopvsVac;

-- Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
continent text,
location text,
date text,
population_density double,
new_vaccinations text
)
AS
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population_density, 
		vac.new_vaccinations
	FROM PortfolioProject.coviddeaths dea
	JOIN PortfolioProject.covidvaccinations vac
		ON dea.location=vac.location
		AND dea.date=vac.date;

SELECT *
FROM PercentPopulationVaccinated;

-- Create view to store data for later visualazation

CREATE VIEW PopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population_density, 
	vac.new_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;



