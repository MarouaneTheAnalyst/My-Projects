--SELECT * 
--FROM PortfolioProject..CovidDeaths$

--SELECT *
--FROM PortfolioProject..CovidVaccinations$

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2
-- Percentage of dying if you contract covid in your country 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location='Morocco' AND continent is not null
ORDER BY 1,2

--percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location='Morocco'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location,population, MAX(total_cases) as HighestInfectioncount, MAX((total_cases/population)*100) as PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location,population
ORDER BY PopulationInfectedPercentage desc

--Countries with Highest Death Count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--contintents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- -- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 -- we can't use it in the same line 
FROM PortfolioProject..CovidDeaths$ dth
JOIN PortfolioProject..CovidVaccinations$ vacc
	ON dth.location = vacc.location
	AND dth.date = vacc.date
where dth.continent is not null 
order by 2,3

-- Using 'CTE' to perform Calculation on Partition By in previous query (or we can use Temp Table)

With PopulationVSvaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dth
Join PortfolioProject..CovidVaccinations$ vacc
	On dth.location = vacc.location
	and dth.date = vacc.date
where dth.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVacc
From PopulationVSvaccination


-- Creating some View to store data for visualizations

CREATE VIEW 
PercentPopulationVaccinate 
as
Select dth.continent, dth.location, dth.date, dth.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dth
Join PortfolioProject..CovidVaccinations$ vacc
	On dth.location = vacc.location
	and dth.date = vacc.date
where dth.continent is not null 

