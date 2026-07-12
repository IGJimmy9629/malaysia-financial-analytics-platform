/*
============================================================
PROJECT:
Malaysia Financial Analytics Platform

AUTHOR:
Mohd Nizam

PURPOSE:
This Hive pipeline manages the World Bank Malaysia dataset
before the data is used for R visual analytics.

CURRENT PIPELINE SECTIONS:

SECTION 1
- Create and select the Hive database
- Register the raw World Bank CSV as an external Hive table
- Validate the raw data

SECTION 2
- Create a cleaned staging table
- Standardise text and code fields
- Keep Malaysia records
- Keep the working period from 2000 to 2024
- Validate the staging table

The raw CSV file is stored in HDFS at:

/user/maria_dev/malaysia_finance/raw/
============================================================
*/


-- ============================================================
-- SECTION 1: DATABASE AND RAW DATA REGISTRATION
-- Creates the Hive database and registers the raw World Bank
-- CSV file as an external table.
-- ============================================================


-- Create the database if it does not already exist.
CREATE DATABASE IF NOT EXISTS malaysia_finance;


-- Select the database for all subsequent Hive operations.
USE malaysia_finance;


-- Remove the existing Hive table definition before recreating it.
-- Because this is an external table, the CSV file in HDFS will
-- remain unchanged.
DROP TABLE IF EXISTS worldbank_raw;


-- Register the World Bank CSV file as an external Hive table.
-- OpenCSVSerde is used because some indicator names contain commas.
CREATE EXTERNAL TABLE worldbank_raw (
    country_name   STRING,
    country_code   STRING,
    indicator_name STRING,
    indicator_code STRING,

    y1960 DOUBLE,
    y1961 DOUBLE,
    y1962 DOUBLE,
    y1963 DOUBLE,
    y1964 DOUBLE,
    y1965 DOUBLE,
    y1966 DOUBLE,
    y1967 DOUBLE,
    y1968 DOUBLE,
    y1969 DOUBLE,

    y1970 DOUBLE,
    y1971 DOUBLE,
    y1972 DOUBLE,
    y1973 DOUBLE,
    y1974 DOUBLE,
    y1975 DOUBLE,
    y1976 DOUBLE,
    y1977 DOUBLE,
    y1978 DOUBLE,
    y1979 DOUBLE,

    y1980 DOUBLE,
    y1981 DOUBLE,
    y1982 DOUBLE,
    y1983 DOUBLE,
    y1984 DOUBLE,
    y1985 DOUBLE,
    y1986 DOUBLE,
    y1987 DOUBLE,
    y1988 DOUBLE,
    y1989 DOUBLE,

    y1990 DOUBLE,
    y1991 DOUBLE,
    y1992 DOUBLE,
    y1993 DOUBLE,
    y1994 DOUBLE,
    y1995 DOUBLE,
    y1996 DOUBLE,
    y1997 DOUBLE,
    y1998 DOUBLE,
    y1999 DOUBLE,

    y2000 DOUBLE,
    y2001 DOUBLE,
    y2002 DOUBLE,
    y2003 DOUBLE,
    y2004 DOUBLE,
    y2005 DOUBLE,
    y2006 DOUBLE,
    y2007 DOUBLE,
    y2008 DOUBLE,
    y2009 DOUBLE,

    y2010 DOUBLE,
    y2011 DOUBLE,
    y2012 DOUBLE,
    y2013 DOUBLE,
    y2014 DOUBLE,
    y2015 DOUBLE,
    y2016 DOUBLE,
    y2017 DOUBLE,
    y2018 DOUBLE,
    y2019 DOUBLE,

    y2020 DOUBLE,
    y2021 DOUBLE,
    y2022 DOUBLE,
    y2023 DOUBLE,
    y2024 DOUBLE
)
ROW FORMAT SERDE
'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ",",
    "quoteChar"     = "\"",
    "escapeChar"    = "\\"
)
STORED AS TEXTFILE
LOCATION '/user/maria_dev/malaysia_finance/raw'
TBLPROPERTIES (
    "skip.header.line.count" = "1"
);


-- ------------------------------------------------------------
-- SECTION 1 VALIDATION
-- These queries check that the raw table was created correctly.
-- Run them separately during development if necessary.
-- ------------------------------------------------------------


-- Display all tables in the database.
SHOW TABLES;


-- Display the raw table structure.
DESCRIBE worldbank_raw;


-- Preview selected columns from the raw dataset.
SELECT
    country_name,
    country_code,
    indicator_name,
    indicator_code,
    y2020,
    y2021,
    y2022,
    y2023,
    y2024
FROM worldbank_raw
LIMIT 5;


-- Count the total number of raw indicator records.
SELECT
    COUNT(*) AS total_raw_indicators
