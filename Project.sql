Queried Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at the total cases vs total deaths
Select location,date, total_cases,population, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states '
where continent is not null
order by 1,2


--Total case vs Population
-- show what percentage of population got covid

Select location,date, total_cases,population, (total_cases/population)*100 as Percentageofpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate vs population

Select location, Max(total_cases) as HighestCount,population, Max((total_cases/population))*100 as Percentageofpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
group by location,population
order by Percentageofpopulationinfected desc

-- Countries with max death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
group by location
order by TotalDeathCount desc

--Lets do it by continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continent with highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

Select sum(new_cases) as totalcases , sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states '
where continent is not null
order by 1,2

--Looking at total population vs vaccination
with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,Rollingsumofvaccinatedpeople )
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location,dea.date) as Rollingsum
from PortfolioProject..CovidDeaths as dea join PortfolioProject..CovidVaccinations as Vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)

Select*,(Rollingsumofvaccinatedpeople/population) from PopvsVac
order by 2,3



--using Temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rollingsumofvaccinatedpeople numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location,dea.date) as Rollingsum
from PortfolioProject..CovidDeaths as dea join PortfolioProject..CovidVaccinations as Vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null


Select*,(Rollingsumofvaccinatedpeople/population) from #PercentPopulationVaccinated
order by 2,3

--Create View to store data for later visualization

Create View PercentPopulationVaccinated as  

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location,dea.date) as Rollingsum
from PortfolioProject..CovidDeaths as dea join PortfolioProject..CovidVaccinations as Vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated