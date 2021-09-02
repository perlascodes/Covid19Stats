Select *
From CovidStats.dbo.CovidDeaths
order by 3,4

--Select *
--From CovidStats.dbo.CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From CovidStats.dbo.CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathRate
From CovidStats.dbo.CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathRate
From CovidStats.dbo.CovidDeaths
Where location like '%Macedonia%'
order by 1,2

Select location, date, total_cases, population, (total_cases/population)*100 as PopTotCaseRatio
from CovidStats.dbo.CovidDeaths
Where location like '%Macedonia%'
order by 1,2

Select location, population, Max(total_cases) as HighestInfectionRate,Max((total_cases/population))*100 as PercentPopInfected
from CovidStats.dbo.CovidDeaths
Where location IN ('North Macedonia','Bulgaria', 'Serbia','Montenegro', 'Bosnia and Herzegovina','Croatia','Greece','Turkey')
Group by Location, population
Order by PercentPopInfected desc;

--make sure the variable type is the same with the one used for ordering(int and float are not the same)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidStats.dbo.CovidDeaths
Where location IN ('North Macedonia','Bulgaria', 'Serbia','Montenegro', 'Bosnia and Herzegovina','Croatia','Greece','Turkey')
and continent is not NULL
Group by Location
Order by TotalDeathCount desc;

--by continents
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidStats.dbo.CovidDeaths
Where continent is not NULL
Group by continent
Order by TotalDeathCount desc;

---global numbers day by day 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidStats.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--overall total 
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidStats.dbo.CovidDeaths
where continent is not null
order by 1,2


--joining total population and deaths roll with vaccinations
Drop table if exists #PercentVaccinated
Create Table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingVaccinationNumbers numeric
)
Insert into #PercentVaccinated
Select deat.continent, deat.location, deat.date, deat.population,  vacc.new_vaccinations, 
SUM(Convert(int, vacc.new_vaccinations)) OVER (partition by deat.location Order by deat.location, deat.Date)
as RollingVaccinationNumbers
From CovidStats.dbo.CovidDeaths deat
Join CovidStats.dbo.CovidVaccinations vacc
On deat.location = vacc.location
and deat.date = vacc.date
where deat.continent is not null

Select * , (RollingVaccinationNumbers/Population)*100 as PercentageOfVaccinated
from #PercentVaccinated




--only for balkan 

Drop table if exists #PercentVaccinatedBalkan
Create Table #PercentVaccinatedBalkan
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingVaccinationNumbers numeric
)
Insert into #PercentVaccinatedBalkan
Select deat.continent, deat.location,deat.date,  deat.population, vacc.new_vaccinations, 
SUM(Convert(int, vacc.new_vaccinations)) OVER (partition by deat.location Order by deat.location, deat.Date)
as RollingVaccinationNumbers
From CovidStats.dbo.CovidDeaths deat
Join CovidStats.dbo.CovidVaccinations vacc
On deat.location = vacc.location
and deat.date = vacc.date
where deat.continent is not null
and deat.location IN ('North Macedonia','Bulgaria', 'Serbia','Montenegro', 'Bosnia and Herzegovina','Croatia','Greece','Turkey')

Select * , (RollingVaccinationNumbers/Population)*100 as PercentageOfVaccinated
from #PercentVaccinatedBalkan


-- create views in order to have permanent tables for later editing 
Create View PercentVaccinated as
Select deat.continent, deat.location, deat.date, deat.population,  vacc.new_vaccinations, 
SUM(Convert(int, vacc.new_vaccinations)) OVER (partition by deat.location Order by deat.location, deat.Date)
as RollingVaccinationNumbers
From CovidStats.dbo.CovidDeaths deat
Join CovidStats.dbo.CovidVaccinations vacc
On deat.location = vacc.location
and deat.date = vacc.date
where deat.continent is not null


--view for the balkans
Create View PercentVaccinatedBalkan as
Select deat.continent, deat.location, deat.date, deat.population,  vacc.new_vaccinations, 
SUM(Convert(int, vacc.new_vaccinations)) OVER (partition by deat.location Order by deat.location, deat.Date)
as RollingVaccinationNumbers
From CovidStats.dbo.CovidDeaths deat
Join CovidStats.dbo.CovidVaccinations vacc
On deat.location = vacc.location
and deat.date = vacc.date
where deat.continent is not null
and deat.location IN ('North Macedonia','Bulgaria', 'Serbia','Montenegro', 'Bosnia and Herzegovina','Croatia','Greece','Turkey')
