/*

Queries used to generate data for Tableau Visualisation

*/


-- 1. Calculate the total cases, total deaths and death percentage for the whole population.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dbo.CovidDeaths
where continent is not null 



-- 2. Calculate the total death count for each continent.

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NULL
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC



-- 3. Calculate the percentage of population infected by Covid in each location

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- 4. Calculate the percentage of population infected by Covid in each location each day

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

