select*
from dbo.CovidDeaths
order by 3,4

--select*
--from dbo.CovidVacinations
--order by 3,4

select [location], [date], total_cases,new_cases, total_deaths, population 
from dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.CovidDeaths
where location like '%Macedonia%'
order by 1,2

--looking at total cases vs population
--show what percentage of population got Covid

Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
from dbo.CovidDeaths
--where location like '%Macedonia%'
order by 1,2

--Looking at countries with highest infection rate compared to population 

Select location, population,  MAX(total_cases) as HighestInfectionCount,
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(population)), 0)) * 100 AS PercentPopulationInfected 
from dbo.CovidDeaths
--where location like '%Macedonia%'
group by Population, Location 
order by PercentPopulationInfected desc

--Showing countries with highest death count per population 

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null 
Group by Location
Order by TotalDeathCount desc 


--break it down by continent 

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null 
Group by continent 
Order by TotalDeathCount desc 

-- global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100 AS DeathPercentageGlobally
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;
   
--looking at total population vs vacinations

  --select*from dbo.CovidDeaths cd
  --inner join dbo.CovidVacinations cv
  --on cd.location = cv.location and cd.date=cv.date 

  

   select cd.continent, cd.location, cd.date, cd.population, cv.date, 
   sum(population) over (partition by cd.location order by cd.Location,cd.Date) as PeopleVaccinated
   from dbo.CovidDeaths cd
  inner join dbo.CovidVacinations cv
  on cd.location = cv.location and cd.date=cv.date 
  where cd.Continent is not null 

  -- Using CTE to see how many people in the country are vaccinated 

 ; with CTE (continent, [location], [date], [population], [cv.date], PeopleVaccinated)
  as
 (
  select cd.continent, cd.location, cd.date, cd.population, cv.date, 
   sum(population) over (partition by cd.location order by cd.Location,cd.Date) as PeopleVaccinated
   from dbo.CovidDeaths cd
  inner join dbo.CovidVacinations cv
  on cd.location = cv.location and cd.date=cv.date 
  where cd.Continent is not null 
 ) 
 
 select*, (PeopleVaccinated/Population)*100
 from CTE 

 --creating view to store data

 Create view PeopleVaccinated as
  select cd.continent, cd.location, cd.date, cd.population, 
   sum(population) over (partition by cd.location order by cd.Location,cd.Date) as PeopleVaccinated
   from dbo.CovidDeaths cd
  inner join dbo.CovidVacinations cv
  on cd.location = cv.location and cd.date=cv.date 
  where cd.Continent is not null 

  select*from PeopleVaccinated