FROM worldbank_raw;


-- Confirm that the dataset contains Malaysia records.
SELECT
    country_name,
    country_code,
    COUNT(*) AS indicator_count
FROM worldbank_raw
GROUP BY
    country_name,
    country_code;


-- ============================================================
-- SECTION 2: STAGING LAYER
-- Standardises codes and text fields, keeps Malaysia records,
-- and limits the working period to 2000–2024.
-- ============================================================


-- Remove the existing staging table before rebuilding it.
DROP TABLE IF EXISTS worldbank_stage;


-- Create a physical staging table in ORC format.
-- The staging table:
-- 1. Keeps Malaysia records only
-- 2. Removes unnecessary spaces
-- 3. Standardises codes to uppercase
-- 4. Keeps only the years needed for the project
CREATE TABLE worldbank_stage
STORED AS ORC
AS
SELECT
    TRIM(country_name) AS country_name,
    UPPER(TRIM(country_code)) AS country_code,
    TRIM(indicator_name) AS indicator_name,
    UPPER(TRIM(indicator_code)) AS indicator_code,

    y2000,
    y2001,
    y2002,
    y2003,
    y2004,
    y2005,
    y2006,
    y2007,
    y2008,
    y2009,

    y2010,
    y2011,
    y2012,
    y2013,
    y2014,
    y2015,
    y2016,
    y2017,
    y2018,
    y2019,

    y2020,
    y2021,
    y2022,
    y2023,
    y2024

FROM worldbank_raw
WHERE UPPER(TRIM(country_code)) = 'MYS';


-- ------------------------------------------------------------
-- SECTION 2 VALIDATION
-- These queries check the staging table after creation.
-- ------------------------------------------------------------


-- Confirm that the staging table exists.
SHOW TABLES;


-- Display the staging table structure.
DESCRIBE worldbank_stage;


-- Preview the cleaned staging data.
SELECT
    country_name,
    country_code,
    indicator_name,
    indicator_code,
    y2020,
    y2021,
    y2022,
    y2023,
    y2024
FROM worldbank_stage
LIMIT 10;


-- Compare the number of records in the raw and staging tables.
SELECT
    COUNT(*) AS raw_count
FROM worldbank_raw;


SELECT
    COUNT(*) AS stage_count
FROM worldbank_stage;


-- Check whether any indicator code appears more than once.
SELECT
    indicator_code,
    COUNT(*) AS record_count
FROM worldbank_stage
GROUP BY indicator_code
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- Check for incomplete indicator names or codes.
SELECT
    COUNT(*) AS incomplete_indicator_records
FROM worldbank_stage
WHERE indicator_code IS NULL
   OR TRIM(indicator_code) = ''
   OR indicator_name IS NULL
   OR TRIM(indicator_name) = '';

-- ============================================================
-- SECTION 3: INDICATOR CATALOGUE
-- Defines the ten indicators used in the visual analytics layer.
-- It stores the World Bank code, dashboard label, theme, unit,
-- desired direction and display order.
-- ============================================================

DROP TABLE IF EXISTS indicator_catalog;

CREATE TABLE indicator_catalog (
    indicator_code      STRING,
    indicator_label     STRING,
    theme               STRING,
    unit                STRING,
    desired_direction   STRING,
    display_order       INT
)
STORED AS ORC;


INSERT INTO TABLE indicator_catalog
SELECT
    'NY.GDP.MKTP.KD.ZG',
    'GDP Growth',
    'Economic Well-being',
    'Annual %',
    'Higher',
    1

UNION ALL

SELECT
    'FP.CPI.TOTL.ZG',
    'Inflation',
    'Economic Well-being',
    'Annual %',
    'Lower',
    2

UNION ALL

SELECT
    'SL.UEM.TOTL.ZS',
    'Unemployment',
    'Economic Well-being',
    '% of labour force',
    'Lower',
    3

UNION ALL

SELECT
    'NY.ADJ.NNTY.PC.KD',
    'Income per Capita',
    'Economic Well-being',
    'Constant 2015 US$',
    'Higher',
    4

UNION ALL

SELECT
    'NE.CON.PRVT.PC.KD',
    'Household Consumption',
    'Household Financial Behaviour',
    'Constant 2015 US$',
    'Higher',
    5

UNION ALL

SELECT
    'NY.GDS.TOTL.ZS',
    'Gross Domestic Savings',
    'Household Financial Behaviour',
    '% of GDP',
    'Higher',
    6

UNION ALL

SELECT
    'FR.INR.LEND',
    'Lending Rate',
    'Financial System Support',
    '%',
    'Lower',
    7

UNION ALL

SELECT
    'FR.INR.DPST',
    'Deposit Rate',
    'Financial System Support',
    '%',
    'Higher',
    8

UNION ALL

SELECT
    'FD.AST.PRVT.GD.ZS',
    'Domestic Credit',
    'Financial System Support',
    '% of GDP',
    'Higher',
    9

UNION ALL

SELECT
    'FB.AST.NPER.ZS',
    'Non-performing Loans',
    'Financial System Support',
    '% of gross loans',
    'Lower',
    10;

-- ============================================================
-- SECTION 4: CURATED SELECTED INDICATORS
-- Joins the staging dataset with the indicator catalogue.
-- Only the ten approved project indicators are retained.
-- The table remains in wide format before unpivoting.
-- ============================================================

DROP TABLE IF EXISTS selected_indicators;

CREATE TABLE selected_indicators
STORED AS ORC
AS
SELECT
    s.country_name,
    s.country_code,
    s.indicator_name,
    s.indicator_code,

    c.indicator_label,
    c.theme,
    c.unit,
    c.desired_direction,
    c.display_order,

    s.y2000,
    s.y2001,
    s.y2002,
    s.y2003,
    s.y2004,
    s.y2005,
    s.y2006,
    s.y2007,
    s.y2008,
    s.y2009,

    s.y2010,
    s.y2011,
    s.y2012,
    s.y2013,
    s.y2014,
    s.y2015,
    s.y2016,
    s.y2017,
    s.y2018,
    s.y2019,

    s.y2020,
    s.y2021,
    s.y2022,
    s.y2023,
    s.y2024

FROM worldbank_stage s
INNER JOIN indicator_catalog c
    ON s.indicator_code = c.indicator_code;

-- ============================================================
-- SECTION 5: LONG-FORMAT ANALYTICAL DATASET
-- Converts the year columns from wide format into individual
-- Year and Value rows for use by R visual analytics.
-- Missing observations are removed from the analytical dataset.
-- ============================================================

USE malaysia_finance;

DROP TABLE IF EXISTS analysis_dataset_full;

CREATE TABLE analysis_dataset_full
STORED AS ORC
AS
SELECT
    country_name,
    country_code,
    indicator_code,
    indicator_name,
    indicator_label,
    theme,
    unit,
    desired_direction,
    display_order,
    year,
    CAST(value_raw AS DOUBLE) AS value

FROM selected_indicators

LATERAL VIEW STACK(
    25,

    2000, y2000,
    2001, y2001,
    2002, y2002,
    2003, y2003,
    2004, y2004,
    2005, y2005,
    2006, y2006,
    2007, y2007,
    2008, y2008,
    2009, y2009,

    2010, y2010,
    2011, y2011,
    2012, y2012,
    2013, y2013,
    2014, y2014,
    2015, y2015,
    2016, y2016,
    2017, y2017,
    2018, y2018,
    2019, y2019,

    2020, y2020,
    2021, y2021,
    2022, y2022,
    2023, y2023,
    2024, y2024

) unpivoted_years AS year, value_raw

WHERE value_raw IS NOT NULL
  AND TRIM(value_raw) <> '';

-- ============================================================
-- SECTION 6: DASHBOARD DATASET
-- Creates the simplified long-format dataset required by the
-- R visual analytics storyboard and dashboard.
--
-- Final CSV columns:
-- Indicator, Theme, Year, Value
-- ============================================================

DROP TABLE IF EXISTS analysis_dataset_dashboard;

CREATE TABLE analysis_dataset_dashboard
STORED AS ORC
AS
SELECT
    indicator_label AS indicator,
    theme,
    year,
    value
FROM analysis_dataset_full;

-- ============================================================
-- SECTION 7: HEATMAP DATASET
-- Converts the long dashboard dataset into a wide analytical
-- table suitable for correlation analysis.
-- One record represents one year.
-- ============================================================

DROP TABLE IF EXISTS analysis_dataset_heatmap;

CREATE TABLE analysis_dataset_heatmap
STORED AS ORC
AS
SELECT

    year,

    MAX(CASE WHEN indicator='GDP Growth'
        THEN value END) AS gdp_growth,

    MAX(CASE WHEN indicator='Inflation'
        THEN value END) AS inflation,

    MAX(CASE WHEN indicator='Unemployment'
        THEN value END) AS unemployment,

    MAX(CASE WHEN indicator='Income per Capita'
        THEN value END) AS income_per_capita,

    MAX(CASE WHEN indicator='Household Consumption'
        THEN value END) AS household_consumption,

    MAX(CASE WHEN indicator='Gross Domestic Savings'
        THEN value END) AS gross_domestic_savings,

    MAX(CASE WHEN indicator='Lending Rate'
        THEN value END) AS lending_rate,

    MAX(CASE WHEN indicator='Deposit Rate'
        THEN value END) AS deposit_rate,

    MAX(CASE WHEN indicator='Domestic Credit'
        THEN value END) AS domestic_credit,

    MAX(CASE WHEN indicator='Non-performing Loans'
        THEN value END) AS nonperforming_loans

