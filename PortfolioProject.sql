Select *
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
Order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccination
--Order by 3,4

--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying from Covid in USA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1, 2

--Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
order by 1, 2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Group by population, location
order by PercentPopulationInfected desc

--Countries with the Highest Death Count per Population
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCounts
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
Group by location
order by TotalDeathCounts desc

--break down by continent
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCounts
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
Group by location
order by TotalDeathCounts desc

--show continents with the highes death count per population
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCounts
From PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
Group by continent
order by TotalDeathCounts desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as BIGINT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1, 2


--USE CTE
-- Total Populations vs Vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated