-- Freddonomics SQL analysis
-- Public portfolio project for Data Science Professional Practice

-- 1. Clean annual confectionery CPI
CREATE OR REPLACE TABLE confectionery_annual AS
WITH cleaned AS (
  SELECT
    TRY_CAST(TRIM(CAST(Title AS STRING)) AS INT) AS year,
    TRY_CAST(TRIM(CAST(`CPI INDEX 01.1.8.4 Confectionery products 2015=100` AS STRING)) AS DOUBLE) AS confectionery_index
  FROM confectionary_raw
)
SELECT year, confectionery_index
FROM cleaned
WHERE year BETWEEN 2015 AND 2025
  AND confectionery_index IS NOT NULL;

-- 2. Clean annual chocolate CPI
CREATE OR REPLACE TABLE chocolate_annual AS
WITH cleaned AS (
  SELECT
    TRY_CAST(TRIM(CAST(period AS STRING)) AS INT) AS year,
    TRY_CAST(TRIM(CAST(index_value AS STRING)) AS DOUBLE) AS chocolate_index
  FROM chocolate_raw
)
SELECT year, chocolate_index
FROM cleaned
WHERE year BETWEEN 2015 AND 2025
  AND chocolate_index IS NOT NULL;

-- 3. Filter Freddo observations
CREATE OR REPLACE TABLE freddo_annual AS
WITH cleaned AS (
  SELECT
    TRY_CAST(TRIM(CAST(year AS STRING)) AS INT) AS year,
    TRY_CAST(TRIM(CAST(price_p AS STRING)) AS DOUBLE) AS freddo_price_pence,
    TRIM(confidence) AS confidence,
    TRIM(source_type) AS source_type,
    notes
  FROM freddo_raw
)
SELECT year, freddo_price_pence, confidence, source_type, notes
FROM cleaned
WHERE year BETWEEN 2015 AND 2025
  AND freddo_price_pence IS NOT NULL
  AND LOWER(source_type) <> 'estimate'
  AND LOWER(confidence) IN ('medium', 'high');

-- 4. Create minimum wage table
CREATE OR REPLACE TABLE minimum_wage_annual AS
SELECT *
FROM VALUES
  (2019, 8.21), (2020, 8.72), (2021, 8.91),
  (2022, 9.50), (2023, 10.42), (2024, 11.44),
  (2025, 12.21)
AS wage_data(year, minimum_wage);

-- 5. Create final summary table
CREATE OR REPLACE TABLE freddonomics_summary AS
WITH years AS (
  SELECT * FROM VALUES (2019), (2020), (2021), (2022), (2023), (2024), (2025) AS year_list(year)
),
combined_data AS (
  SELECT y.year, ch.chocolate_index, co.confectionery_index, mw.minimum_wage, fr.freddo_price_pence
  FROM years AS y
  LEFT JOIN chocolate_annual AS ch ON y.year = ch.year
  LEFT JOIN confectionery_annual AS co ON y.year = co.year
  LEFT JOIN minimum_wage_annual AS mw ON y.year = mw.year
  LEFT JOIN freddo_annual AS fr ON y.year = fr.year
),
previous_year_data AS (
  SELECT *,
    LAG(chocolate_index) OVER (ORDER BY year) AS previous_chocolate_index,
    LAG(minimum_wage) OVER (ORDER BY year) AS previous_minimum_wage,
    LAG(freddo_price_pence) OVER (ORDER BY year) AS previous_freddo_price
  FROM combined_data
)
SELECT
  year,
  ROUND(chocolate_index, 2) AS chocolate_index,
  ROUND(confectionery_index, 2) AS confectionery_index,
  ROUND(minimum_wage, 2) AS minimum_wage,
  ROUND(freddo_price_pence, 2) AS freddo_price_pence,
  ROUND(freddo_price_pence / 100.0, 2) AS freddo_price_pounds,
  CASE WHEN freddo_price_pence IS NOT NULL AND minimum_wage IS NOT NULL
    THEN ROUND(((freddo_price_pence / 100.0) / minimum_wage) * 60, 2) END AS minutes_to_buy_freddo,
  CASE WHEN chocolate_index IS NOT NULL AND previous_chocolate_index IS NOT NULL
    THEN ROUND(((chocolate_index - previous_chocolate_index) / previous_chocolate_index) * 100, 2) END AS chocolate_index_growth,
  CASE WHEN minimum_wage IS NOT NULL AND previous_minimum_wage IS NOT NULL
    THEN ROUND(((minimum_wage - previous_minimum_wage) / previous_minimum_wage) * 100, 2) END AS minimum_wage_growth,
  CASE WHEN freddo_price_pence IS NOT NULL AND previous_freddo_price IS NOT NULL
    THEN ROUND(((freddo_price_pence - previous_freddo_price) / previous_freddo_price) * 100, 2) END AS freddo_price_growth
FROM previous_year_data;

-- 6. Monthly chocolate growth for histogram
CREATE OR REPLACE TABLE chocolate_monthly_growth AS
WITH monthly_cleaned AS (
  SELECT
    TO_DATE(CONCAT('01 ', INITCAP(LOWER(TRIM(period)))), 'dd yyyy MMM') AS month,
    TRY_CAST(TRIM(CAST(index_value AS STRING)) AS DOUBLE) AS chocolate_index
  FROM chocolate_raw
  WHERE TRIM(period) RLIKE '^[0-9]{4} [A-Z]{3}$'
),
previous_month_data AS (
  SELECT month, chocolate_index, LAG(chocolate_index) OVER (ORDER BY month) AS previous_chocolate_index
  FROM monthly_cleaned
  WHERE month BETWEEN DATE '2019-01-01' AND DATE '2025-12-01'
)
SELECT month, chocolate_index,
  CASE WHEN previous_chocolate_index IS NOT NULL
    THEN ROUND(((chocolate_index - previous_chocolate_index) / previous_chocolate_index) * 100, 2) END AS monthly_chocolate_growth
FROM previous_month_data
ORDER BY month;
