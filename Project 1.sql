select *
from Portfolioproject..Coviddeaths
where continent is not null
order by 3,4
--select *
--from Portfolioproject..Covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..Coviddeaths
order by 1,2

--Total cases vs Total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Portfolioproject..Coviddeaths
where location like '%states%'
and where continent is not null
order by 1,2

--Total Cases vs Populatoion
select location, date, total_cases, population, (total_cases/population)*100 as Infectedpercentage
from Portfolioproject..Coviddeaths
--where location like '%states%'
order by 1,2

--Finding countries with highest infection rate
select location, population, Max(total_cases) as HighestInfection, Max((total_cases/population))*100 as PopulationPercentageInfected
from Portfolioproject..Coviddeaths
--where location like '%states%'
Group by location, population
order by PopulationPercentageInfected desc

--Finding countries with highest death count
select location, population, Max(total_deaths) as DeathCount, Max((total_deaths/population))*100 as PopulationPercentageDied
from Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by PopulationPercentageDied desc

--Continents with highest deaths
select continent, Max(CAST(total_deaths as int)) as TotalDeathCount
from Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Stats
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from Portfolioproject..Coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2

--Merging tables
--Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as TotalVaccinated
From Portfolioproject..Coviddeaths dea
Join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac(continent, location, date, population, new_vaccinations, Totalvaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as TotalVaccinated
From Portfolioproject..Coviddeaths dea
Join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (Totalvaccinated/population)*100
from PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location varchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
Totalvaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as TotalVaccinated
From Portfolioproject..Coviddeaths dea
Join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (Totalvaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as TotalVaccinated
From Portfolioproject..Coviddeaths dea
Join Portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated