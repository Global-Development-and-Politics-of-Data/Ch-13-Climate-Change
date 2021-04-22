# Summary

This section includes all the steps in the data management process, where we use the raw data from the [`data`](https://github.com/Global-Development-and-Politics-of-Data/Climate-Change/tree/main/data) folder to produce a clean dataset ready for analysis. The process includes the following steps:

1. Import raw datasets
2. Rename variables for consistency[[1]](#1)
3. Convert data from wide to long (steps are detailed in the tutorial)
4. Merge datasets
5. Produce clean dataset in CSV format and associated R script


# Directory Contents

| File Name                                          |  Content                        |
|----------------------------------------------------|---------------------------------|
| UNFCCC-Emissions-clean.csv                         | Final UNFCCC GHG inventories dataset in long format|
| UNFCCC-Emissions-clean.R                           | R script to produce final UNFCCC GHG inventories dataset|
| UNFCCC-Emissions.docx                              | Word document tutorial on data cleaning and wrangling UNFCCC raw dataset|
| UNFCCC-Emissions.Rmd                               | R markdown tutorial on data cleaning and wrangling UNFCCC raw dataset|


# Codebook

The following codebook is for the clean dataset called `unfccc-emissions-clean.csv`.


| Variable      | Description     | Unit of measurement | Data type     | Notes        |
| -----------   | -----------     | ------------------- | ------------- | ------------ |
| `party`       | Territory name  | Not applicable      | Categorical   |              |
| `type`        | Emissions that include or exclude<br />Land Use, Land-Use Change and Forestry (LULUCF)| Not applicable | Categorical |      |
| `year`        | Gregorian year  | Annual year         | Categorical   |              |
| `ghg`         | Total GHG emissions | kt or Gg of CO<sub>2</sub> equivalent | Numerical | GHG include the following: <br /> 1. Carbon dioxide (CO<sub>2</sub>) <br /> 2. Methane (CH<sub>4</sub>) <br /> 3. Nitrous oxide (N<sub>2</sub>) <br /> 4. Hydrofluorocarbons (HFCs) <br /> 5. Perfluorocarbons (PFCs) <br /> 6. Sulphur Hexafluoride (SF<sub>6</sub>) |
| `co2`         | Total CO<sub>2</sub> emissions | kt or Gg of CO<sub>2</sub> | Numerical | Only measures CO<sub>2</sub> emissions |
| `region`      | Region name for each country based on the United Nations designation | Not applicable | Categorical |           |



# References

<a id = "1">[1]</a>
Karl W. Broman and Kara H. Woo, “Data Organization in Spreadsheets,” The American Statistician 72, no. 1 (January 2, 2018): 2–10, [link](https://doi.org/10.1080/00031305.2017.1375989).