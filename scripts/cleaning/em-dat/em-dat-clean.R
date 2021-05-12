## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      knitr.duplicate.label = "allow",
                      tidy.opts = list(width.cutoff = 40), 
                      tidy = TRUE,
                      strip.white = FALSE)



## ----libraries, message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(here)
library(readxl)
library(janitor)
library(dplyr)
library(stringr)
library(scales)


## ---- eval = FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## em_dat <- readxl::read_excel(here::here("data/em-dat", "emdat-public-2021-03-24-query-uid-DuX1xq-raw.xlsx"),
##                      skip = 6)


## ---- eval = FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## em_dat <- janitor::clean_names(em_dat)


## ----import em-dat dataset, warning=FALSE, message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------
em_dat <- readxl::read_excel(here::here("data/em-dat", "emdat-public-2021-03-24-query-uid-DuX1xq-raw.xlsx"), skip = 6) %>%
          janitor::clean_names() 


## ----select variables, warning=FALSE, message=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------
em_dat_sub <- em_dat %>% 
  dplyr::select(iso, country, year, disaster_type, total_deaths, no_injured, no_affected, no_homeless, total_affected, total_damages_000_us) %>% 
  dplyr::filter(str_detect(disaster_type, "Drought|Extreme temperature|Flood|Storm|Wildfire"))


## ----em-dat sub for merging, warning=FALSE, message=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------
em_dat_climate <- em_dat_sub %>% 
  dplyr::filter(as.numeric(year) >= 1990 & 
                  !(is.na(total_deaths) & 
                      is.na(no_injured) & 
                      is.na(no_affected) & 
                      is.na(no_homeless) & 
                      is.na(total_affected) & 
                      is.na(total_damages_000_us))) %>% 
  dplyr::group_by(iso, country, year, disaster_type) %>%
  dplyr::summarise_all(funs(sum), na.rm = TRUE) %>%
  dplyr::mutate(country = str_remove(country, " \\(the\\)")) %>%
  dplyr::mutate(country = str_replace_all(country, c("Korea \\(the Republic of\\)" = "Republic of Korea",
                                                     "Congo \\(the Democratic of\\)" = "Democratic Republic of the Congo",
                                                     "Tanzania, United Republic of" = "United Republic of Tanzania",
                                                     "Taiwan \\(Province of China\\)" = "China"))) %>%
  dplyr::na_if(., 0)

utils::write.csv(em_dat_climate, here("scripts/cleaning/em-dat", "em-dat-clean.csv"), row.names = FALSE)

rm(em_dat, em_dat_climate, em_dat_sub)


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------------------------------------------------
## knitr::purl("em-dat-cleaning.Rmd", "em-dat-cleaning.R")
## knitr::write_bib(.packages(), "packages.bib")

