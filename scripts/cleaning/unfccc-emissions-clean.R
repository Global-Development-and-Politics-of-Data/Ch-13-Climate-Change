## ----setup, include=FALSE----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      knitr.duplicate.label = "allow",
                      tidy.opts=list(width.cutoff=50), 
                      tidy=TRUE)



## ----eval=FALSE, warning=FALSE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
## install.packages("openxlsx")
## install.packages("janitor")
## install.packages("tidyverse")
## install.packages("countrycode")
## install.packages("fuzzyjoin")
## install.packages("knitr")


## ----load libraries, warning=FALSE, message=FALSE----------------------------------------------------------------------------------------------------------------------------------------------------------
library(openxlsx)
library(janitor)
library(tidyverse)
library(countrycode)
library(fuzzyjoin)
library(knitr)


## ----import data (Annex I)---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
annex_i_emissions <- openxlsx::read.xlsx("../../data/annual-net-emissions-removals-annex-i-raw.xlsx",
                                         startRow = 5, 
                                         fillMergedCells = TRUE, 
                                         rows = 5:96) %>% 
  janitor::clean_names()


## ----import data (Non-Annex I)-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
non_annex_i_emissions <- openxlsx::read.xlsx("../../data/annual-net-emissions-removals-non-annex-i-raw.xlsx",
                                             startRow = 5, 
                                             fillMergedCells = TRUE, 
                                             rows = 5:96) %>% 
  janitor::clean_names()


## ----clean main dataframe (Annex I), warning=FALSE, message=FALSE------------------------------------------------------------------------------------------------------------------------------------------
annex_i_emissions <- annex_i_emissions[-c(1),]

colnames(annex_i_emissions)[1] <- "party"

annex_i_emissions <- annex_i_emissions %>% 
  dplyr::rename_all(funs(stringr::str_replace_all(., "aggregate_gh_gs", "ghg")))


## ----clean main dataframe (Non-Annex I), warning=FALSE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------
non_annex_i_emissions <- non_annex_i_emissions[-c(1),]

colnames(non_annex_i_emissions)[1] <- "party"

non_annex_i_emissions <- non_annex_i_emissions %>% 
  dplyr::rename_all(funs(stringr::str_replace_all(., "aggregate_gh_gs", "ghg")))


## ----disaggregate dataframe by gas type (Annex I)----------------------------------------------------------------------------------------------------------------------------------------------------------
annex_i_emissions_co2 <- annex_i_emissions %>% 
  dplyr::select("party", "gas", contains("co2")) %>% 
  dplyr::rename("base_year" = "co2")

colnames(annex_i_emissions_co2)[4:32] <- 1990:2018

annex_i_emissions_ghg <- annex_i_emissions %>% 
  dplyr::select("party", "gas", contains("ghg")) %>% 
  dplyr::rename("base_year" = "ghg")

colnames(annex_i_emissions_ghg)[4:32] <- 1990:2018


## ----disaggregate dataframe by gas type (Non-Annex I)------------------------------------------------------------------------------------------------------------------------------------------------------
non_annex_i_emissions_co2 <- non_annex_i_emissions %>% 
  dplyr::select("party", "gas", contains("co2"))

colnames(non_annex_i_emissions_co2)[3:31] <- 1990:2018

non_annex_i_emissions_ghg <- non_annex_i_emissions %>% 
  dplyr::select("party", "gas", contains("ghg"))

colnames(non_annex_i_emissions_ghg)[3:31] <- 1990:2018


## ----convert datasets to long (Annex I)--------------------------------------------------------------------------------------------------------------------------------------------------------------------
annex_i_emissions_co2 <- annex_i_emissions_co2 %>% 
  tidyr::gather(year, co2, base_year:`2018`) %>% 
  mutate(group = "Annex I")

annex_i_emissions_ghg <- annex_i_emissions_ghg %>% 
  tidyr::gather(year, ghg, base_year:`2018`) %>% 
  mutate(group = "Annex I")


## ----convert datasets to long (Non-Annex I)----------------------------------------------------------------------------------------------------------------------------------------------------------------
non_annex_i_emissions_co2 <- non_annex_i_emissions_co2 %>% 
  tidyr::gather(year, co2, `1990`:`2018`) %>% 
  mutate(group = "Non-Annex I")

non_annex_i_emissions_ghg <- non_annex_i_emissions_ghg %>% 
  tidyr::gather(year, ghg, `1990`:`2018`) %>% 
  mutate(group = "Non-Annex I")


## ----merge datasets back (Annex I)-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
annex_i_emissions <- annex_i_emissions_ghg %>% 
  dplyr::full_join(annex_i_emissions_co2, by =c("party", "gas", "year", "group"))

rm(annex_i_emissions_co2,annex_i_emissions_ghg)


## ----merge datasets back (Non-Annex I)---------------------------------------------------------------------------------------------------------------------------------------------------------------------
non_annex_i_emissions <- non_annex_i_emissions_ghg %>% 
  dplyr::full_join(non_annex_i_emissions_co2, by =c("party", "gas", "year", "group"))

rm(non_annex_i_emissions_co2,non_annex_i_emissions_ghg)


## ----Merge Annex I and Non-Annex I dataframes, message=FALSE, warning=FALSE--------------------------------------------------------------------------------------------------------------------------------
unfccc_emissions <- dplyr::bind_rows(annex_i_emissions,non_annex_i_emissions) %>%
  dplyr::rename("type" = "gas") %>% 
  dplyr::mutate(type = stringr::str_replace(type,"Total GHG emissions excluding LULUCF/LUCF", "Total GHG emissions without LULUCF")) %>% 
  dplyr::mutate(type = stringr::str_replace(type,"Total GHG emissions including LULUCF/LUCF", "Total GHG emissions with LULUCF")) %>%
  readr::type_convert() %>%
  dplyr::mutate_if(is.character, as.factor)


## ----Merge region dataframe with unfccc_emissions datafram, message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------------------------
region <- countrycode::codelist %>% select(country.name.en, un.region.name) %>% mutate(country.name.en = stringr::str_replace_all(country.name.en, c("Antigua & Barbuda" = "Antigua and Barbuda", "Bosnia & Herzegovina" = "Bosnia and Herzegovina", "Cape Verde" = "Cabo Verde", "Congo - Kinshasa" = "Congo", "Côte d’Ivoire" = "Cote d'Ivoire", "Congo - Brazzaville" = "Democratic Republic of Congo", "North Korea" = "Democratic People's Republic of Korea")))

unfccc_emissions_test <- unfccc_emissions %>% fuzzyjoin::regex_left_join(region, by= c(party = "country.name.en")) %>% dplyr::rename(region = un.region.name) %>% select(-country.name.en)
unfccc_emissions_test$region[unfccc_emissions_test$party %in% c("European Union (Convention)", "European Union (KP)")] <- "Europe"

regions_na <- unfccc_emissions_test %>% dplyr::filter(is.na(un.region.name))


## ----export as a csv file----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
write.csv(UNFCCC_Emissions, "unfccc-emissions-clean.csv")


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE---------------------------------------------------------------------------------------------------------------------------------------
## knitr::purl("unfccc-emissions.Rmd", "unfccc-emissions-clean.R")

