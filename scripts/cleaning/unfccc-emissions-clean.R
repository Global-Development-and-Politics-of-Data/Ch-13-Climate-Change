## ----setup, include=FALSE------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      knitr.duplicate.label = "allow",
                      tidy.opts = list(width.cutoff = 40), 
                      tidy = TRUE,
                      strip.white = FALSE)



## ----eval=FALSE, warning=FALSE, message=FALSE----------------------------------------------------------------------
## install.packages("here")
## install.packages("openxlsx")
## install.packages("janitor")
## install.packages("tidyverse")
## install.packages("countrycode")
## install.packages("fuzzyjoin")
## install.packages("knitr")


## ----load libraries, warning=FALSE, message=FALSE------------------------------------------------------------------
library(here)
library(openxlsx)
library(janitor)
library(tidyverse)
library(countrycode)
library(fuzzyjoin)
library(knitr)


## ----import data (Annex I)-----------------------------------------------------------------------------------------
annex_i_emissions <- openxlsx::read.xlsx(here::here("data", "annual-net-emissions-removals-annex-i-raw.xlsx"),
                                         startRow = 5, 
                                         fillMergedCells = TRUE, 
                                         rows = 5:96) %>% 
  janitor::clean_names()


## ----import data (Non-Annex I)-------------------------------------------------------------------------------------
non_annex_i_emissions <- openxlsx::read.xlsx(here::here("data", "annual-net-emissions-removals-non-annex-i-raw.xlsx"),
                                             startRow = 5, 
                                             fillMergedCells = TRUE, 
                                             rows = 5:302) %>% 
  janitor::clean_names()


## ----clean main dataframe (Annex I), warning=FALSE, message=FALSE--------------------------------------------------
annex_i_emissions <- annex_i_emissions[-c(1),]

colnames(annex_i_emissions)[1] <- "country"

annex_i_emissions <- annex_i_emissions %>% 
  dplyr::rename_all(funs(stringr::str_replace_all(., "aggregate_gh_gs", "ghg")))


## ----clean main dataframe (Non-Annex I), warning=FALSE, message=FALSE----------------------------------------------
non_annex_i_emissions <- non_annex_i_emissions[-c(1),]

colnames(non_annex_i_emissions)[1] <- "country"

non_annex_i_emissions <- non_annex_i_emissions %>% 
  dplyr::rename_all(funs(stringr::str_replace_all(., "aggregate_gh_gs", "ghg")))


## ----disaggregate dataframe by gas type (Annex I)------------------------------------------------------------------
annex_i_emissions_co2 <- annex_i_emissions %>% 
  dplyr::select("country", "gas", contains("co2")) %>% 
  dplyr::rename("base_year" = "co2")

colnames(annex_i_emissions_co2)[4:32] <- 1990:2018

annex_i_emissions_ghg <- annex_i_emissions %>% 
  dplyr::select("country", "gas", contains("ghg")) %>% 
  dplyr::rename("base_year" = "ghg")

colnames(annex_i_emissions_ghg)[4:32] <- 1990:2018


## ----disaggregate dataframe by gas type (Non-Annex I)--------------------------------------------------------------
non_annex_i_emissions_co2 <- non_annex_i_emissions %>% 
  dplyr::select("country", "gas", contains("co2"))

colnames(non_annex_i_emissions_co2)[3:31] <- 1990:2018

non_annex_i_emissions_ghg <- non_annex_i_emissions %>% 
  dplyr::select("country", "gas", contains("ghg"))

colnames(non_annex_i_emissions_ghg)[3:31] <- 1990:2018


## ----convert datasets to long (Annex I)----------------------------------------------------------------------------
annex_i_emissions_co2 <- annex_i_emissions_co2 %>% 
  tidyr::gather(year, co2, base_year:`2018`) %>% 
  mutate(group = "Annex I")

annex_i_emissions_ghg <- annex_i_emissions_ghg %>% 
  tidyr::gather(year, ghg, base_year:`2018`) %>% 
  mutate(group = "Annex I")


## ----convert datasets to long (Non-Annex I)------------------------------------------------------------------------
non_annex_i_emissions_co2 <- non_annex_i_emissions_co2 %>% 
  tidyr::gather(year, co2, `1990`:`2018`) %>% 
  mutate(group = "Non-Annex I")

non_annex_i_emissions_ghg <- non_annex_i_emissions_ghg %>% 
  tidyr::gather(year, ghg, `1990`:`2018`) %>% 
  mutate(group = "Non-Annex I")


## ----merge datasets back (Annex I)---------------------------------------------------------------------------------
annex_i_emissions <- annex_i_emissions_ghg %>% 
  dplyr::full_join(annex_i_emissions_co2, by =c("country", "gas", "year", "group"))

rm(annex_i_emissions_co2,annex_i_emissions_ghg)


## ----merge datasets back (Non-Annex I)-----------------------------------------------------------------------------
non_annex_i_emissions <- non_annex_i_emissions_ghg %>% 
  dplyr::full_join(non_annex_i_emissions_co2, by =c("country", "gas", "year", "group"))

rm(non_annex_i_emissions_co2,non_annex_i_emissions_ghg)


## ----Merge Annex I and Non-Annex I dataframes, message=FALSE, warning=FALSE----------------------------------------
unfccc_emissions <- dplyr::bind_rows(annex_i_emissions,non_annex_i_emissions) %>%
  dplyr::rename("type" = "gas") %>% 
  dplyr::mutate(type = stringr::str_replace(type, 
                                            "Total GHG emissions excluding LULUCF/LUCF", 
                                            "Total GHG emissions without LULUCF")) %>% 
  dplyr::mutate(type = stringr::str_replace(type, 
                                            "Total GHG emissions including LULUCF/LUCF", 
                                            "Total GHG emissions with LULUCF")) %>%
  readr::type_convert() %>%
  dplyr::mutate_if(is.character, as.factor)


## ----Merge region dataframe with unfccc_emissions dataframe, message=FALSE, warning=FALSE--------------------------
region <- countrycode::codelist %>% 
  dplyr::select(country.name.en, region, iso3c) %>% 
  dplyr::mutate(country.name.en = stringr::str_replace_all(country.name.en, 
                                                    c("Antigua & Barbuda" = "Antigua and Barbuda", 
                                                      "Bosnia & Herzegovina" = "Bosnia and Herzegovina", 
                                                      "Cape Verde" = "Cabo Verde", 
                                                      "Congo - Kinshasa" = "Congo", 
                                                      "Côte d’Ivoire" = "Cote d'Ivoire", 
                                                      "Congo - Brazzaville" = "Democratic Republic of Congo",
                                                      "Laos" = "Lao People's Democratic Republic",
                                                      "Micronesia \\(Federated States of\\)" = "Micronesia",
                                                      "Myanmar \\(Burma\\)" = "Myanmar",
                                                      "St. Lucia" = "Saint Lucia",
                                                      "St. Vincent & Grenadines" = "Saint Vincent and the Grenadines",
                                                      "São Tomé & Príncipe" = "Sao Tome and Principe",
                                                      "Palestinian Territories" = "State of Palestine",
                                                      "Trinidad & Tobago" = "Trinidad and Tobago",
                                                      "North Korea" = "Democratic People's Republic of Korea",
                                                      "South Korea" = "Republic of Korea",
                                                      "St. Kitts & Nevis" = "Saint Kitts and Nevis",
                                                      "Vietnam" = "Viet Nam")))

unfccc_emissions <- unfccc_emissions %>% 
  fuzzyjoin::regex_left_join(region, by = c(country = "country.name.en")) %>%
  dplyr::rename(iso = iso3c) %>% 
  dplyr::filter(!(country == "United Kingdom of Great Britain and Northern Ireland" & iso == "IRL"),
                !(country == "Guinea-Bissau" & iso == "GIN"),
                !(country == "Papua New Guinea" & iso == "GIN"),
                !(country == "Democratic People's Republic of Korea" & iso == "KOR"),
                !(country == "Dominican Republic" & iso == "DMA"),
                !(country == "Nigeria" & iso == "NER"),
                !(country == "South Sudan" & iso == "SDN")) %>%
  dplyr::select(-country.name.en) %>%
  dplyr::relocate(iso, .before = country) %>%
  dplyr::relocate(c(region, group, year), .after = country)
  

unfccc_emissions$region[unfccc_emissions$country %in% c("European Union (Convention)", "European Union (KP)")] <- "Europe & Central Asia"


## ----export as a csv file------------------------------------------------------------------------------------------
utils::write.csv(unfccc_emissions, "unfccc-emissions-clean.csv", row.names = FALSE)


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE-----------------------------------------------
## knitr::purl("unfccc-emissions-clean.Rmd", "unfccc-emissions-clean.R")
## knitr::write_bib(.packages(), "packages.bib")

