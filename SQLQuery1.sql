select *
from Covid_project.dbo.CovidDeaths$
order by 3,4

select location,date,population,total_cases,new_cases,total_deaths
from Covid_project.dbo.CovidDeaths$
order by 1,2


-- Looking at total cases vs total deaths, shows percentage of people dieing amidts getting affected by covid 


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Covid_project.dbo.CovidDeaths$
order by 1,2


-- Looking at India


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Covid_project.dbo.CovidDeaths$
where location in ('India')
order by 1,2


-- looking at Total_cases vs Population,shows what percentage of population got covid


select location,date,total_cases,population,(total_cases/population)*100 as populaion_percentage_infected
from Covid_project.dbo.CovidDeaths$
-- where location in ('India')
order by 1,2


-- Looking at countries with highest infection rate


select location, max((total_cases)) as highest_infection_count, population, max((total_cases/population))*100 as Infection_Rate
from Covid_project.dbo.CovidDeaths$
-- where location in ('India')
group by location,population
order by Infection_Rate desc


-- Showing Countries with Highest Death Count per population


select location, max(cast(total_deaths as int)) as highest_death_count
from Covid_project.dbo.CovidDeaths$
-- where location in ('India')
where continent is not null
group by location
order by highest_death_count desc;


-- Showing contintents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_project.dbo.CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- Global Numbers


Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_project.dbo.CovidDeaths$
where continent is not null 
Group By date
order by 1,2

-- Total NUmbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_project.dbo.CovidDeaths$
where continent is not null 
--Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


WITH VaccinationData AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int,vac.new_vaccinations)) 
        OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM 
        Covid_project.dbo.CovidDeaths$ dea
    JOIN 
        Covid_project.dbo.CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingPeopleVaccinated,
    (RollingPeopleVaccinated / population) * 100 AS VaccinationRate
FROM 
    VaccinationData
ORDER BY 
    location, date;



	-- using a temp table



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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_project.dbo.CovidDeaths$ dea
Join Covid_project.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100 as vaccination_rate
From #PercentPopulationVaccinated


-- Creating view for later visulaisaitons


Create View PercentPopulationVaccinateds as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From Covid_project.dbo.CovidDeaths$ dea
Join Covid_project.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

