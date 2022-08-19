/*Queries Used for Tableu Dashboard Visualization
As I have Tableau Desktop installed, I have directly connected Sql Server Management Studio to Tableau with windows credentials
and these queries resulted tables which are connected to each other in Tableau */

Use PortfolioProject

--1
Select continent, 
		Location, 
		date, 
		new_cases, 
		CAST(new_deaths as float) AS new_deaths
From CovidDeaths
Where continent is NOT null

--2
SELECT location, 
		population
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY location, population

--3
Select location, 
		SUM(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')
Group by location

--4
SELECT DISTINCT CONTINENT
 FROM CovidDeaths
 WHERE CONTINENT IS NOT NULL

--5
SELECT location, 
		MAX(CAST(total_vaccinations as float)) AS Total_Vaccinations,
		MAX(CAST(people_vaccinated as int)) AS Half_vaccinated,
		MAX(CAST(people_fully_vaccinated as int)) AS Full_Vaccinated
FROM Covidvaccination
WHERE continent IS NOT NULL  
GROUP BY location
HAVING  MAX(CAST(total_vaccinations as float)) IS NOT NULL

--6
SELECT location, 
		date,
		ROUND(CAST(new_tests AS float),2) AS Total_Tests
FROM Covidvaccination
WHERE continent IS NOT NULL
