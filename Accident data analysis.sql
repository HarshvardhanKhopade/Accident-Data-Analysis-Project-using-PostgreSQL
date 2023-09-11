CREATE TABLE acc (
    AccidentIndex VARCHAR(255), -- Adjust the data type as needed
    Severity VARCHAR(255),               -- Adjust the data type as needed
    Date DATE,                  -- Date data type
    Day VARCHAR(255),           -- Adjust the data type as needed
    SpeedLimit INT,             -- Adjust the data type as needed
    LightConditions VARCHAR(255), -- Adjust the data type as needed
    WeatherConditions VARCHAR(255), -- Adjust the data type as needed
    RoadConditions VARCHAR(255),   -- Adjust the data type as needed
    Area VARCHAR(255)            -- Adjust the data type as needed
);



set datestyle to DMY
COPY acc FROM 'H:/Dataset/Road Accident Data/accident.csv' WITH CSV HEADER;

SELECT * FROM acc;

/* 1 How many accidents have occured in urban areas versus rural areas? */

SELECT
       area,
       COUNT(AccidentIndex) AS "Total Accident"
FROM  
	acc
GROUP BY 
        area;

/* 2 which day of the week highest number of accident? */

SELECT 
       Day,
       count(AccidentIndex) as "Total Accident"
FROM
    acc
GROUP BY 
        Day
order by Day,
         "Total Accident" DESC;
         
		 
/* 3 What is the averge age of vechiles envolved in accidents based on there type? */

SELECT 
       VehicleType,
       COUNT(AccidentIndex) AS "Total Accident",
       AVG(AgeVehicle) AS "AVG Age"
FROM 
    vehicle
WHERE AgeVehicle IS NOT NULL
GROUP BY
       VehicleType
ORDER BY 
       "Total Accident" DESC;


/* 4 Can we identify any trends in accident based on age of vehicle involved? */

SELECT "AgeGroup",
       COUNT(AccidentIndex) AS "Total Accidents",
       AVG(AgeVehicle) AS "Avg Age"
FROM (
  SELECT
    AccidentIndex,
    AgeVehicle,
    CASE
      WHEN AgeVehicle BETWEEN 0 AND 5 THEN 'NEW'
      WHEN AgeVehicle BETWEEN 6 AND 10 THEN 'REGULAR'
      ELSE 'OLD'
    END AS "AgeGroup"
  FROM vehicle
) AS Subquery
GROUP BY "AgeGroup";

/* 5 Are there any specific weather conditions that contribute to severe accidents? */

SELECT 
    WeatherConditions,
    Severity,
    "Accident count"
FROM (
    SELECT 
        WeatherConditions,
        Severity,
        COUNT(AccidentIndex) AS "Accident count"
    FROM 
        acc
    GROUP BY
        WeatherConditions, Severity
) AS subquery
ORDER BY "Accident count" DESC;


/* 6  Do accidents often involve impacts on the left-hand side of vehicles? */

SELECT LeftHand,
COUNT(AccidentIndex) AS "Total Accident"
FROM vehicle
group by LeftHand
HAVING LeftHand is NOT null;

/* 7 Are there any relationships between journey purposes and the severity of accidents?*/

SELECT
    v.JourneyPurpose,
    a.Severity,
    COUNT(a.AccidentIndex) AS "Accident Count"
FROM
    acc a
join vehicle v ON  a.AccidentIndex=v.AccidentIndex
GROUP BY
    JourneyPurpose,
    Severity
ORDER BY
    "Accident Count" DESC;


/* 8 Calculate the average age of vehicles involved in accidents , considering Day light and point of impact ? */

SELECT 
       acc.LightConditions,
       vehicle.PointImpact,
       AVG(vehicle.AgeVehicle) AS "AVG Age"
FROM 
     acc
JOIN vehicle ON vehicle.AccidentIndex = acc.AccidentIndex
GROUP BY 
        acc.LightConditions, vehicle.PointImpact
ORDER BY
        "AVG Age" DESC;

WITH SubqueryCTE AS (
    SELECT
        v.AccidentIndex,
        AVG(v.AgeVehicle) AS "AVG Age"
    FROM 
        vehicle AS v
    GROUP BY v.AccidentIndex
)
SELECT
    a.LightConditions,
    v.PointImpact,
    s."AVG Age"
FROM 
    acc AS a
JOIN vehicle AS v ON v.AccidentIndex = a.AccidentIndex
LEFT JOIN SubqueryCTE AS s ON s.AccidentIndex = a.AccidentIndex
GROUP BY a.LightConditions, v.PointImpact;

/* 9 Analyze accident severity in relation to various factors, including weather conditions, road conditions, and lighting conditions.*/

WITH accidents_by_factors AS (
  SELECT
    Severity,
    WeatherConditions ,
    RoadConditions,
    LightConditions,
    COUNT (*) AS accident_count
   FROM acc
   WHERE WeatherConditions IS NOT NULL
   GROUP BY
    Severity,
    WeatherConditions  ,
    RoadConditions  ,
    LightConditions
)
SELECT
  Severity,
  WeatherConditions,
  RoadConditions,
  LightConditions,
  accident_count
FROM accidents_by_factors
ORDER BY accident_count DESC;

/* 10 "Which area has the highest frequency of accidents for all vehicle types where the number of accidents has reached 1000?"*/

SELECT
    a.area,
    v.VehicleType,
    COUNT(v.AccidentIndex) AS "Accident Frequency"
FROM
    acc a
JOIN
    vehicle v ON a.AccidentIndex = v.AccidentIndex
GROUP BY
    a.area,
    v.VehicleType
HAVING
    COUNT(v.AccidentIndex) >= 1000
ORDER BY
    "Accident Frequency" DESC;

/* 11 Which area has the lowest frequency of accidents for a specific vehicle type?*/

	
WITH AccidentFrequencyCTE AS (
    SELECT
        a.area,
        v.VehicleType,
        COUNT(v.AccidentIndex) AS "Accident Frequency"
    FROM
        acc a
    JOIN
        vehicle v ON a.AccidentIndex = v.AccidentIndex
    GROUP BY
        a.area,
        v.VehicleType
)

SELECT
    area,
    VehicleType,
    "Accident Frequency"
FROM
    AccidentFrequencyCTE
WHERE
    "Accident Frequency" = (
        SELECT MIN("Accident Frequency") FROM AccidentFrequencyCTE
    );
