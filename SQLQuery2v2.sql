Select *
From WorkProject..CovidDeaths
where continent is not null
order by 3,4

select *
from WorkProject..CovidVaccinations
order by 3,4

--select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM WorkProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM WorkProject..CovidDeaths
where location like '%states%'
order by 1,2


--looking at total cases vs population
--shows what percentage of population got covid

SELECT location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM WorkProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From WorkProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From WorkProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--break down by continent

--showing continents with the highest death count

Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From WorkProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM WorkProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from WorkProject..CovidDeaths dea
join WorkProject..CovidVaccinations vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from WorkProject..CovidDeaths dea
join WorkProject..CovidVaccinations vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac





--temp table

drop table if exists #PerecentPopulationVaccinated
create table #PerecentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PerecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from WorkProject..CovidDeaths dea
join WorkProject..CovidVaccinations vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PerecentPopulationVaccinated

--creating view to store data for later visualizations

create view PerecentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from WorkProject..CovidDeaths dea
join WorkProject..CovidVaccinations vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PerecentPopulationVaccinated