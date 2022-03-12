select * from DataAnalysisPortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

select * from DataAnalysisPortfolioProject..CovidDeaths 
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population from DataAnalysisPortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

-- 1. Total cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from DataAnalysisPortfolioProject..CovidDeaths 
where location like '%bangladesh%' and continent is not null 
order by 1,2

-- 2. Total cases vs Population

select Location, date, Population, total_cases, (total_cases/population)*100 as Population_Percentage 
from DataAnalysisPortfolioProject..CovidDeaths 
where location like '%bangladesh%' and continent is not null 
order by 1,2

-- 3. Contries Highest Infection Rate vs Population 

select Location, Population,date, MAX(total_cases) as Highest_Infection, MAX((total_cases/population))*100 as Population_Infected_Percentage 
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is not null
group by population,location,date
order by Population_Infected_Percentage desc

select Location, SUM(cast (new_deaths as int)) as Total_Death 
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is null
and location not in ('Low income','Lower middle income','High income','Upper middle income','World', 'European Union', 'International')
group by location
order by Total_Death desc


-- 4. Countries Highest Death per Population

select Location, MAX(cast (total_deaths as int)) as Highest_Death 
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is not null
group by location
order by Highest_Death desc

-- 5. Check with Continent

select continent, MAX(cast (total_deaths as int)) as Highest_Death 
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is not null
group by continent
order by Highest_Death desc

-- 6. Continent vs Highest Death per Population 

select continent, MAX(cast (total_deaths as int)) as Highest_Death 
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is not null
group by continent
order by Highest_Death desc

-- 7. Continent vs Highest Death per Population 

select continent, SUM(new_cases) as Sum_Cases 
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is not null
group by continent
order by Sum_Cases desc

-- 8. Showing Total Cases, Total Death and Death Percentge 

select SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_Deaths, SUM(new_cases)/SUM(cast(new_deaths as int)) as Death_Percentage
from DataAnalysisPortfolioProject..CovidDeaths
-- where location like '%bangladesh%'
where continent is not null
-- group by date
order by 1,2

select * from DataAnalysisPortfolioProject..CovidVaccinations 
where continent is not null
order by 3,4

-- 9. Join CovidDeath Dataset and CovidVaccinations Dataset

select * from DataAnalysisPortfolioProject..CovidDeaths dea
join DataAnalysisPortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date

-- 10. Total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations  from DataAnalysisPortfolioProject..CovidDeaths dea
join DataAnalysisPortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- 11. Total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vaccination
 from DataAnalysisPortfolioProject..CovidDeaths dea
join DataAnalysisPortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- 12. Use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations,Rolling_Vaccination)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vaccination
 from DataAnalysisPortfolioProject..CovidDeaths dea
join DataAnalysisPortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_Vaccination/population)*100 from PopvsVac

Drop Table if exists #PercentPopulationVaccinated

-- 13.Temp Table 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric,
Rolling_Vaccination numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vaccination
 from DataAnalysisPortfolioProject..CovidDeaths dea
join DataAnalysisPortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *,(Rolling_Vaccination/population)*100 from #PercentPopulationVaccinated

-- 14. Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vaccination
 from DataAnalysisPortfolioProject..CovidDeaths dea
join DataAnalysisPortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *from PercentPopulationVaccinated