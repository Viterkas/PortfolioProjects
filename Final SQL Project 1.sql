Select *
FROM [Portfolio Project]..['Covid Deaths']
Where continent is not null
Order By 3,4

Select *
FROM [Portfolio Project]..['Covid Vaccinations']
Order By 3,4

Select location, date, total_cases, new_cases, total_deaths,population
FROM [Portfolio Project]..['Covid Deaths']
Where continent is not null
Order by 1,2

-- Lookin total cases vs total deaths
-- Shows likelyhood of diying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float)*100 AS death_rate
FROM [Portfolio Project]..['Covid Deaths']
Where Location like '%spain%'
AND continent is not null
Order by 1,2

-- Looking at total cases vs population
-- Shows what rate of population got infected by covid

SELECT location, date, total_cases, population, CAST(total_cases AS float) / CAST(population AS float)*100 AS infection_rate
FROM [Portfolio Project]..['Covid Deaths']
Where Location like '%spain%'
AND continent is not null
Order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT
    location,
	population,
    MAX(total_cases) AS HighestInfectionCount,
    CAST(MAX(total_cases) AS float) / CAST(population AS float) * 100 AS PopulationInfectedRate
FROM
    [Portfolio Project]..['Covid Deaths']
--WHERE
--    location LIKE '%spain%'
Where continent is not null
GROUP BY
    location, population
ORDER BY
    PopulationInfectedRate desc


-- Countries with Highest Death Count per Population

SELECT
    location,
	MAX(Cast(total_deaths as float)) AS TotalDeathsCount
FROM
    [Portfolio Project]..['Covid Deaths']
--WHERE
--    location LIKE '%spain%'
Where continent is not null
GROUP BY
    location
ORDER BY
    TotalDeathsCount Desc

	

-- Let's see by CONTINENT
SELECT
    continent,
	MAX(Cast(total_deaths as float)) AS TotalDeathsCount
FROM
    [Portfolio Project]..['Covid Deaths']
--WHERE
--    location LIKE '%spain%'
Where continent is not null
GROUP BY
    continent
ORDER BY
    TotalDeathsCount Desc

-- Global numbers

	SELECT
    SUM(CAST(new_cases AS float)) AS total_cases, 
    SUM(CAST(new_deaths AS float)) AS total_deaths,
    SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0) * 100 AS death_rate
FROM
    [Portfolio Project]..['Covid Deaths']
ORDER BY
    1,2


-- Looking at total population vs vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Addition_per_new_vaccination
From [Portfolio Project].[dbo].['Covid Deaths'] Dea
Join [Portfolio Project].[dbo].['Covid Vaccinations'] Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not NULL 
Order by 2,3


-- Application of CTE 

With Popvsvac (continent, location, date, population, new_vaccinations, Addition_per_new_vaccination) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Addition_per_new_vaccination
From [Portfolio Project].[dbo].['Covid Deaths'] Dea
Join [Portfolio Project].[dbo].['Covid Vaccinations'] Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not NULL 
--Order by 2,3
)
Select * , (Addition_per_new_vaccination/population) * 100
From Popvsvac

-- TEMP TABLE 

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Addition_per_new_vaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Addition_per_new_vaccination
From [Portfolio Project].[dbo].['Covid Deaths'] Dea
Join [Portfolio Project].[dbo].['Covid Vaccinations'] Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not NULL 
--Order by 2,3	

Select * , (Addition_per_new_vaccination/population) * 100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Addition_per_new_vaccination
From [Portfolio Project].[dbo].['Covid Deaths'] Dea
Join [Portfolio Project].[dbo].['Covid Vaccinations'] Vac
	ON Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not NULL 
-- Order by 2,3	

Select * 
From PercentPopulationVaccinated