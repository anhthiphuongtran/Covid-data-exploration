/*
COVID 19 DATA EXPLORATION

SKILLS USED: JOINS, CTE'S, TEMP TABLES, WINDOW FUNCTIONS, AGGREGATE FUNCTIONS, CREATING VIEWS, CONVERTING DATA TYPES
*/


-- FIRST, LET'S EXPLORE THE DATASET ABOUT COVIDDEATHS

SELECT * FROM dbo.CovidDeaths 
ORDER BY date




-- FIND THE PERCENTAGE OF POPULATION INFECTED WITH COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths 
ORDER BY PercentPopulationInfected DESC





-- CALCULATE THE LIKELIHOOD OF DYING OF CONTRACTING COVID IN VIETNAM

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location = 'Vietnam'
ORDER BY Date

-- According to the processed data, the highest death percentage in Vietnam was around 3.3%, recorded in September 2020. 




-- NOW, LET'S LOOK MORE CLOSELY AT CONTINENTS.

SELECT * FROM dbo.CovidDeaths
WHERE continent IS NULL

-- Where continent is null, location shows either continent names or population categorized by income.




-- EXAMINE DIFFERENT SEGMENTS OF WORLD POPULATION

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Europe has the highest total death count amongst the continents while Africa and Oceania show the lowest figures.
-- With regards to income categorization, the number of deaths in high income group is highest, falling respectively from upper middle income, lower middle income to income groups.




-- EXAMINE THE DATASET ABOUT COVID VACCINATIONS

SELECT * FROM dbo.CovidVaccinations 
ORDER BY location, date





-- SHOW PERCENTAGE OF POPULATION THAT HAS RECIEVED AT LEAST ONE COVID VACCINE.

SELECT dea.location, dea.date, dea.population, vac.people_vaccinated
, CONVERT(float, vac.people_vaccinated)/CONVERT(float, dea.population) AS PercentVaccinated
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date 




-- SHOW THE ACCUMULATED NUMBER OF VACCINATIONS AND THE AVERAGE NUMBER OF VACCINES TAKEN PER INDIVIDUAL IN VIETNAM IN COMPARISON WITH THAILAND AND CHINA OVER TIME

SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS AccumulatedVaccinations
, (SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)/dea.population) AS VaccinesPerHead
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.location IN ('Vietnam', 'Thailand', 'China')
ORDER BY dea.location





-- USE CTE TO CALCULATE THE AVERAGE NUMBER OF COVID TESTS TAKEN BY EACH INDIVIDUAL
WITH TestedPopulation (Country, Date, Population, New_tests, Accumulated_tests)
AS(
SELECT dea.location, dea.date, dea.population, vac.new_tests
, SUM(CONVERT(float, vac.new_tests)) OVER (PARTITION BY dea.location ORDER BY dea.date)
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Accumulated_tests/Population)  AS Mean_tests_per_individual
FROM TestedPopulation




-- USE TEMP TABLE TO COMPARE THE PROPORTION OF HANDWASHING FACILITIES AVAILABLE AND PERCENTAGE OF COVID INFECTED POPULATION IN EACH COUNTRY.

DROP TABLE IF EXISTS #HandWashingvsCovid

CREATE TABLE #HandWashingvsCovid (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
TotalCovidCases numeric,
HandWashingFacilities float,
PercentPopulationInfected float,
)

INSERT INTO #HandWashingvsCovid
SELECT dea.continent, dea.location, dea.date, dea.population, dea.total_cases, vac.handwashing_facilities,
CONVERT(float, dea.total_cases)/CONVERT(float, dea.population)*100
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
ORDER BY 2, 3

SELECT * FROM #HandWashingvsCovid




-- CREATE VIEW TO STORE DATA ABOUT COVID DEATH RATES VERSUS CARDIOVASCULAR DEATH RATES

DROP VIEW IF EXISTS [Covid Versus Cardiovascular Deaths]

CREATE VIEW [Covid Versus Cardiovascular Deaths] AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, vac.cardiovasc_death_rate
, CONVERT(float, dea.total_deaths)/CONVERT(float, dea.population)*100 AS Covid_death_rate
, CONVERT(float, vac.cardiovasc_death_rate)/CONVERT(float, dea.population)*100 AS Cardiovascular_death_rate
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM [Covid Versus Cardiovascular Deaths]