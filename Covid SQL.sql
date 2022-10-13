--Looking at Total Cases vs Total Deaths
SELECT 
  location, date, total_cases, total_deaths, 
  (total_deaths/total_cases)*100 AS death_percentage
FROM 
  Covid.CovidDeaths
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of contracting covid in your country
SELECT location, date, total_cases, total_deaths, 
  (total_deaths/total_cases)*100 AS death_percentage
FROM 
  Covid.CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Shows what % of population got Covid
SELECT 
  location, date, total_cases, population, 
  (total_cases/population*100) AS covid_percentage
FROM 
  Covid.CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2;

--Looking at countries with Highest Infection Rate compared to Population
SELECT 
  location, max(total_cases) AS highest_infection_count, population, date, 
  Max((total_cases/population)*100) AS PercentPopulationInfected
FROM 
  Covid.CovidDeaths
WHERE 
  date between '2020-01-01' and '2022-09-17'
GROUP BY
  location, population, date
ORDER BY PercentPopulationInfected DESC;

--Showing countries with Highest Death Count per Country
SELECT 
  location, max(total_deaths) AS total_death_count
FROM 
  Covid.CovidDeaths
WHERE continent is not NULL
  and location not in ('World', 'European Union', 'International')
--WHERE location like '%States%'
GROUP BY
  location
ORDER BY total_death_count DESC;

--Let's break things down by Continent
SELECT 
  location, max(total_deaths) AS total_death_count
FROM 
  Covid.CovidDeaths
WHERE continent is NULL
  and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
--WHERE location like '%States%'
GROUP BY
  location
ORDER BY total_death_count DESC;

--Global Numbers by Date
SELECT 
  date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
  (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM 
  Covid.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2;

--Global Death Rate to date
SELECT 
  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
  (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM 
  Covid.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
ORDER BY 1,2;

--Looking at Total Vaccinations vs Population
--Use CTE
WITH PopvsVac AS
(
SELECT
  death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
  SUM(vacc.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM
  Covid.CovidDeaths death
JOIN Covid.CovidVaccinations vacc
  ON death.location = vacc.location
  and death.date = vacc.date
WHERE death.continent is not NULL and vacc.new_vaccinations is not NULL
--ORDER BY 2,3
)

SELECT *,
  (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopvsVac;

