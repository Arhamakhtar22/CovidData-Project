show databases;
create database covidinfo;
show databases;

-- Total cases vs total deaths in USA

SELECT location, date, total_cases, total_deaths, (CovidDeaths.total_deaths/CovidDeaths.total_cases)* 100 as DeathPercentage
FROM covidinfo.CovidDeaths
WHERE location like "%states%"
ORDER BY 1,2;

-- Total cases vs Population in USA
-- shows what percentage of population got Covid

SELECT location, date, total_cases, population, (CovidDeaths.total_cases/CovidDeaths.population)* 100 as PercentagePopulation
FROM covidinfo.CovidDeaths
WHERE location like "%states%"
ORDER BY total_cases;

-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestNoOfCases, (MAX(CovidDeaths.total_cases)/CovidDeaths.population)* 100 as PercentagePopuation
FROM covidinfo.CovidDeaths
GROUP BY Location, population
ORDER BY  PercentagePopuation desc;

-- Countries with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as unsigned )) as DeathCount
FROM covidinfo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount desc;

-- by continent

SELECT location, MAX(cast(total_deaths as unsigned )) as DeathCount
FROM covidinfo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY DeathCount desc;

-- showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as unsigned )) as DeathCount
FROM covidinfo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount desc;

-- numbers by date

SELECT date, MAX(new_cases) as total_cases, SUM(cast(new_deaths as unsigned )) as total_deaths, (sum(cast(CovidDeaths.total_deaths as unsigned ))/sum(CovidDeaths.total_cases))*100 as DeathPercentage
FROM covidinfo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- amount of ppl in the world that are vaccinated using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Totalvaccinated)
    as (SELECT dea.continent,
               dea.location,
               dea.date,
               dea.population,
               vac.new_vaccinations,
               SUM(cast(vac.new_vaccinations as unsigned))
                   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Totalvaccinated
        FROM covidinfo.CovidDeaths dea
                 JOIN covidinfo.CovidVaccination vac
                      ON dea.location = vac.location
                          and dea.date = vac.date
        WHERE dea.continent is not null
)
SELECT *,(Totalvaccinated/population)* 100 AS PopVaccinated FROM PopvsVac



CREATE VIEW covidinfo.deathbycontinent AS
SELECT continent, MAX(cast(total_deaths as unsigned )) as DeathCount
FROM covidinfo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount desc;
