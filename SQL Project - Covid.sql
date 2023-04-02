SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Look at Total Cases vs Total Deaths
--Show likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%ph%' and continent is not null
ORDER BY DeathPercentage

--Looking at Total Cases vs Population
--Show what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercent
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%ph%' and continent is not null
ORDER BY InfectionPercent

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PecentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PecentPopulationInfected

--Showing Countries with Highest Death Count per Population\
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing by continent with highest death counts
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Global Numbers of death
SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

--CovidVaccinations
SELECT *
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date

--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT*
FROM PercentPopulationVaccinated