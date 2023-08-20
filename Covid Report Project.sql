select * from [Portofolio Project]..CovidDeaths order by 3,4

select * from [Portofolio Project]..CovidVaccinations order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from [Portofolio Project]..CovidDeaths order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS

select location,date,total_cases,total_deaths,(total_deaths/total_cases) as deathpercentage
from [Portofolio Project]..CovidDeaths where location like '%india%' order by 1,2

----lokking at total cases vs population


select location,date,population,total_cases,(total_cases/population) as deathpercentage
from [Portofolio Project]..CovidDeaths where location like '%states%' order by 1,2

--looking at contries with highest infection rate compared to population

select location,population,max(total_cases) as highinfectioncount,max((total_cases/population))*100 as percentagepopulationinfected
from [Portofolio Project]..CovidDeaths group by location,population order by percentagepopulationinfected desc

--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as highestdeathcount
from [Portofolio Project]..CovidDeaths where continent is not null group by location order by highestdeathcount desc

--showing continents with highest death count per population

select continent,max(cast(total_deaths as int)) as highestdeathcount
from [Portofolio Project]..CovidDeaths where continent is not null group by continent order by highestdeathcount desc

---global numbers

select sum(total_cases) as totalcases,sum(cast(total_deaths as float)) as totaldeaths,sum(cast(total_deaths as float))/sum(total_cases)*100 as deathpercentageglobally
from [Portofolio Project]..CovidDeaths where continent is not null order by 1,2


select * from [Portofolio Project]..CovidDeaths as Dea
 join [Portofolio Project]..CovidVaccinations as Vac
 on Dea.location = Vac.location and
 Dea.date = Vac.date

 --total population vs people vaccinated

 select Dea.continent, Dea.location, Dea.date, Dea.population, 
 Vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingpeoplevaccianted
 from [Portofolio Project]..CovidDeaths as Dea
 join [Portofolio Project]..CovidVaccinations as Vac
 on Dea.location = Vac.location and
 Dea.date = Vac.date
 where Dea.continent is not null
 order by 2,3

 with popvsvac
 (
 continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
 as
 (
 select Dea.continent, Dea.location, Dea.date, Dea.population, 
 Vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingpeoplevaccianted
 from [Portofolio Project]..CovidDeaths as Dea
 join [Portofolio Project]..CovidVaccinations as Vac
 on Dea.location = Vac.location and
 Dea.date = Vac.date
 where Dea.continent is not null
 )
 select *, (rollingpeoplevaccinated/population)*100 as percentagepeoplevaccinated from popvsvac

 --temp table 

 create table #percentagepopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )
 drop table if exists #percentagepopulationvaccinated
 insert into #percentagepopulationvaccinated
  select Dea.continent, Dea.location, Dea.date, Dea.population, 
 Vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingpeoplevaccianted
 from [Portofolio Project]..CovidDeaths as Dea
 join [Portofolio Project]..CovidVaccinations as Vac
 on Dea.location = Vac.location and
 Dea.date = Vac.date
 where Dea.continent is not null
 select *, (rollingpeoplevaccinated/population)*100 from #percentagepopulationvaccinated

 --creating view and to use later for visualizations

 create view percentagepopulationvaccinated as
 select Dea.continent, Dea.location, Dea.date, Dea.population, 
 Vac.new_vaccinations,
 sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingpeoplevaccianted
 from [Portofolio Project]..CovidDeaths as Dea
 join [Portofolio Project]..CovidVaccinations as Vac
 on Dea.location = Vac.location and
 Dea.date = Vac.date
 where Dea.continent is not null

 select * from percentagepopulationvaccinated