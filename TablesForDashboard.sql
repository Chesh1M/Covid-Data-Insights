-- Views for visualization

-- 1. Worldwide percentage of people that got covid who died 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidInsights..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--2. Number of deaths by continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidInsights..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income', 'World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Percent of population that got infected per country
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidInsights..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Infected population percentage data over time by country
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidInsights..CovidDeaths
Where location like '%sing%'
Group by Location, Population, date
order by PercentPopulationInfected desc