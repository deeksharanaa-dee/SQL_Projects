Select *
From [portfolio project]..CovidDeaths
where continent is not null

--Select *
--From [portfolio project]..CovidVaccinations
--order by 3,4


--Looking at Total cases vs Total deaths
--Shows likelihood of dying if contracted by covid in your country

Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercantage
from [portfolio project]..CovidDeaths
where location like '%kingdom%' and continent is not null
order by 1,2

--Looking at total cases vs Population
-- Shows the percentage of population got covid


Select location,date, total_cases,population, (total_cases/population)*100 as PercentPopulationInf
from [portfolio project]..CovidDeaths
where location like '%kingdom%'and continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location,population,Max(total_cases) as HighestInfCount,Max((total_cases/population))*100 as PercentPopulationInfected
from [portfolio project]..CovidDeaths
--where location like '%kingdom%'
group by population, location
order by PercentPopulationInfected Desc

-- Showing countries with the highest death count per population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project]..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by location
order by TotalDeathCount desc


--Let's check it out as per continent

Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project]..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM (new_cases) * 100 as deathpercentage
from [portfolio project]..CovidDeaths
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2

-- total death percentage 

Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM (new_cases) * 100 as deathpercentage
from [portfolio project]..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as 
 rollingcountofpeoplevacc 
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 --USE CTE
 
 With PopvsVac (Continent,location,date,population,new_vaccinations,rollingcountofpeoplevacc)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as 
 rollingcountofpeoplevacc 
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )	
 select * , (rollingcountofpeoplevacc / population)* 100
 from PopvsVac

 -- TEMP TABLE

 Drop Table if exists #percentpopulationvaccinated
 Create Table #percentpopulationvaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rcp numeric
 )

 Insert into #percentpopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as rcp 
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select * , (rcp/ population)* 100
 from #percentpopulationvaccinated


--Create view to store data for visualization 

Create View percentpopulationvaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as rcp 
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select * 
 from percentpopulationvaccinated