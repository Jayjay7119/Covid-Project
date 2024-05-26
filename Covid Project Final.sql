/*
Covid 19 Data Exploration 

Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types

*/


SELECT *
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
Where continent is not null
Order By 3,4

-- SELECT *
-- From `covid-portfolio-project-424317.Covid_Project.CovidVaccinations`
-- Order By 3,4

-- Selecting Data that we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
Where continent is not null
Order By 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
Where location = 'United States'
  and continent is not null
Order By 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_infected
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
Where location = 'United States'
  and continent is not null
Order By 1,2

-- Looking at Contries with highest infection rate compared to population 

Select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
--Where location = 'United States'
Where continent is not null
GROUP BY Location, population
Order By Percent_Population_Infected desc

-- Showing Countries with highest death count per Population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
--Where location = 'United States'
Where continent is not null
GROUP BY Location
Order By Total_Death_Count desc

-- Breaking Things Down by Continent

-- Showing the Continets with the Highest Death Count per population

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
--Where location = 'United States'
Where continent is not null
GROUP BY continent
Order By Total_Death_Count desc 


-- Global Numbers

Select date, SUM(new_cases) as Total_Cases, Sum(CAST(new_deaths as int)) as Total_Deaths, 
  CASE WHEN SUM(new_cases) > 0 THEN  -- Check for non-zero cases before division
       Sum(CAST(new_deaths as int)) / SUM(new_cases)*100 
  ELSE 
       NULL  -- Set Death_Percentage to NULL for days with zero cases
  END AS Death_Percentage
From `covid-portfolio-project-424317.Covid_Project.CovidDeaths`
Where continent is not null
Group By date
Order By 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  Sum(Cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea. location,dea.date) As Rolling_People_Vaccinated
    --(Rolling_People_Vaccinated/population)*100

From `covid-portfolio-project-424317.Covid_Project.CovidDeaths` dea
Join `covid-portfolio-project-424317.Covid_Project.CovidVaccinations` vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Order BY 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

BEGIN
  CREATE TEMP TABLE PercentPopulationVaccinated (
    Continent STRING,
    Location STRING,
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    Rolling_People_Vaccinated NUMERIC); 

  INSERT INTO PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
  FROM `covid-portfolio-project-424317.Covid_Project.CovidDeaths` dea
  JOIN `covid-portfolio-project-424317.Covid_Project.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL;
END;
-- 
