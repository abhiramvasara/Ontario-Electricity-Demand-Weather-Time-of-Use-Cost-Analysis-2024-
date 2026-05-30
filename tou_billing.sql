Create Database Ontario_energy;

Create Table hourly_data(
		reading_time	DATETIME	PRIMARY KEY,
		YEAR			INT,
		MONTH			INT,
		DAY				INT,
		Hour24			INT,
		weekday			INT,
		IS_weekend		TINYINT,
		ontario_demand	INT,
		market_demand	INT,
		temp_C			DECIMAL(4,2)
)

USE ontario_energy;

-- 1. How many rows? Should be 8784
SELECT COUNT(*) FROM hourly_data;

-- 2. Any gaps or bad values? All should be 0
SELECT
    COUNT(*) - COUNT(reading_time)   AS missing_time,
    COUNT(*) - COUNT(temp_c)         AS missing_temp,
    COUNT(*) - COUNT(ontario_demand) AS missing_demand
FROM hourly_data;

-- 3. Does it cover the whole year, and do the numbers look sane?
SELECT
    MIN(reading_time) AS first_hour,
    MAX(reading_time) AS last_hour,
    MIN(temp_c)       AS coldest,
    MAX(temp_c)       AS hottest,
    ROUND(AVG(ontario_demand)) AS avg_demand
FROM hourly_data;

## Layer 1 of the billing engine — every hour can now be tagged on/mid/off-peak.
Select reading_time, ontario_demand,
		CASE
			When WEEKDAY >= 5 then 'off-peak'
			when MONTH in (5,6,7,8,9,10) and hour24 BETWEEN 11 and 16 then 'on-peak'
			when MONTH in (5,6,7,8,9,10) and hour24 in (7,8,9,10,17,18) then 'mid-mid-peak'
			when MONTH in (5,6,7,8,9,10) and hour24 in (0,1,2,3,4,5,6,19,20,21,22,23) then 'off-peak'
			when MONTH in (11,12,1,2,3,4) and hour24 in (7,8,9,10,17,18) then 'on-peak'
			WHEN MONTH in (11,12,1,2,3,4) and hour24 BETWEEN 11 and 16 then 'Mid-peak'
			WHEN MONTH in (11,12,1,2,3,4) and hour24 in (0,1,2,3,4,5,6,19,20,21,22,23) then 'off-peak'
			End as tou_period
From hourly_data;


##count the hours in each period (the sanity check):
SELECT tou_period, COUNT(*) AS hours
FROM (
    SELECT CASE
        WHEN weekday >= 5 THEN 'off-peak'
        WHEN month IN (5,6,7,8,9,10) AND hour24 BETWEEN 11 AND 16 THEN 'on-peak'
        WHEN month IN (5,6,7,8,9,10) AND hour24 IN (7,8,9,10,17,18) THEN 'mid-peak'
        WHEN month IN (5,6,7,8,9,10) AND hour24 IN (0,1,2,3,4,5,6,19,20,21,22,23) THEN 'off-peak'
        WHEN month IN (11,12,1,2,3,4) AND hour24 IN (7,8,9,10,17,18) THEN 'on-peak'
        WHEN month IN (11,12,1,2,3,4) AND hour24 BETWEEN 11 AND 16 THEN 'mid-peak'
        WHEN month IN (11,12,1,2,3,4) AND hour24 IN (0,1,2,3,4,5,6,19,20,21,22,23) THEN 'off-peak'
    END AS tou_period
    FROM hourly_data
) t
GROUP BY tou_period;


## ADD TOU PERIOD AS COLUMN
ALTER TABLE hourly_data ADD COLUMN tou_period VARCHAR(10);

UPDATE hourly_data
SET tou_period = CASE
    WHEN weekday >= 5 THEN 'off-peak'
    WHEN month IN (5,6,7,8,9,10) AND hour24 BETWEEN 11 AND 16        THEN 'on-peak'
    WHEN month IN (5,6,7,8,9,10) AND hour24 IN (7,8,9,10,17,18)      THEN 'mid-peak'
    WHEN month IN (5,6,7,8,9,10) AND hour24 IN (0,1,2,3,4,5,6,19,20,21,22,23) THEN 'off-peak'
    WHEN month IN (11,12,1,2,3,4) AND hour24 IN (7,8,9,10,17,18)     THEN 'on-peak'
    WHEN month IN (11,12,1,2,3,4) AND hour24 BETWEEN 11 AND 16       THEN 'mid-peak'
    WHEN month IN (11,12,1,2,3,4) AND hour24 IN (0,1,2,3,4,5,6,19,20,21,22,23) THEN 'off-peak'
END;


SELECT tou_period, COUNT(*) AS hours
FROM hourly_data
GROUP BY tou_period;

##LAYER 2 - apply the rates
Select reading_time,tou_period, ontario_demand,
		CASE
			WHEN tou_period = 'off-peak' then 9.8
			WHEN tou_period = 'mid-peak' then 15.7
			WHEN tou_period = 'on-peak' then 20.3 END as rate_cents,
			(ontario_demand * 		CASE
			WHEN tou_period = 'off-peak' then 9.8
			WHEN tou_period = 'mid-peak' then 15.7
			WHEN tou_period = 'on-peak' then 20.3 END ) as COST
FROM hourly_data	

##Layer 3 - AGGREGATE INTO MONTHLY BILLS

SELECT `MONTH`,tou_period, SUM(
	ontario_demand * CASE
		WHEN tou_period = 'off-peak' THEN 9.8
		WHEN tou_period = 'mid-peak' THEN 15.7
		WHEN tou_period = 'on-peak' THEN 20.3
	END) AS Total_cost
from hourly_data
GROUP BY `MONTH`,tou_period
ORDER BY `MONTH`,tou_period;

##full hourly table with cost added
SELECT
    reading_time,
    `year`,
    `month`,
    `day`,
    hour24,
    weekday,
    is_weekend,
    ontario_demand,
    temp_c,
    tou_period,
    ontario_demand * CASE
        WHEN tou_period = 'off-peak' THEN 9.8
        WHEN tou_period = 'mid-peak' THEN 15.7
        WHEN tou_period = 'on-peak'  THEN 20.3
    END AS hourly_cost
FROM hourly_data
ORDER BY reading_time;
