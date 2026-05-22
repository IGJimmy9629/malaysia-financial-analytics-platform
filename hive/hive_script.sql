CREATE DATABASE IF NOT EXISTS malaysia_finance;
USE malaysia_finance;

DROP TABLE IF EXISTS worldbank_raw;

CREATE EXTERNAL TABLE worldbank_raw (
  country_name STRING,
  country_code STRING,
  indicator_name STRING,
  indicator_code STRING,
  y1960 DOUBLE, y1961 DOUBLE, y1962 DOUBLE, y1963 DOUBLE, y1964 DOUBLE,
  y1965 DOUBLE, y1966 DOUBLE, y1967 DOUBLE, y1968 DOUBLE, y1969 DOUBLE,
  y1970 DOUBLE, y1971 DOUBLE, y1972 DOUBLE, y1973 DOUBLE, y1974 DOUBLE,
  y1975 DOUBLE, y1976 DOUBLE, y1977 DOUBLE, y1978 DOUBLE, y1979 DOUBLE,
  y1980 DOUBLE, y1981 DOUBLE, y1982 DOUBLE, y1983 DOUBLE, y1984 DOUBLE,
  y1985 DOUBLE, y1986 DOUBLE, y1987 DOUBLE, y1988 DOUBLE, y1989 DOUBLE,
  y1990 DOUBLE, y1991 DOUBLE, y1992 DOUBLE, y1993 DOUBLE, y1994 DOUBLE,
  y1995 DOUBLE, y1996 DOUBLE, y1997 DOUBLE, y1998 DOUBLE, y1999 DOUBLE,
  y2000 DOUBLE, y2001 DOUBLE, y2002 DOUBLE, y2003 DOUBLE, y2004 DOUBLE,
  y2005 DOUBLE, y2006 DOUBLE, y2007 DOUBLE, y2008 DOUBLE, y2009 DOUBLE,
  y2010 DOUBLE, y2011 DOUBLE, y2012 DOUBLE, y2013 DOUBLE, y2014 DOUBLE,
  y2015 DOUBLE, y2016 DOUBLE, y2017 DOUBLE, y2018 DOUBLE, y2019 DOUBLE,
  y2020 DOUBLE, y2021 DOUBLE, y2022 DOUBLE, y2023 DOUBLE, y2024 DOUBLE,
  y2025 DOUBLE,
  extra_column STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar" = "\""
)
STORED AS TEXTFILE
LOCATION '/user/maria_dev/malaysia_finance/raw'
TBLPROPERTIES ("skip.header.line.count"="1");

DROP TABLE IF EXISTS selected_indicators;

CREATE TABLE selected_indicators AS
SELECT *
FROM worldbank_raw
WHERE indicator_name IN (
  'GDP growth (annual %)',
  'Inflation, consumer prices (annual %)',
  'Unemployment, total (% of total labor force) (modeled ILO estimate)',
  'Domestic credit to private sector by banks (% of GDP)',
  'Bank nonperforming loans to total gross loans (%)',
  'Lending interest rate (%)',
  'Deposit interest rate (%)',
  'Broad money growth (annual %)'
);

DROP TABLE IF EXISTS malaysia_financial_long;

CREATE TABLE malaysia_financial_long AS
SELECT country_name, country_code, indicator_name, indicator_code, 2000 AS year, y2000 AS value FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2001, y2001 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2002, y2002 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2003, y2003 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2004, y2004 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2005, y2005 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2006, y2006 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2007, y2007 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2008, y2008 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2009, y2009 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2010, y2010 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2011, y2011 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2012, y2012 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2013, y2013 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2014, y2014 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2015, y2015 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2016, y2016 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2017, y2017 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2018, y2018 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2019, y2019 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2020, y2020 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2021, y2021 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2022, y2022 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2023, y2023 FROM selected_indicators
UNION ALL SELECT country_name, country_code, indicator_name, indicator_code, 2024, y2024 FROM selected_indicators;

DROP TABLE IF EXISTS malaysia_financial_clean;

CREATE TABLE malaysia_financial_clean AS
SELECT *
FROM malaysia_financial_long
WHERE value IS NOT NULL;

DROP TABLE IF EXISTS indicator_summary;

CREATE TABLE indicator_summary AS
SELECT
  indicator_name,
  MIN(value) AS minimum_value,
  MAX(value) AS maximum_value,
  AVG(value) AS average_value,
  COUNT(value) AS total_records
FROM malaysia_financial_clean
GROUP BY indicator_name;