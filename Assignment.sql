
-- ***INTRODUCTION*** 
-- In this task, we analyze the distribution of Long-Lasting Insectcidal Nets (LLINs) across various locations in multiple countries. 
-- We aim to understand the distribution patterns, trends and gain insights into the effectiveness of different distribution campaigns 

-- ****OBTECTIVE ONE****

-- Create a new database named `llin_analysis`  

CREATE DATABASE `llin_analysis`;
USE `llin_analysis`;

-- Creating a table for the database
CREATE TABLE llin_distribution (
  ID INT NOT NULL AUTO_INCREMENT, -- Unique identifier for each record
 Number_distributed VARCHAR(9), -- Number of LLINs distribued 
  Location  VARCHAR(50),        -- The specific location where the LLINs were distributed
 country VARCHAR(30),           -- The country where the distribution took place
year  INT,                      -- The period during which the distribution occured
 by_whom VARCHAR(60),           -- The organization responsible for the distribution
 country_code VARCHAR(5),      -- The ISO code for the country
PRIMARY KEY (ID)
);

-- Select all records from the 'llin_distribution' table . Here we want ot have a general view of the dataset

SELECT * FROM llin_analysis.llin_distribution;


-- *** OBJECTIVE TWO***

-- DESCRIPTIVE STATISTICS

-- We want to calculate total number of distributed llins in each country,  ordered by Total number of LLINs  in ascending order to see which country was doing well or poor. 
SELECT 
country,
SUM(Number_distributed) AS Total_Number
FROM 
  llin_distribution
GROUP BY
country 
ORDER BY 
Total_Number asc; -- Uganda had the highest number of LLINs distributed  and Gabon had the least.

-- Also to find average number distributed per event
SELECT 
year,
    ROUND(AVG(Number_distributed), 0) AS avg_No_distributed
FROM 
    llin_distribution
GROUP BY 
    year   -- Group results by year
ORDER BY 
    year; 
  -- On average, 197646 nets were distributed in 2006 compared to 221383 in 2007.
  
-- To determine the earliest and latest distribution dates 
SELECT 
    MIN(year) AS earliest_date,
    MAX(year) AS latest_date,
    COUNT(*) AS record_count
FROM 
    llin_distribution; -- Earliest date is the year 2006 and latest is the year 2007, however this type of question would makes sense if we had actual date in the data rather than just a year
    
    
    
-- ***OBJECTIVE THREE***
    
-- TRENDS AND PATTERNS
    
-- Here we calculate total number of LLINs distributed by each organization
    
SELECT
by_whom,
SUM(Number_distributed) AS Total_Number
FROM 
llin_distribution
GROUP BY
 by_whom
ORDER BY
 Total_Number desc; -- NMCP/Various distributed the highest number of nets(19669420) and Ndebele Arts Project produced the least(150)

-- In this step  we calculate number of LLINs  distributed in each year

SELECT 
year,
SUM(Number_distributed) as Total_Number -- (We use function 'SUM')
FROM llin_distribution
GROUP BY
year
ORDER BY
year; -- Total No of LLINs in 2007 was 27672820 and in 2006 was 8301133


-- *** OBJECTIVE FOUR***
-- VOLUME INSIGHTS

-- In this step  we find the location with the highest and lowest number of LLINs distributed

WITH LocationSums AS ( -- Use Common Table Expression(CTE) to calculates the total number of LLINs distributed for each location. 
  SELECT 
    location, 
    SUM(Number_distributed) AS Total_Number
  FROM 
    llin_distribution
  GROUP BY 
    location
),
MaxLocation AS ( -- This finds the location with the maximum number of LLINs distributed.
  SELECT 
    location, 
    Total_Number
  FROM 
    LocationSums
  ORDER BY 
    Total_Number DESC
  LIMIT 1
),
MinLocation AS ( -- This finds the location with the minimum number of LLINs distributed.
  SELECT 
    location, 
    Total_Number
  FROM 
    LocationSums
  ORDER BY 
    Total_Number ASC
  LIMIT 1 -- top first row should be selected
)

SELECT * FROM MaxLocation -- Combine the two together
UNION ALL
SELECT * FROM MinLocation; -- The location with highest number is Western and Eastern(12752620) whereas the one with the least is Kumali district (150)


-- Next is to  determine if there is a significant difference in the number of LLINs distributed by different organizations

SELECT 
  by_whom AS Organization,
  SUM(Number_distributed) AS Total_Distributed,
  ROUND(AVG(Number_distributed),0) AS Average_Distributed, -- On average how many LLINs were distributed
  COUNT(Number_distributed) AS Distribution_Count, -- Number of times the distribution occured
  ROUND(STDDEV(Number_distributed), 0) AS StdDev_Distributed -- the spread from the average
FROM 
  llin_distribution
GROUP BY 
  by_whom; -- There is a  difference based on the parameters used above  however, to determine whether its statistically significant, we can perfom formal test such as classical ANOVA
  
  
  
  -- *** OBJECTIVE FIVE***
  
  -- IDENTIFY EXTREMES
  
  -- We want to identify any outliers or significant spikes in the number of LLINS distributed in specific locations or periods
  -- Z scores are used in this section to identify outliers. We consider a value to be  an outlier if its (z_score < -3 or z_score >3 )
  
  -- Calculate statistics and identify outliers
WITH stats AS (
    SELECT
        AVG(Number_distributed) AS Average_llins,
        STDDEV(Number_distributed) AS Stddev_llins
    FROM llin_distribution
),
z_scores AS ( 
    SELECT
        ID,
        location,
        year,
        Number_distributed,
        (Number_distributed - (SELECT Average_llins FROM stats)) / (SELECT Stddev_llins FROM stats) AS z_score -- ( Formula to calculate z-scores)
    FROM llin_distribution
)
SELECT
    ID,
    location,
    year,
	Number_distributed,
    z_score
FROM z_scores
WHERE ABS(z_score) > 3 
ORDER BY z_score DESC;  -- (There were two outliers i.e. in the year 2007, "Western & Eastern  " region and "Various Regions" had  extremely high number of LLINs (12752620 and 3600000) respectively)