-- select the data Im going to use
--select location,date,total_cases,total_deaths
--from PortfolioProject..CovidDeaths$
--order by 1,2

---- look into the Deathrate
--SELECT location,date,total_cases,total_deaths,
--    CASE 
--        WHEN total_cases = 0 THEN 0
--        ELSE (total_deaths / total_cases) * 100
--    END AS Deathpercentage
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1, 2;

---- look into the infectionrate
--SELECT location,date,population,total_cases,(total_cases/population) * 100 AS Infectionrate
--FROM PortfolioProject..CovidDeaths
--Where location = 'United States'
--ORDER BY 1, 2;


---- look into the countries with highest infectionrate
--SELECT location,population,
--	MAX(total_cases) AS total_cases,
--	MAX(total_cases/population) * 100 AS Infectionrate
--	--(total_deaths / total_cases) * 100 AS Deathpercentage
--FROM PortfolioProject..CovidDeaths
--group by location,population 
--ORDER BY Infectionrate desc;

---- look into the countries with highest Deathcount
--SELECT 
--	location,
--	MAX(CAST(total_deaths AS bigint))AS total_deaths_count,
--	MAX(total_deaths / population) *100 AS DeathRate
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
--group by location,population 
--ORDER BY total_deaths_count desc;

---- break things down by continent
--SELECT 
--	location,
--	MAX(CAST(total_deaths AS bigint))AS total_deaths_count,
--	MAX(total_deaths / population) *100 AS DeathRate
--FROM PortfolioProject..CovidDeaths
--Where continent is  null
--group by location
--ORDER BY total_deaths_count desc;

---- Global Numbers
--SELECT 
--	date,
--	SUM(new_cases) AS total_cases,
--	SUM(cast(new_deaths as bigint)) AS total_deaths,
--	SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS DeathRate
--	--total_cases,
--	--total_deaths,
--	--(total_deaths / total_cases) *100 AS DeathRate
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
--Group by date
--ORDER BY 1,2

--SELECT 
--	--date
--	SUM(new_cases) AS total_cases,
--	SUM(cast(new_deaths as bigint)) AS total_deaths,
--	SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS DeathRate
	
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
----Group by date
--ORDER BY 1,2;


-------------------

---- looking at total population VS vaccinations
--select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--FROM PortfolioProject..CovidDeaths dea
--Join PortfolioProject..covidvaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3;

--select 
--	dea.continent,
--	dea.location,
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	sum(convert(int,vac.new_vaccinations))over (Partition by dea.location order by dea.location,dea.date) as Vaccination_counts,
--(Vaccination_counts/population)*100 as Vaccination_Rate
--FROM PortfolioProject..CovidDeaths dea 
--Join PortfolioProject..covidvaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3;


-- use cte

--with PopvsVac (continent,location,date,population,new_vaccinations,Vaccination_counts)
--as
--(
--select 
--	dea.continent,
--	dea.location,
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	sum(convert(int,vac.new_vaccinations))over (Partition by dea.location order by dea.location,dea.date) as Vaccination_counts

--FROM PortfolioProject..CovidDeaths dea 
--Join PortfolioProject..covidvaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null

--)
--Select *,(Vaccination_counts/Population)*100 as Vaccination_Rate
--from PopvsVac


-- Using CTE to perform Calculation on Partition By in previous query

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Vaccination_counts
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3
--)
--Select *,(Vaccination_counts/Population)*100
--from PopvsVac

-- Using CTE to perform Calculation on Partition By in previous query

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3
--)
--Select *, (RollingPeopleVaccinated/Population)*100
--From PopvsVac


---- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table if exists #PercentPopulationVaccinated
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--Insert into #PercentPopulationVaccinated
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
----where dea.continent is not null 
----order by 2,3

--Select *, (RollingPeopleVaccinated/Population)*100
--From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
USE PortfolioProject 
GO 
Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select*
from PercentPopulationVaccinated2