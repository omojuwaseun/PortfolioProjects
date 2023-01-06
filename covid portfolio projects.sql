select *
from portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from portfolioproject..CovidVaccinations
--order by 3,4

--selecting data that were going to be using 

select Location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like '%africa%'
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid

select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
--where location like '%africa%'
order by 1,2


-- looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
--where location like '%africa%'
group by Location, population
order by PercentPopulationInfected desc


-- showing the countries with the highest death count per population

select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by Location
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT 

-- showing the continent with the highest death

select continent , max(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by continent 
order by TotalDeathCount desc

 
 -- global numbers

 select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%africa%'
where continent is not null 
group by date 
order by 1,2

-- overall worldwide death percentage

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%africa%'
where continent is not null 
--group by date 
order by 1,2

-- looking at total vaccinations vs vaccinations 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- with cte
with PopvsVac (Continent, location, date, population, new_vaccinations ,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


-- temp table

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
select dea.Continent,dea.Location,dea.Date,dea.Population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) over (partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--creating view to store data for visualizations

create view PercentPopulationVaccinated as
select dea.Continent,dea.Location,dea.Date,dea.Population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) over (partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
--, ((RollingPeopleVaccinated/Population)*100 
from portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date
where dea.continent is not null
--order by 2,3
select *
from PercentPopulationVaccinated 


create view DeathPercentage as 
select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%africa%'
where continent is not null 
group by date 
--order by 1,2
