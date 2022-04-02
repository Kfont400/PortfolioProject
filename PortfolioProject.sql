SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT Null
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using
SELECT Location, date,total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- shows likelihoo of ytou dying if you contract the covid in your country
SELECT Location, date,total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at total cases vs population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_deaths/population) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at countries with highest infection rates compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population)) * 100 as
percent_of_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by Location, Population
order by percent_of_population_infected desc

--Showiing Countries with Highest Death Counts Per Popluation

SELECT Location, MAX(cast(total_deaths as int)) * 100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT Null
--WHERE location like '%states%'
Group by Location, Population
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BYH CONTINENT 

SELECT location, MAX(cast(total_deaths as int)) * 100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS Null
--WHERE location like '%states%'
Group by location
order by TotalDeathCount desc

--Lets look at each continent with highest Death counts
SELECT continent, MAX(cast(total_deaths as int)) * 100 as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not Null
--WHERE location like '%states%'
Group by continent
order by TotalDeathCount desc


--Gloabal numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths,
SUM(cast(New_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccincations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location ORDER By
dea.location, dea.date) as Rolling_People_Vaccinated,
--MAX(Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS not Null
--and dea.location like'%state%'
order by 2,3

--USE CTE
 WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_People_Vaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location ORDER By
dea.location, dea.date) as Rolling_People_Vaccinated
--MAX(Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS not Null
--and dea.location like'%state%'
--order by 2,3
)

SELECT *,(Rolling_People_Vaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location ORDER By
dea.location, dea.date) as Rolling_People_Vaccinated
--MAX(Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS not Null
--and dea.location like'%state%'
--order by 2,3

SELECT *,(Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data later for visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location ORDER By
dea.location, dea.date) as Rolling_People_Vaccinated
--MAX(Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS not Null
and dea.location like'%state%'
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated