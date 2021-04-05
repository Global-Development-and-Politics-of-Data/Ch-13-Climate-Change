## ----setup, include=FALSE------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      knitr.duplicate.label = "allow",
                      tidy.opts=list(width.cutoff=50), 
                      tidy=TRUE)



## ----load libraries, warning=FALSE, message=FALSE------------------------------------------
library(openxlsx)
library(tidyverse)
library(janitor)
library(knitr)


## ----import data (Annex I)-----------------------------------------------------------------
Annex_I_emissions <- openxlsx::read.xlsx("Annual-Net-emissions-removals-Annex-I-raw.xlsx", startRow = 5, fillMergedCells = TRUE, rows = 5:96) %>% janitor::clean_names()


## ----import data (Non-Annex I)-------------------------------------------------------------
Non_Annex_I_emissions <- openxlsx::read.xlsx("Annual-Net-emissions-removals-Non-Annex-I-raw.xlsx", startRow = 5, fillMergedCells = TRUE, rows = 5:96) %>% janitor::clean_names()


## ----clean main dataframe (Annex I), warning=FALSE, message=FALSE--------------------------
Annex_I_emissions <- Annex_I_emissions[-c(1),]

colnames(Annex_I_emissions)[1] <- "party"

Annex_I_emissions <- Annex_I_emissions %>% dplyr::rename_all(funs(str_replace_all(., "gh_gs", "ghg")))


## ----clean main dataframe (Non-Annex I), warning=FALSE, message=FALSE----------------------
Non_Annex_I_emissions <- Non_Annex_I_emissions[-c(1),]

colnames(Non_Annex_I_emissions)[1] <- "party"

Non_Annex_I_emissions <- Non_Annex_I_emissions %>% dplyr::rename_all(funs(str_replace_all(., "gh_gs", "ghg")))


## ----disaggregate dataframe by gas type (Annex I)------------------------------------------
Annex_I_emissions_ch4 <- Annex_I_emissions %>% dplyr::select("party", "gas", contains("ch4")) %>% dplyr::rename("base_year" = "ch4")
colnames(Annex_I_emissions_ch4)[4:32] <- 1990:2018

Annex_I_emissions_co2 <- Annex_I_emissions %>% dplyr::select("party", "gas", contains("co2"))%>% dplyr::rename("base_year" = "co2")
colnames(Annex_I_emissions_co2)[4:32] <- 1990:2018

Annex_I_emissions_ghg <- Annex_I_emissions %>% dplyr::select("party", "gas", contains("ghg"))%>% dplyr::rename("base_year" = "aggregate_ghg")
colnames(Annex_I_emissions_ghg)[4:32] <- 1990:2018


## ----disaggregate dataframe by gas type (Non-Annex I)--------------------------------------
Non_Annex_I_emissions_ch4 <- Non_Annex_I_emissions %>% dplyr::select("party", "gas", contains("ch4"))
colnames(Non_Annex_I_emissions_ch4)[3:31] <- 1990:2018

Non_Annex_I_emissions_co2 <- Non_Annex_I_emissions %>% dplyr::select("party", "gas", contains("co2"))
colnames(Non_Annex_I_emissions_co2)[3:31] <- 1990:2018

Non_Annex_I_emissions_ghg <- Non_Annex_I_emissions %>% dplyr::select("party", "gas", contains("ghg"))
colnames(Non_Annex_I_emissions_ghg)[3:31] <- 1990:2018


## ----convert datasets to long (Annex I)----------------------------------------------------
Annex_I_emissions_ch4 <- Annex_I_emissions_ch4 %>% tidyr::gather(year, ch4, base_year:`2018`)

Annex_I_emissions_co2 <- Annex_I_emissions_co2 %>% tidyr::gather(year, co2, base_year:`2018`)

Annex_I_emissions_ghg <- Annex_I_emissions_ghg %>% tidyr::gather(year, ghg, base_year:`2018`)


## ----convert datasets to long (Non-Annex I)------------------------------------------------
Non_Annex_I_emissions_ch4 <- Non_Annex_I_emissions_ch4 %>% tidyr::gather(year, ch4, `1990`:`2018`)

Non_Annex_I_emissions_co2 <- Non_Annex_I_emissions_co2 %>% tidyr::gather(year, co2, `1990`:`2018`)

Non_Annex_I_emissions_ghg <- Non_Annex_I_emissions_ghg %>% tidyr::gather(year, ghg, `1990`:`2018`)


## ----merge datasets back (Annex I)---------------------------------------------------------
Annex_I_emissions <- Annex_I_emissions_ghg %>% dplyr::full_join(Annex_I_emissions_co2, by =c("party", "gas", "year")) %>% dplyr::full_join(Annex_I_emissions_ch4, by =c("party", "gas", "year"))

rm(Annex_I_emissions_ch4,Annex_I_emissions_co2,Annex_I_emissions_ghg)


## ----merge datasets back (Non-Annex I)-----------------------------------------------------
Non_Annex_I_emissions <- Non_Annex_I_emissions_ghg %>% dplyr::full_join(Non_Annex_I_emissions_co2, by =c("party", "gas", "year")) %>% dplyr::full_join(Non_Annex_I_emissions_ch4, by =c("party", "gas", "year"))

rm(Non_Annex_I_emissions_ch4,Non_Annex_I_emissions_co2,Non_Annex_I_emissions_ghg)


## ----Merge Annex I and Non-Annex I dataframes, message=FALSE, warning=FALSE----------------
UNFCCC_Emissions <- dplyr::bind_rows(Annex_I_emissions,Non_Annex_I_emissions) %>%
  dplyr::rename("type" = "gas") %>% 
  dplyr::mutate(type = stringr::str_replace(type,"Total GHG emissions excluding LULUCF/LUCF", "Total GHG emissions without LULUCF")) %>% 
  dplyr::mutate(type = stringr::str_replace(type,"Total GHG emissions including LULUCF/LUCF", "Total GHG emissions with LULUCF")) %>%
  readr::type_convert() %>%
  dplyr::mutate_if(is.character, as.factor)

rm(Annex_I_emissions, Non_Annex_I_emissions)


## ----export as a csv file------------------------------------------------------------------
write.csv(UNFCCC_Emissions, "UNFCCC-Emissions-clean.csv")


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE-----------------------
## knitr::purl("UNFCCC-Emissions.Rmd", "UNFCCC-Emissions-clean.R")

