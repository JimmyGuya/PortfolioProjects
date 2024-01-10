SELECT *
FROM PortfolioProject..CovidDeaths$

SELECT *
FROM PortfolioProject..CovidVaccinations$

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'

--Looking at the Total Cases vs Population
--Shows what % of population got covid

SELECT location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Percentpopulationinfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(float, total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS Percentpopulationinfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY Percentpopulationinfected DESC

--Showing the countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotaldeathCount DESC

--Lets break things down by continent
----Showing continents with the highest death count

SELECT continent, MAX(total_deaths) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotaldeathCount DESC

--Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as float)) AS total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (Rollingpeoplevaccinated/population)*100
FROM PopvsVac

--


USE TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT*, (Rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualiazations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated