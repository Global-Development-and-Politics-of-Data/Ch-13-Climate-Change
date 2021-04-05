# Introduction

We've collected data on country emissions from the United Nations Framework Convention on Climate Change's (UNFCCC) Greenhouse gas (GHG) [Data Interface](https://di.unfccc.int/) website. We've specifically conducted 'Flexible queries' both for [Annex I](https://di.unfccc.int/flex_annex1) and [Non-Annex I](https://di.unfccc.int/flex_non_annex1) parties to collect data on different types of GHG emissions as well as three types of general statistics: population, land size, and nominal GDP is US$ billions.

Details on how to use the interface and query specific data can be found [here](https://unfccc.int/process-and-meetings/transparency-and-reporting/greenhouse-gas-data/data-interface-help#eq-7). The website also provides higher-level information on major variables, and we will go in detail below on the types of variables we will focus on for this module.

# GHG Emissions

Generally speaking, there are six steps required to query the raw dataset that is provided in this module. The data collected in this module is as of **April 4, 2021**.

## Annex I

The following [steps](https://di.unfccc.int/flex_annex1) are for each drop-down menu as shown in the figure below.

![](../../Figures/Flexible-Queries-Annex-I.png)

1.  **Select Party**: 'Annex I'

2.  **Select Year**: 'Select All'

3.  **Select Category**: 'Total GHG emissions without LULUCF' and 'Total GHG emissions with LULUCF'

4.  **Select Classification**: 'Total for Category'

5.  **Select Type of Value**: 'Net emissions/removals'

6.  **Select Gas**: 'Aggregate GHGs,' 'CO~2~,' and 'CH~4~'

Once the query is submitted and you see the table go to the 'Unit' tab and unselect 'kt,' which means all your GHG emissions values are in kt CO~2~ equivalent.

## Non-Annex I

The Non-Annex I [steps](https://di.unfccc.int/flex_non_annex1) are similar to the previous steps for Annex I except for the following:

-   **Select Party**: 'Select All'

-   **Select Category**: 'Total GHG emissions excluding LULUCF/LUCF' and 'Total GHG emissions including LULUCF/LUCF'

Once the query is submitted and you see the table go to the 'Unit' tab and unselect 'Gg,' which means all your GHG emissions values are in Gg CO~2~ equivalent.

Please note that $1\; kt = 1\; Gg$.


## Codebook

| Variable      | Description     | Unit of measurement | Data type     | Notes        |
| -----------   | -----------     | ------------------- | ------------- | ------------ |
| `party`       | Territory name  | Not applicable      | Categorical   |              |
| `type`        | Text        |
