/* Covid-19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Subqueries, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types*/

Use PortfolioProject

/*We have two datasets and CovidDeaths has data related to cases,deaths due to covid 
whereas CovidVaccination table describes vaccination details for whole world

Here We are exploring data and finding insights which we can be extracted to Tableau to build dashboards*/

-- Selecting the data which we are going to use

SELECT continent, location, date, population, new_cases, total_cases, new_deaths, total_deaths
FROM CovidDeaths
ORDER BY location,date;

SELECT continent, location, date, people_vaccinated, people_fully_vaccinated, new_vaccinations, total_vaccinations, total_tests
FROM Covidvaccination
ORDER BY location,date;

-- We have found that continent has null value which we have to eliminate in every query

SELECT Distinct continent
FROM CovidDeaths;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Continent, 
		location, 
		MAX(population) AS Population, 
		MAX(total_cases) as Total_Cases, 
		MAX(cast(total_deaths as int)) as Total_Deaths, 
		ROUND((MAX(cast(total_deaths as int))/MAX(total_cases)*100), 4) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND location = 'Canada'
GROUP BY Continent, location
ORDER BY Continent, location;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid and shows countries with highest infection rate

SELECT Continent, 
		location, 
		MAX(population) AS Population, 
		MAX(total_cases) as Total_Cases,
		ROUND((MAX(total_cases)/Max(population)*100), 4) AS Infected_population_percentage
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY Continent, location
ORDER BY Infected_population_percentage DESC;

-- We can see same population count is present for all the rows for that specific country so here we grouping population by country
-- We can use this table in Tableau Dashboards

SELECT continent, location, population
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY continent, location, population

-- Countries with Highest Death Count per Population

Select location, 
		SUM(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- Continents with Highest Death Count per Population
Select Continent, 
		SUM(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Continent
order by TotalDeathCount desc

-- Also there is null value in continent so here we are checking what corresponding it have
Select location, 
		SUM(CAST(total_deaths as float)) as TotalDeathCount
From CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc

-- If we clear some things like income range from above query then we can get actual deathcount of continents

Select location, 
		SUM(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
		and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


-- Now we are checking vaccination table and it shows how many people half vaccinated, full vaccinated and also full vaccination rate
SELECT Continent,
		location, 
		MAX(CAST(total_vaccinations as float)) AS Total_Vaccinations,
		MAX(CAST(people_vaccinated as int)) AS Half_vaccinated,
		MAX(CAST(people_fully_vaccinated as int)) AS Full_Vaccinated,
		ROUND((MAX(CAST(people_fully_vaccinated as int))/MAX(population)*100), 4) AS FullVaccination_Rate
FROM Covidvaccination
WHERE continent IS NOT NULL
GROUP BY Continent, location
ORDER BY Continent, location;



-- Using Subquery, Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, 
		(RollingPeopleVaccinated/population)*100 AS Single_vaccine_percentage
FROM (
	Select CD.continent, 
			CD.location, 
			CD.date, 
			CD.population, 
			CV.new_vaccinations,
			SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated,
			total_vaccinations
	From CovidDeaths CD
	Join CovidVaccination CV
		On CD.location = CV.location
		and CD.date = CV.date
	where CD.continent is not null AND CD.location = 'INDIA') Sub;


-- Using CTE to perform the same operation as same query

WITH CTE AS 
	(Select CD.continent, 
			CD.location, 
			CD.date, 
			CD.population, 
			CV.new_vaccinations,
			SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated,
			total_vaccinations
	From CovidDeaths CD
	Join CovidVaccination CV
		On CD.location = CV.location
		and CD.date = CV.date
	where CD.continent is not null AND CD.location = 'INDIA')
SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, 
		(RollingPeopleVaccinated/population)*100 AS Single_vaccine_percentage
FROM CTE


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
		Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		Population numeric,
		New_vaccinations numeric,
		RollingPeopleVaccinated float
	)

Insert into #PercentPopulationVaccinated
	Select CD.continent, 
			CD.location, 
			CD.date, 
			CD.population, 
			CV.new_vaccinations,
			SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
	From CovidDeaths CD
	Join CovidVaccination CV
		On CD.location = CV.location AND CD.date = CV.date

Select *, (RollingPeopleVaccinated/Population)*100 AS Single_vaccine_percentage
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
	Select CD.continent, 
			CD.location, 
			CD.date, 
			CD.population, 
			CV.new_vaccinations,
			SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated,
			total_vaccinations
	From PortfolioProject..CovidDeaths CD
	Join PortfolioProject..CovidVaccination CV
		On CD.location = CV.location
		and CD.date = CV.date
	where CD.continent is not null


