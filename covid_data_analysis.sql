/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From CovidDeaths
where continent is not null
order by 3,4;


Select location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths
where continent is not null
Order by 1,2; 


-- Looking at Total Cases vs Total deaths
-- Shows likelihood of dying if you get covid in different countries

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
-- and location='India'
Order by 1,2;


-- Let's look at countries with highest Death Rate

Select location,max(total_cases) as TotalCases,max(cast(total_deaths as int)) as TotalDeaths,(max(cast(total_deaths as int))/max(total_cases))*100 as DeathPercentage
From CovidDeaths
where continent is not null
Group by location
Order by DeathPercentage desc;


-- Let's analyze the Death Rate according to continents 

Select location,max(total_cases) as TotalCases,max(cast(total_deaths as int)) as TotalDeaths,(max(cast(total_deaths as int))/max(total_cases))*100 as DeathPercentage
From CovidDeaths
where continent is null
and location not like 'World' and location not like 'International' and location not like 'European Union'
Group by location
Order by DeathPercentage desc;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected with Covid in different countries

Select location,date,population,total_cases,(cast(total_cases as decimal)/cast(population as decimal))*100 as PercentagePopulationInfected
From CovidDeaths
where continent is not null
-- and location='India'
Order by 1,2;


-- Let's look at countries with highest Infection Rate compared to Population

Select location,population,max(total_cases) as TotalCases,(max(total_cases)/population)*100 as PercentagePopulationInfected
From CovidDeaths
where continent is not null
group by location,population
Order by PercentagePopulationInfected desc;


-- Continents with highest infection rate in comparison population

Select location,population,max(total_cases) as TotalCases,(max(total_cases)/population)*100 as PercentagePopulationInfected
From CovidDeaths
where continent is null
and location not like 'World' and location not like 'International' and location not like 'European Union'
group by location,population
Order by PercentagePopulationInfected desc;


-- Showing countries with highest Death Count

Select location,max(convert(int,total_deaths)) as TotalDeathCount
From CovidDeaths
where continent is not null
group by location
Order by TotalDeathCount desc;


-- Let's break things down by Continent

Select location,max(convert(int,total_deaths)) as TotalDeathCount
From CovidDeaths
where continent is null 
and location not like 'World' and location not like 'International'  and location not like 'European Union'
group by location
Order by TotalDeathCount desc;


-- Looking at global numbers
-- World wide cases vs deaths

Select date,SUM(new_cases) as WorldWideCases,SUM(cast(new_deaths as int)) as WorldWideDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDeaths
where continent is not null
group by date
Order by 1;


-- Total Cases in World vs Deaths 

Select SUM(new_cases) as WorldWideCases,SUM(cast(new_deaths as int)) as WorldWideDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDeaths
where continent is not null;

Select *
From CovidVaccinations;


-- Looking at Total Population vs Vaccinations in different countries

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and dea.location = 'India'
order by 2,3;


-- Using CTE to show the percentage of population vaccinated in different countries

With PopvsVac ( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and dea.location = 'India'
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PopvsVac;


-- Let's look at percentage vaccination in different continents

Select dea.location,dea.population, MAX(cast(vac.total_vaccinations as numeric)) as VaccinatedPeopleCount
from CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null
and dea.location not like 'World' and dea.location not like 'International' and dea.location not like 'European Union'
group by dea.location,dea.population
order by 1;


-- Using TEMP TABLE to show Percentage of population vaccinated in different Continents

If OBJECT_ID ('tempdb..#PercentPeopleVaccinated') is not null 
DROP Table #PercentPeopleVaccinated

Create Table #PercentPeopleVaccinated 
(
location varchar(30),
population numeric,
VaccinatedPeopleCount numeric
)
insert into #PercentPeopleVaccinated
Select dea.location,dea.population, MAX(cast(vac.total_vaccinations as numeric)) as VaccinatedPeopleCount
from CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null
and dea.location not like 'World' and dea.location not like 'International' and dea.location not like 'European Union'
group by dea.location,dea.population;

Select location,population,VaccinatedPeopleCount, (VaccinatedPeopleCount/Population)*100 as PercentPopulationVaccinated
from #PercentPeopleVaccinated


-- Let's look at global Population vs Vaccinated Population

Select SUM(convert(numeric,new_vaccinations)) as WorldWideVaccinations
From CovidVaccinations
where continent is not null
--group by date
Order by 1;


-- Looking at Percent Global population vaccinated

Select dea.population as WorldPopulation, SUM(convert(numeric,vac.new_vaccinations)) as WorldWideVaccinations,(SUM(convert(numeric,vac.new_vaccinations))/ dea.population)*100 as PercentPopulationVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null
and dea.location like 'World'
Group by dea.Population;



































