-- Temp Table for Average rent rates for 1 and 3 bedroom in the city and short column name for Average Monthly Net Salary
DROP TABLE IF EXISTS #Renting
SELECT City, Country
	  , ([Apartment (1 bedroom) in City Centre] + [Apartment (1 bedroom) Outside of Centre]) / 2 AS Avg_1bed
      ,([Apartment (3 bedrooms) in City Centre] + [Apartment (3 bedrooms) Outside of Centre]) / 2 AS Avg_3bed
      ,[Average Monthly Net Salary (After Tax)] AS Avg_sal
INTO #Renting
FROM Numbeo_Project..numbeo_cities

DROP TABLE IF EXISTS #Housing
SELECT City, Country
	  ,([Apartment (1 bedroom) in City Centre] * 100) / ([Price per Square Meter to Buy Apartment in City Centre] * 30) AS ROI_1bed_Center
      ,([Apartment (3 bedrooms) in City Centre] * 100) / ([Price per Square Meter to Buy Apartment in City Centre] * 80) AS ROI_3bed_Center
      ,([Apartment (1 bedroom) Outside of Centre] * 100) / ([Price per Square Meter to Buy Apartment Outside of Centre] * 30) AS ROI_1bed_Outside
	  ,([Apartment (3 bedrooms) Outside of Centre] * 100) / ([Price per Square Meter to Buy Apartment Outside of Centre] * 80) AS ROI_3bed_Outside
INTO #Housing
FROM Numbeo_Project..numbeo_cities

-- Temp Table for Food spendings (if mostly Cooking)
DROP TABLE IF EXISTS #Food
SELECT City, Country
	  ,[Milk (regular), (1 liter)]*3 + [Loaf of Fresh White Bread (500g)]*6 + [Rice (white), (1kg)]*5 + [Eggs (regular) (12)]*3
	  +[Local Cheese (1kg)]*3 + [Chicken Fillets (1kg)]*3 + [Beef Round (1kg) (or Equivalent Back Leg Red Meat)]*2 + [Apples (1kg)]*2
	  +[Banana (1kg)]*3 + [Tomato (1kg)]*3 + [Potato (1kg)]*3 + [Onion (1kg)] + [Lettuce (1 head)]*2 + [Oranges (1kg)]
	  +[McMeal at McDonalds (or Equivalent Combo Meal)]*10 AS Food
INTO #Food
FROM Numbeo_Project..numbeo_cities
WHERE [Milk (regular), (1 liter)] IS NOT NULL
	AND [Loaf of Fresh White Bread (500g)] IS NOT NULL
	AND [Rice (white), (1kg)] IS NOT NULL
	AND [Eggs (regular) (12)] IS NOT NULL
	AND [Banana (1kg)] IS NOT NULL
	AND [Tomato (1kg)] IS NOT NULL
	AND [Potato (1kg)] IS NOT NULL
	AND [Onion (1kg)] IS NOT NULL
	AND [Lettuce (1 head)] IS NOT NULL
	AND [McMeal at McDonalds (or Equivalent Combo Meal)] IS NOT NULL

-- Temp Table for Food spendings (if only Eating Out)
DROP TABLE IF EXISTS #FoodEatingOut
SELECT City, Country
	  ,[McMeal at McDonalds (or Equivalent Combo Meal)]*60 AS FoodEatingOut
INTO #FoodEatingOut
FROM Numbeo_Project..numbeo_cities
WHERE [McMeal at McDonalds (or Equivalent Combo Meal)] IS NOT NULL

-- Temp Table for Bills and Monthly Pass
DROP TABLE IF EXISTS #TransportUtilities
SELECT City, Country
	  ,[Monthly Pass (Regular Price)] AS Transportation
	  ,[Basic (Electricity, Heating, Cooling, Water, Garbage) for 85m2 A] / 4
	  +[Mobile Phone Monthly Plan with Calls and 10GB+ Data] AS Utilities
INTO #TransportUtilities
FROM Numbeo_Project..numbeo_cities
WHERE [Monthly Pass (Regular Price)] IS NOT NULL
	AND [Basic (Electricity, Heating, Cooling, Water, Garbage) for 85m2 A] IS NOT NULL
	AND [Mobile Phone Monthly Plan with Calls and 10GB+ Data] IS NOT NULL

-- Percentage of Salary to 1 bedroom apartments
SELECT nc.City, nc.Country, Avg_1bed, Avg_sal, ROUND(Avg_1bed/Avg_sal*100, 2) AS PercSalAparts
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
WHERE Avg_1bed IS NOT NULL 
	AND Avg_sal IS NOT NULL
	--AND nc.City = 'Sydney'
ORDER BY PercSalAparts	

