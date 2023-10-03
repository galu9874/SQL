select * from PortfolioProject1..CovidDeaths
where continent is not null 
order by 3,4

select * from PortfolioProject1..CovidVaccinations 
where continent is not null
order by 3,4

--Select the data that we're going to be using 
select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject1..CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject1..CovidDeaths
where location like 'Bulgaria'
order by 1, 2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid
select 
	location, 
	date, 
	population, 
	total_cases, 
	((total_cases*1.0)/population)*100 as "TotalCases%"
from PortfolioProject1..CovidDeaths
where location like 'Bulgaria'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
select
	location, 
	population, 
	MAX(total_cases) as HighestInfectonCount, 
	MAX(((total_cases*1.0)/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where continent is not null
group by population, location
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select 
	location,
	MAX(total_deaths) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Showing continents with the highest death count per population
select 
	continent,
	MAX(total_deaths) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select 
	sum(new_cases) as Total_Cases, 
	sum(new_deaths) as Total_Deaths,
	Sum(new_deaths)/(sum(new_cases))*100 as Death_Percentage
from PortfolioProject1..CovidDeaths
where continent is not null


--Looking at Total Population vs Vaccinations
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date)
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Looking at Total Population vs Vaccinations in Bulgaria
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location like 'Bulgaria'
order by 2, 3

--Create Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
	(continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location like 'Bulgaria'
--order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated 
from #PercentPopulationVaccinated

--Creating View to store data for later vizualizations
Create view PercentPopulationVaccinated as 
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location like 'Bulgaria'
--order by 2, 3

select * from PercentPopulationVaccinated
