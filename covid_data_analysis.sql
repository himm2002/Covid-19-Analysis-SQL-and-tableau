CREATE DATABASE covid_19 ;
USE covid_19;
SELECT * FROM covid_19_records;
-- checking the null values in the dataset
SELECT * FROM covid_19_records
WHERE Province IS NULL OR
`Country/Region` IS NULL OR 
Latitude IS NULL OR
Longitude IS NULL OR 
Date IS NULL OR
Confirmed IS NULL OR
Deaths IS NULL OR
Recovered IS NULL ;

-- Replacing the null values of integer with 0
UPDATE 	covid_19_records
SET Confirmed = coalesce(Confirmed,0),
    Deaths = coalesce(Deaths,0),
    Recovered = coalesce(Recovered,0)
WHERE Confirmed IS NULL OR Deaths IS NULL OR Recovered IS NULL;

-- No null values are present 

-- checking the number of rows 
SELECT COUNT(*) AS Total_rows FROM covid_19_records;
-- checking the start date and end date of record
ALTER TABLE covid_19_records
MODIFY Date date;
SELECT MIN(Date) AS start_date, MAX(Date) AS end_date FROM covid_19_records;

-- Number of months present in the dataset
SELECT COUNT(DISTINCT MONTH(Date)) AS Num_months FROM covid_19_records;

-- Find the monthly average for confirmed deaths and recovered
SELECT YEAR(Date) AS Year,
       MONTH(Date) AS Month_Num,
       AVG(Confirmed) AS Confirmed_average,
       AVG(Deaths) AS Deaths_average,
       AVG(Recovered) AS Recovered_average
       FROM covid_19_records
GROUP BY Year,Month_Num;

-- Find the most frequent values for confirmed, deaths and recovered
SELECT YEAR(Date) AS Year,
       MONTH(Date) AS Month_Num,
       substring_index(GROUP_CONCAT(Confirmed ORDER BY Confirmed DESC),",",1) AS Most_freq_Confirmed,
       substring_index(GROUP_CONCAT(Deaths ORDER BY Deaths DESC),",",1) AS Most_freq_Deaths,
       substring_index(GROUP_CONCAT(Recovered ORDER BY Recovered DESC),",",1) AS Most_freq_Recovered
       FROM covid_19_records
GROUP BY Year, Month_Num
ORDER BY Year, Month_Num;

-- Find the minimum values for confirmed,deaths,recovered per year
SELECT YEAR(Date) AS Year,
       MIN(Confirmed) AS Min_Confirmed,
       MIN(Deaths) AS Min_Deaths,
       MIN(Recovered) AS Min_Recovered
       FROM covid_19_records
GROUP BY Year 
ORDER BY Year ASC;

-- Find the maximum values for same  3 columns per year
SELECT YEAR(Date) AS Year,
       MAX(Confirmed) AS Max_Confirmed,
       MAX(Deaths) AS Max_Deaths,
       MAX(Recovered) AS Max_Recovered
       FROM covid_19_records
GROUP BY Year 
ORDER BY Year ASC;

-- Find the total values values for each month
SELECT YEAR(Date) AS Year,
       MONTH(Date) AS Month_Num,
       SUM(Confirmed) AS Total_confirmed,
       SUM(Deaths) AS Total_Deaths,
       SUM(Recovered) AS Total_Recovered
       FROM covid_19_records
GROUP BY Year,Month_Num
ORDER BY Year, Month_Num;

-- Find the month which is having maximum total confirmed cases
SELECT Year,Month_Num,MAX(Total_Confirmed) AS Total_Cases FROM (SELECT YEAR(Date) AS Year,
       MONTH(Date) AS Month_Num,
       SUM(Confirmed) AS Total_confirmed,
       SUM(Deaths) AS Total_Deaths,
       SUM(Recovered) AS Total_Recovered
       FROM covid_19_records
GROUP BY Year,Month_Num
ORDER BY Year, Month_Num) AS Total_values
GROUP BY Year,Month_Num
ORDER BY Total_Cases DESC ;

-- Check how the covid 19 spread to confirmed cases e.g total covid 19 cases st dev and variance and average
SELECT SUM(Confirmed) AS Total_Cases,
       AVG(Confirmed) AS Average_Cases,
       ROUND(STDDEV(Confirmed),3) AS Stdev_confirmed_cases,
       ROUND(VARIANCE(Confirmed),3) AS Variance_Cases
       FROM covid_19_records;
-- check how the covid 19 spread with respect to deaths per each month ( same values as above)
SELECT YEAR(Date) AS Year,
       MONTH(Date) AS Month_num,
       SUM(Deaths) AS Total_Deaths,
       ROUND(AVG(Deaths),3) AS Average_Deaths,
       ROUND(STDDEV(DEATHS),3) AS Stdev_Deaths,
       ROUND(VARIANCE(DEATHS),3) AS Variance_Deaths
       FROM covid_19_records
GROUP BY Year,Month_Num
ORDER BY Year,Month_Num;

-- Check the spread of covid 19 with respect to recovered cases
SELECT SUM(Recovered) AS Total_Recovered,
       ROUND(AVG(Recovered),3) AS Average_Recovered,
       ROUND(STDDEV(Recovered),3) AS Stdev_Recovered,
       ROUND(VARIANCE(Recovered),3) AS Variance_Recovered
       FROM covid_19_records;
-- Find country having highest number of confirmed cases
SELECT `Country/Region`,
       SUM(Confirmed) AS Total_Confirmed_Cases
       FROM covid_19_records
GROUP BY `Country/Region`
ORDER BY Total_Confirmed_Cases DESC
LIMIT 1;
-- Find country having lowest number of deaths
WITH RankingCountry AS(
SELECT `Country/Region`,SUM(Deaths) AS Total_Deaths ,
RANK() OVER(ORDER BY SUM(Deaths) ASC) AS Rank_no
FROM covid_19_records
GROUP BY `Country/Region`)
SELECT `Country/Region`, Total_Deaths FROM RankingCountry 
WHERE Rank_no = 1;

-- Find the top 5 countries having highest number of recovered cases
SELECT `Country/Region`,
        SUM(Recovered) AS Total_recovered_cases
        FROM covid_19_records
GROUP BY `Country/Region`
ORDER BY Total_recovered_cases DESC
LIMIT 5;

-- Find the recovery percentage for each country % = recovered/total cases
SELECT `Country/Region`,Total_cases,Total_recovered_cases,(Total_recovered_cases/Total_cases)*100 AS Recovery_per 
FROM
  (SELECT `Country/Region`,
       SUM(Confirmed) AS Total_Cases,
       SUM(Recovered) AS Total_recovered_cases
       FROM covid_19_records
GROUP BY `Country/Region`) AS New_table
WHERE Total_Cases >5
GROUP BY `Country/Region`
ORDER BY Recovery_per DESC;