-- Percentage of Salary to 3 bedroom apartments
SELECT nc.City, nc.Country, Avg_3bed, Avg_sal, ROUND(Avg_3bed/Avg_sal*100, 2) AS PercSalAparts
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
WHERE Avg_3bed IS NOT NULL
	AND Avg_sal IS NOT NULL
ORDER BY PercSalAparts

-- Return on Investment
SELECT nc.City, nc.Country, ROI_1bed_Center, ROI_3bed_Center, ROI_1bed_Outside, ROI_3bed_Outside
FROM Numbeo_Project..numbeo_cities nc
JOIN #Housing col_h
	ON nc.City = col_h.City
	AND nc.Country = col_h.Country
WHERE ROI_1bed_Center IS NOT NULL 
	AND ROI_3bed_Center IS NOT NULL
	AND ROI_1bed_Outside IS NOT NULL
	AND ROI_3bed_Outside IS NOT NULL
	AND Contributors > 15
	AND Entries > 130
	--AND nc.Country NOT IN ('United States', 'United Kingdom', 'Mexico', 'Fiji')
	--AND ROI_1bed_Center < ROI_3bed_Center
	--AND nc.City = 'Dubai'
ORDER BY ROI_1bed_Center DESC

-- Cost of Living for individual renting
SELECT nc.City, nc.Country, Avg_1bed + Food + Transportation + Utilities AS Cost_of_living,
	   Food, Transportation, Utilities, Avg_1bed, Avg_sal,
	   ROUND(Avg_sal - (Avg_1bed + Food + Transportation + Utilities), 2) AS Money_after_spendings,
	   ROUND(Food / Avg_sal * 100, 2) AS PercentageFoodSpendings
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
JOIN #Food col_f
	ON nc.City = col_f.City
	AND nc.Country = col_f.Country
JOIN #TransportUtilities col_tu
	ON nc.City = col_tu.City
	AND nc.Country = col_tu.Country
WHERE Avg_3bed IS NOT NULL
	AND Avg_sal IS NOT NULL
	AND Avg_1bed IS NOT NULL
	AND Food IS NOT NULL
	--AND nc.City = 'Tashkent'
	--AND nc.Country = 'United States'
ORDER BY Money_after_spendings DESC

-- Cost of Living for shared renting (renting a room or renting 3 bedroom flat with friends)
SELECT nc.City, nc.Country, ROUND(([Apartment (3 bedrooms) Outside of Centre] / 3 + Food + Transportation + Utilities), 2) AS Cost_of_living,
	   Food, Transportation, Utilities, ROUND([Apartment (3 bedrooms) Outside of Centre] / 3, 2) AS room_price,
	   ROUND(Avg_sal - ([Apartment (3 bedrooms) Outside of Centre] / 3 + Food + Transportation + Utilities), 2) AS Money_after_spendings,
	   ROUND(Food / Avg_sal * 100, 2) AS PercentageFoodSpendings
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
JOIN #Food col_f
	ON nc.City = col_f.City
	AND nc.Country = col_f.Country
JOIN #TransportUtilities col_tu
	ON nc.City = col_tu.City
	AND nc.Country = col_tu.Country
WHERE Avg_3bed IS NOT NULL
	AND Avg_sal IS NOT NULL
	AND Avg_1bed IS NOT NULL
	AND Food IS NOT NULL
	--AND nc.City = 'Warsaw'
	--AND nc.Country = 'Germany'
ORDER BY Money_after_spendings DESC

-- Cost of Living if only eating out and individual renting
SELECT nc.City, nc.Country, Avg_1bed + FoodEatingOut + Transportation + Utilities AS Cost_of_living,
	   FoodEatingOut, Transportation, Utilities, Avg_1bed, Avg_sal,
	   ROUND(Avg_sal - (Avg_1bed + FoodEatingOut + Transportation + Utilities), 2) AS Money_after_spendings,
	   ROUND(FoodEatingOut / Avg_sal * 100, 2) AS PercentageFoodSpendings
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
JOIN #FoodEatingOut col_f
	ON nc.City = col_f.City
	AND nc.Country = col_f.Country
JOIN #TransportUtilities col_tu
	ON nc.City = col_tu.City
	AND nc.Country = col_tu.Country
WHERE Avg_3bed IS NOT NULL
	AND Avg_sal IS NOT NULL
	AND Avg_1bed IS NOT NULL
	AND FoodEatingOut IS NOT NULL
	--AND nc.City = 'Tashkent'
	--AND nc.Country = 'United States'
ORDER BY Money_after_spendings DESC

