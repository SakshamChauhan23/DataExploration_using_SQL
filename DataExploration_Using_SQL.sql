select *
from [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
where continent is not null
order by 3,4

--Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total deaths, population
From [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
where continent is not null
order by 1,2

--Total Cases Vs Total Deaths 
--Shows likelihood of dying if you contact covid in your country

Select Location, date, population, total_cases, total deaths, (total_cases/population)*100 as Percentpopulationinfected
From [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
--Where location like '%states%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as Percentpopulationinfected
From [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
--Where location like '%states%'
order by location, population
order by Percentpopulationinfected desc

--Countries with Highest Death Count compared to Population

Select Location, MAX(cast(Total_deaths as int))as TotalDeathCount
From [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT
--Showing Continents with the highest death count per populatio

Select Location, MAX(cast(Total_deaths as int))as TotalDeathCount
From [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Total Population Vs Vaccinations
--Shows percentage of Population that has recieved at least one Covid Vaccine

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$ dea

Join [Portfolio_Project_SQL(Data_Exploration)]..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USING CTE to perform Calculations on Partition by in previous query 
with PopVsVac (Continent, Location, date, Population, New_Vaccination, RollingPeopleVaccinated) as 
(
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$ dea

Join [Portfolio_Project_SQL(Data_Exploration)]..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopVsVac


--Using Temp Table to perform Calculations on Partition by in Previous Query

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population Numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$ dea

Join [Portfolio_Project_SQL(Data_Exploration)]..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio_Project_SQL(Data_Exploration)]..CovidDeaths$ dea

Join [Portfolio_Project_SQL(Data_Exploration)]..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null