# Malaysia Financial and Economic Indicators Analysis Using Apache Hive and Python

## Project Overview

This project was prepared for the Data Management assignment under the Master of Science in Data Science and Analytics programme.

The selected industry is the finance and banking industry. The purpose of this project is to analyse selected Malaysia financial and economic indicators using open-source data from the World Bank.

Apache Hive was used through Ambari Hive View to manage and filter the dataset. Python in VS Code Jupyter Notebook was then used for data cleaning, transformation, visualisation, insights and recommendations.

## Tools Used

- Apache Hive
- Ambari Hive View
- HDFS
- VS Code
- Jupyter Notebook
- Python
- Pandas
- Matplotlib
- GitHub

## Dataset

The dataset used in this project is the World Bank Malaysia dataset in CSV format.

The selected indicators are:

- GDP growth (annual %)
- Inflation, consumer prices (annual %)
- Unemployment, total (% of total labor force)
- Domestic credit to private sector by banks (% of GDP)
- Bank non-performing loans to total gross loans (%)
- Lending interest rate (%)
- Deposit interest rate (%)
- Broad money growth (annual %)

## Project Workflow

1. The raw World Bank CSV file was prepared and uploaded into HDFS.
2. Apache Hive was used to create an external table.
3. Hive was used to filter selected finance and economic indicators.
4. The selected dataset was exported as `selected_indicators.csv`.
5. Python was used in VS Code Jupyter Notebook to clean and reshape the data.
6. Visualisations were created using Matplotlib.
7. Insights, recommendations and conclusion were written based on the analysis.

## Data Cleaning

The cleaning process included:

- removing Hive table prefixes from column names
- converting the data from wide format to long format
- converting year values into integer format
- converting indicator values into numeric format
- removing missing values
- keeping records from 2000 to 2024

## Data Visualisations

The project includes visualisations for:

- GDP growth trend
- Inflation trend
- Unemployment trend
- Domestic credit to private sector by banks
- Bank non-performing loans
- Key economic indicators comparison

The chart images are saved in the `visuals` folder.

## Insights and Explanations

The analysis shows that GDP growth, inflation and unemployment are useful for understanding Malaysia's general economic condition.

For the banking industry, domestic credit to the private sector shows how banks support households and businesses. Bank non-performing loans are important because they show credit risk and lending quality.

## Recommendations

Based on the analysis:

1. Banks should continue monitoring non-performing loans.
2. Financial institutions should support productive lending to businesses and SMEs.
3. Inflation and unemployment should be considered when evaluating repayment ability.
4. Data analytics can help banks monitor financial risk.
5. Digital banking can support better financial inclusion.

## Conclusion

This project demonstrates a complete data management workflow using open-source data. Apache Hive was used for data storage and filtering, while Python was used for data cleaning, visualisation and interpretation.

Overall, the project shows how financial and economic indicators can support decision-making in the finance and banking industry.

## Repository Structure

```text
malaysia-financial-hive-project/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── hive/
│   └── hive_script.sql
│
├── notebooks/
│   └── malaysia_financial_analysis.ipynb
│
├── visuals/
│
├── README.md
└── requirements.txt