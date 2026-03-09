-- Select basic columns from the CovidDeaths table

SELECT location, date, total_deaths, new_cases, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;


-- Compare total cases per million vs total deaths per million to calculate death ratio

SELECT location, date, total_cases_per_million, total_deaths_per_million,
       (total_deaths_per_million / total_cases_per_million) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;


-- Calculate approximate percentage of population infected

SELECT location, date, total_cases_per_million, population,
       (total_cases_per_million / 1000000) * 100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;


-- Calculate infection percentage specifically for the United States

SELECT location, date, total_cases_per_million, population,
       (total_cases_per_million / 1000000) * 100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY location, date;


-- Find countries with the highest infection rate compared to population

SELECT location,
       population,
       MAX(total_cases_per_million) AS HighestInfectionCount,
       MAX(total_cases_per_million / 1000000) * 100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC;


-- Show countries with the highest total death count

SELECT location,
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Show total death count aggregated by continent

SELECT continent,
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death rate (% of population)
SELECT continent,
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount,
       MAX(CAST(total_deaths AS float) / population * 100) AS DeathRatePercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathRatePercentage DESC;

-- Total Population vs Vaccinations (cumulative)

SELECT 
    DEA.continent,
    DEA.location,
    DEA.date,
    DEA.population,
    VAC.total_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS int)) 
        OVER (PARTITION BY DEA.location ORDER BY DEA.date ROWS UNBOUNDED PRECEDING) AS CumulativeVaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
    ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.location, DEA.date;


-- Create a temporary table to store population and cumulative vaccinations per country

CREATE TABLE #CovidVaccinationTemp
(
    continent NVARCHAR(50),
    location NVARCHAR(100),
    date DATE,
    population BIGINT,
    total_vaccinations BIGINT,
    cumulative_vaccinations BIGINT
);

-- Insert data into the temporary table

INSERT INTO #CovidVaccinationTemp (continent, location, date, population, total_vaccinations, cumulative_vaccinations)
SELECT 
    DEA.continent,
    DEA.location,
    DEA.date,
    DEA.population,
    VAC.total_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY DEA.location ORDER BY DEA.date ROWS UNBOUNDED PRECEDING) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
    ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.location, DEA.date;

-- Select from temporary table to check data

SELECT * FROM #CovidVaccinationTemp;

-- Create a permanent view for population vs cumulative vaccinations

CREATE VIEW CovidVaccinationTemp AS
SELECT 
    DEA.continent,
    DEA.location,
    DEA.date,
    DEA.population,
    VAC.total_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY DEA.location ORDER BY DEA.date ROWS UNBOUNDED PRECEDING) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
    ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL;



