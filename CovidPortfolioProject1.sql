--Select *
--From Portfolio_Project1..CovidDeaths
--Where continent is not null
--order by 3,4

--Select *
--From Portfolio_Project1..CovidVaccinations
--order by 3,4

--Select Data that to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project1..CovidDeaths
order by 1,2

-- Total Cases VS Total Deaths, likelihood of dying in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project1..CovidDeaths
Where location LIKE '%states%'
order by 1,2

--grouped by location total_cases vs total_deaths
Select location, 
	   sum(cast(total_cases AS BIGINT)) AS totalCases, 
       SUM(cast(total_deaths AS BIGINT)) AS totalDeath
from Portfolio_Project1..CovidDeaths
group by location
order by totalCases DESC, totalDeath DESC

-- total cases vs population, percentage of population got covid 
Select location, date,total_cases, population, (total_cases/population)*100 as InfectionPercentage
From Portfolio_Project1..CovidDeaths
where location LIKE 'ph%'
order by 1,2

--total cases, total deaths, philippines, percentage of population who got covid above 0.5%
Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS InfectionPercentage
From Portfolio_Project1.dbo.CovidDeaths
WHERE location like 'ph%' AND (total_cases/population)*100 >0.5
order by 1,2

--what countries have the highest infection rates compared to population
Select 
	location,
	population, 
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population)*100) AS HighestInfectionPercentage
From Portfolio_Project1..CovidDeaths
Where continent is not null
Group by location, population
order by 4 DESC

--showing countries with the highest death rates per population
Select 
	location,
	MAX(cast(total_deaths AS int)) as HighestDeathCount
From Portfolio_Project1..CovidDeaths
Where continent is not null
Group by location
order by 2 DESC

-- by continent
Select 
	location,
	MAX(cast(total_deaths AS int)) as HighestDeathCount
From Portfolio_Project1..CovidDeaths
Where continent is null AND location <> 'World'
Group by location
order by 2 DESC

--top continent with the highest death
Select 
	TOP 1 location,
	MAX(cast(total_deaths AS int)) as HighestDeathCount
From Portfolio_Project1..CovidDeaths
Where continent is null AND location <> 'World'
Group by location
order by 2 DESC

-- showing the continents with the highest death count
Select 
	TOP 1 location,
	MAX(cast(total_deaths AS int)) as HighestDeathCount
From Portfolio_Project1..CovidDeaths
Where continent is null AND location <> 'World'
Group by location
order by 2 DESC

-- GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/ SUM(new_cases)) * 100 as deathPercentage--, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Portfolio_Project1..CovidDeaths
where continent is not null
order by 1,2

--Total population vs vaccinations



With PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
Select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from Portfolio_Project1..CovidDeaths cd
join Portfolio_Project1..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)

Select *, (RollingPeopleVaccinated / population)*100
From PopVSVac

--using temp table
Create Table #VaccinatedPercentage(
	continent nvarchar(255),
	location  nvarchar(255),
	date      datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #VaccinatedPercentage
Select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from Portfolio_Project1..CovidDeaths cd
join Portfolio_Project1..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

Select *, (RollingPeopleVaccinated / population)*100
From #VaccinatedPercentage

--create a view to store data for later visualizations
Create View VaccinatedPercentage as
Select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from Portfolio_Project1..CovidDeaths cd
join Portfolio_Project1..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