FROM analysis_dataset_dashboard

GROUP BY year;

-- ============================================================
-- SECTION 8A: EXECUTIVE KPI SUMMARY
-- Creates one summary record for each indicator.
-- Includes descriptive statistics, latest values and long-term
-- percentage change.
-- ============================================================

DROP TABLE IF EXISTS executive_kpi_summary;

CREATE TABLE executive_kpi_summary
STORED AS ORC
AS
WITH indicator_statistics AS (
    SELECT
        indicator,
        theme,
        AVG(value) AS mean_value,
        MIN(value) AS minimum_value,
        MAX(value) AS maximum_value,
        STDDEV_SAMP(value) AS std_dev,
        MIN(year) AS start_year,
        MAX(year) AS end_year,
        COUNT(value) AS observations
    FROM analysis_dataset_dashboard
    GROUP BY indicator, theme
),

first_latest_years AS (
    SELECT
        indicator,
        MIN(year) AS first_year,
        MAX(year) AS latest_year
    FROM analysis_dataset_dashboard
    GROUP BY indicator
),

first_latest_values AS (
    SELECT
        y.indicator,
        y.first_year,
        f.value AS first_value,
        y.latest_year,
        l.value AS latest_value
    FROM first_latest_years y

    LEFT JOIN analysis_dataset_dashboard f
        ON y.indicator = f.indicator
       AND y.first_year = f.year

    LEFT JOIN analysis_dataset_dashboard l
        ON y.indicator = l.indicator
       AND y.latest_year = l.year
)

SELECT
    s.indicator,
    s.theme,

    ROUND(s.mean_value, 2) AS mean_value,
    ROUND(s.minimum_value, 2) AS minimum_value,
    ROUND(s.maximum_value, 2) AS maximum_value,
    ROUND(s.std_dev, 2) AS std_dev,

    s.start_year,
    s.end_year,
    s.observations,

    f.latest_year,
    ROUND(f.latest_value, 2) AS latest_value,

    f.first_year,
    ROUND(f.first_value, 2) AS first_value,

    f.latest_year AS latest_year_for_change,
    ROUND(f.latest_value, 2) AS latest_value_for_change,

    ROUND(
        CASE
            WHEN f.first_value IS NULL OR f.first_value = 0
                THEN NULL
            ELSE
                ((f.latest_value - f.first_value) / f.first_value) * 100
        END,
        2
    ) AS percent_change

FROM indicator_statistics s
INNER JOIN first_latest_values f
    ON s.indicator = f.indicator;

-- ============================================================
-- SECTION 8B: INDICATOR SUMMARY
-- Summarises data availability for each selected indicator.
-- ============================================================

DROP TABLE IF EXISTS indicator_summary;

CREATE TABLE indicator_summary
STORED AS ORC
AS
SELECT
    indicator,
    COUNT(value) AS observations,
    MIN(year) AS start_year,
    MAX(year) AS end_year
FROM analysis_dataset_dashboard
GROUP BY indicator;

-- ============================================================
-- SECTION 8C: THEME SUMMARY
-- Summarises indicator and observation coverage by theme.
-- ============================================================

DROP TABLE IF EXISTS theme_summary;

CREATE TABLE theme_summary
STORED AS ORC
AS
SELECT
    theme,
    COUNT(DISTINCT indicator) AS indicators,
    COUNT(value) AS observations
FROM analysis_dataset_dashboard
GROUP BY theme;

-- ============================================================
-- SECTION 8D: PROJECT METADATA
-- Stores descriptive information about the project, source,
-- analytical scope and downstream visualisation platform.
-- ============================================================

DROP TABLE IF EXISTS project_metadata;

CREATE TABLE project_metadata (
    parameter STRING,
    value     STRING
)
STORED AS ORC;

INSERT INTO TABLE project_metadata

SELECT
    'Project Name',
    'Malaysia Financial Analytics Platform'

UNION ALL

SELECT
    'Country',
    'Malaysia'

UNION ALL

SELECT
    'Data Source',
    'World Bank Open Data'

UNION ALL

SELECT
    'Study Period',
    '2000-2024'

UNION ALL

SELECT
    'Indicators',
    '10'

UNION ALL

SELECT
    'Themes',
    '3'

UNION ALL

SELECT
    'ETL Platform',
    'Apache Hive'

UNION ALL

SELECT
    'Visualisation Platform',
    'R'

UNION ALL

SELECT
    'Repository Platform',
    'GitHub'

UNION ALL

SELECT
    'Dashboard Platform',
    'R Shiny';

