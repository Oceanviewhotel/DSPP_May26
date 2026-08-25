# Freddonomics: SQL Analysis of Chocolate Inflation, Minimum Wage and Freddo Affordability

## Project aim
This project investigates whether the common idea that Freddo prices show unusually high inflation is supported when compared with official UK chocolate/confectionery inflation and National Living Wage data.

## Data sources
- ONS CPI index 01.1.8.3 Chocolate, 2015=100.
- ONS CPI index 01.1.8.4 Confectionery products, 2015=100.
- GOV.UK National Minimum Wage and National Living Wage rates.
- A small community-sourced Freddo price file used only as an illustrative case study.

## Tools used
- Databricks SQL for cleaning, joining, feature engineering and summary outputs.
- Excel/Databricks visualisation exports for charts.
- GitHub for portfolio documentation.

## Data engineering process
The pipeline loads the raw CSV files, standardises year/date fields, filters unreliable Freddo observations, creates a year spine, joins the datasets and calculates growth and affordability measures. Missing Freddo prices are preserved as nulls rather than being imputed.

## Key findings
- The chocolate index increased from 100.5 in 2019 to 149.7 in 2025, a rise of approximately 49.0%.
- The National Living Wage increased by approximately 48.7% over the same period.
- Chocolate annual growth exceeded wage growth in only two of six measurable annual intervals.
- Confirmed Freddo observations showed affordability improving slightly from 1.89 minutes of minimum-wage work in 2022 to 1.84 minutes in 2024, but this is illustrative because only two retained Freddo prices were available.

## Visualisations
The project includes charts showing chocolate and confectionery price indices, National Living Wage, confirmed Freddo affordability observations and monthly chocolate-index growth distribution.

## Limitations
Freddo price evidence is weak because it is not an official price series and only two medium-confidence observations were retained in the final analysis window. The project therefore avoids causal claims and treats Freddo prices as an illustrative case study rather than the main evidence.

## Future improvements
A future version should collect retailer-level Freddo observations with dates, product size, promotional status and region. It should also automate ONS ingestion and add validation tests for duplicate periods and schema changes.