DROP TABLE IF EXISTS #CostOfLiving
SELECT nc.City, nc.Country, Avg_1bed + FoodEatingOut + Transportation + Utilities AS Cost_of_living_EatingOut_IndividualRenting,
	   Avg_1bed + Food + Transportation + Utilities AS Cost_of_living_Cooking_IndividualRenting,
	   Avg_3bed + FoodEatingOut + Transportation + Utilities AS Cost_of_living_EatingOut_3bed,
	   Avg_3bed + Food + Transportation + Utilities AS Cost_of_living_Cooking_3bed,
	   ROUND(([Apartment (3 bedrooms) Outside of Centre] / 3 + Food + Transportation + Utilities), 2) AS Cost_of_living_Cooking_SharedRenting,
	   ROUND(([Apartment (3 bedrooms) Outside of Centre] / 3 + FoodEatingOut + Transportation + Utilities), 2) AS Cost_of_living_EatingOut_SharedRenting
	   --Food, Transportation, Utilities, Avg_1bed, Avg_3bed, Avg_sal, ROUND(([Apartment (3 bedrooms) Outside of Centre] / 3), 2) room_price
INTO #CostOfLiving
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
JOIN #FoodEatingOut col_feo
	ON nc.City = col_feo.City
	AND nc.Country = col_feo.Country
JOIN #Food col_f
	ON nc.City = col_f.City
	AND nc.Country = col_f.Country
JOIN #TransportUtilities col_tu
	ON nc.City = col_tu.City
	AND nc.Country = col_tu.Country
WHERE Avg_3bed IS NOT NULL
	AND Avg_sal IS NOT NULL
	AND Avg_1bed IS NOT NULL
	AND Food IS NOT NULL


-- Table with all the results from this analysis 
-- Resulting table will be saved in excel file for Tableau Visualization
SELECT nc.City, nc.Country, Cost_of_living_EatingOut_IndividualRenting,
	   Cost_of_living_Cooking_IndividualRenting,
	   Cost_of_living_EatingOut_3bed,
	   Cost_of_living_Cooking_3bed,
	   Cost_of_living_Cooking_SharedRenting,
	   Cost_of_living_EatingOut_SharedRenting,
	   ROI_1bed_Center, ROI_3bed_Center, ROI_1bed_Outside, ROI_3bed_Outside,
	   Food, Transportation, Utilities, Avg_1bed, Avg_3bed, Avg_sal, ROUND(([Apartment (3 bedrooms) Outside of Centre] / 3), 2) room_price,
	   ROUND(Avg_sal - Cost_of_living_Cooking_IndividualRenting, 2) AS Money_after_Cooking_IndividualRenting,
	   ROUND(Avg_sal - Cost_of_living_EatingOut_IndividualRenting, 2) AS Money_after_EatingOut_IndividualRenting,
	   ROUND(Avg_sal - Cost_of_living_EatingOut_3bed, 2) AS Money_after_EatingOut_3bed,
	   ROUND(Avg_sal - Cost_of_living_Cooking_3bed, 2) AS Money_after_Cooking_3bed,
	   ROUND(Avg_sal - Cost_of_living_Cooking_SharedRenting, 2) AS Money_after_Cooking_SharedRenting,
	   ROUND(Avg_sal - Cost_of_living_EatingOut_SharedRenting, 2) AS Money_after_EatingOut_SharedRenting,
	   ROUND(Food / Avg_sal * 100, 2) AS PercentageFoodSpendings_if_cooking,
	   ROUND(FoodEatingOut / Avg_sal * 100, 2) AS PercentageFoodSpendings_if_EatingOut,
	   Contributors, Entries, Latitude, Longitude, Population
FROM Numbeo_Project..numbeo_cities nc
JOIN #Renting col_r
	ON nc.City = col_r.City
	AND nc.Country = col_r.Country
JOIN #Housing col_h
	ON nc.City = col_h.City
	AND nc.Country = col_h.Country
JOIN #FoodEatingOut col_feo
	ON nc.City = col_feo.City
	AND nc.Country = col_feo.Country
JOIN #Food col_f
	ON nc.City = col_f.City
	AND nc.Country = col_f.Country
JOIN #TransportUtilities col_tu
	ON nc.City = col_tu.City
	AND nc.Country = col_tu.Country
JOIN #CostOfLiving col
	ON nc.City = col.City
	AND nc.Country = col.Country
WHERE Avg_3bed IS NOT NULL
	AND Avg_sal IS NOT NULL
	AND Avg_1bed IS NOT NULL
	AND Food IS NOT NULL
	AND ROI_1bed_Center IS NOT NULL 
	AND ROI_3bed_Center IS NOT NULL
	AND ROI_1bed_Outside IS NOT NULL
	AND ROI_3bed_Outside IS NOT NULL
	AND Contributors > 15
	AND Entries > 130
ORDER BY Money_after_Cooking_SharedRenting DESC

