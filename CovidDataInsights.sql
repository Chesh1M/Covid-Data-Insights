
--Select *
--From CovidInsights..CovidDeaths
--order by 3,4

-- Data that will be used
Select location, date, total_cases, new_cases, total_deaths, population
From CovidInsights..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths from start till now
-- Likelihood of dying from Covid in SG
Select location, date, total_cases, total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From CovidInsights..CovidDeaths
Where location like '%Singapore%'
order by 1,2


-- Total Cases vs Population from start till now
-- Percentage of population of specific country that gotten covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopnInfected
From CovidInsights..CovidDeaths
Where location like '%Singapore%'
order by 1,2


-- Percentage of population infected of all countries
Select location, population, Max(total_cases) as NumberOfInfectionsToDate, Max(total_cases/population)*100 as PercentOfPopnInfected
From CovidInsights..CovidDeaths
Where continent is not null
Group by location, population
order by PercentOfPopnInfected desc


-- Covid deaths to date per COUNTRY
Select location, Max(Cast(total_deaths as float)) as NumberOfDeathsToDate
From CovidInsights..CovidDeaths
Where continent is not null
Group by location
order by NumberOfDeathsToDate desc


-- Covid death percentage in the World
Select location, population, Max(Cast(total_deaths as int)) as TotalDeaths, Max(total_deaths/population)*100 as DeathPercentage
From CovidInsights..CovidDeaths
Where location like '%world%'
Group by location, population


-- Percentage of people who got covid, and percentage of people who got covid AND actually died from it per country
Select location, population, Max(Cast(total_cases as float)) as NumberOfInfectionsToDate, Max(Cast(total_deaths as float)) as NumberOfDeathsToDate, Max(total_cases/population)*100 as PercentOfPopnInfected, (Max(Cast(total_deaths as float))/Max(Cast(total_cases as float)))*100 as PercentInfectedThatDied
From CovidInsights..CovidDeaths
Where continent is not null
Group by location, population
order by PercentOfPopnInfected desc


-- Covid death percentage per CONTINENT
Select location, population, Max(Cast(total_deaths as float)) as NumberOfDeathsToDate, (Max(Cast(total_deaths as float))/population)*100 as DeathPercentage
From CovidInsights..CovidDeaths
Where continent is null and (location = 'Asia' or location = 'Europe' or location = 'North America' or location = 'South America' or location = 'Oceania' or location = 'Africa')
Group by location, population
order by NumberOfDeathsToDate desc



-- GLOBAL NUMBERS

-- Covid death percentage in the World
Select location, population, Max(Cast(total_deaths as int)) as TotalDeaths, Max(total_deaths/population)*100 as DeathPercentage
From CovidInsights..CovidDeaths
Where location like '%world%'
Group by location, population


-- Death Percentage per day 
Select date, Sum(Cast(new_cases as int)) as TotalCasesPerDay, Sum(Cast(new_deaths as int)) as NewDeaths, (Sum(Cast(new_deaths as float))/Sum(Cast(new_cases as float)))*100 as DeathPercentage
From CovidInsights..CovidDeaths
where continent is not null and new_cases != '0'
Group by date
order by 1,2


-- Total Cases vs Total Deaths from start till now
-- Likelihood of dying from Covid in general
Select date, Sum(Cast(total_cases as int)) as TotalCases, Sum(Cast(total_deaths as int)) as TotalDeaths, (Sum(Cast(total_deaths as float))/Sum(Cast(total_cases as float)))*100 as DeathPercentage
From CovidInsights..CovidDeaths
Where continent is not null
group by date
order by 1,2
-- ## Death percentage steady increase till end april 2020 (peak 7.9%), after which steady decline until now
-- ## Peak coincides with timing where global lockdowns started
-- ## Mortality rate now at less than 1%.


-- Percentage of global population that has gotten covid
Select date, Sum(population) as GlobalPopulation, Sum(Cast(total_cases as int)) as TotalInfectedTillDate, (Sum(Cast(total_cases as float))/Sum(population))*100 as PercentInfectedTillDate
From CovidInsights..CovidDeaths
Where continent is not null
Group by date
Order by date


-- Percentage of global population that has gotten covid and percentage of global population that died
Select date, Sum(population) as GlobalPopulation, Sum(Cast(total_cases as int)) as TotalInfectedTillDate, Sum(Cast(total_deaths as int)) as TotalDeathsTillDate, (Sum(Cast(total_cases as float))/Sum(population))*100 as PercentInfectedTillDate, (Sum(Cast(total_deaths as int))/Sum(population))*100 as PercentDiedTillDate
From CovidInsights..CovidDeaths
Where continent is not null
Group by date
Order by date


-- Joining tables
-- Number of vaccinations vs population per country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsTillDate
From CovidInsights..CovidDeaths dea
Join CovidInsights..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
Order by 2,3


-- NUMBER OF VACCINATIONS VS POPULATION (rolling count)
-- Using CTE 
With PopvsVaccinations (Continent, Location, Date, Population, New_Vaccinations, VaccinationsTillDate)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsTillDate
From CovidInsights..CovidDeaths dea
Join CovidInsights..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
)
Select *, (VaccinationsTillDate/Population)*100 as VacToPopulationPercentage
From PopvsVaccinations
-- ## Percentage will exceed 100% because 1 individual can get more than 1 vaccination shot

-- Using Temporary Tables
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVacs numeric,
VaccinationsTillDate numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsTillDate
From CovidInsights..CovidDeaths dea
Join CovidInsights..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
-- End of table (can be placed at top of file if wanted to)

Select *, (VaccinationsTillDate/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated
Order by 2,3


-- VIEWS
-- POPULATION VS NUMBER OF VACCINATIONS
Create View PopvsVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsTillDate
From CovidInsights..CovidDeaths dea
Join CovidInsights..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null


-- Total Cases vs Total Deaths from start till now
-- Likelihood of dying from Covid in general
Create View DailyDeathsToTotalCasesPercentageGlobal as
Select date, Sum(Cast(total_cases as int)) as TotalCases, Sum(Cast(total_deaths as int)) as TotalDeaths, (Sum(Cast(total_deaths as float))/Sum(Cast(total_cases as float)))*100 as DeathPercentage
From CovidInsights..CovidDeaths
Where continent is not null
group by date
order by 1,2 offset 0 rows