## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      tab.cap.pre = "Table 13.", tab.cap.sep = ": ",
                      knitr.duplicate.label = "allow",
                      tidy.opts = list(width.cutoff = 40), 
                      tidy = TRUE,
                      strip.white = FALSE)



## ----eval=FALSE, warning=FALSE, message=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------
## install.packages("here")
## install.packages("janitor")
## #install.packages("tidyverse")
## install.packages("dplyr")
## install.packages("tidyr")
## install.packages("stringr")
## install.packages("readr")
## install.packages("countrycode")
## install.packages("fuzzyjoin")
## install.packages("knitr")
## install.packages("flextable")
## install.packages("officer")
## install.packages("ggplot2")
## install.packages("extrafont")
## # font_import() # Only do this once


## ----load libraries, warning=FALSE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
library(here)
library(janitor)
#library(tidyverse)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(tibble)
library(countrycode)
library(fuzzyjoin)
library(knitr)
library(flextable)
library(officer)
library(ggplot2)
library(extrafont)
loadfonts(device = "win") #change based on your operating system


## ----run script for clean dataset, warning=FALSE, message=FALSE, eval = FALSE----------------------------------------------------------------------------------------------------------------------------------
## source(here::here("scripts/cleaning/unfccc-emissions", "unfccc-emissions-clean.R"))


## ----import dataset, warning=FALSE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
unfccc_emissions <- utils::read.csv(here::here("scripts/cleaning/unfccc-emissions", "unfccc-emissions-clean.csv"))


## ----check NAs CO2 non-annex, warning=FALSE, message=FALSE, caption = "Percent of missing values of CO~2~ over time (Non-Annex I)"-----------------------------------------------------------------------------
table_00 <- unfccc_emissions %>% 
  dplyr::ungroup() %>% 
  dplyr::filter(group == "Non-Annex I") %>% 
  dplyr::group_by(year) %>% 
  dplyr::summarise(missing = round(sum(is.na(co2))/length(co2) * 100, digits = 2)) %>%
  tibble::add_row(year = "2019", missing = NA)

table_01 <- cbind(table_00[table_00$year < 2000, ], table_00[table_00$year >= 2000 & table_00$year < 2010, ], table_00[table_00$year >= 2010 & table_00$year <= 2019, ]) %>%
  tibble::repair_names()

autonum <- officer::run_autonum(seq_id = "tab", bkm = "TC1", bkm_all = TRUE)

table_01 %>%
  flextable::flextable() %>%
  flextable::set_header_labels(year = "Year", missing = "Missing (%)", year1 = "Year", missing1 = "Missing (%)", year2 = "Year", missing2 = "Missing (%)") %>%
  flextable::theme_vanilla() %>%
  flextable::font(fontname = "Times New Roman", part = "all") %>%
  flextable::set_caption("Percent of missing values of CO~2~ over time (Non-Annex I)", autonum = autonum) %>%
  flextable::highlight(j = "missing", i = ~ missing < 50, color = "yellow") %>%
  flextable::highlight(j = "missing1", i = ~ missing1 < 50, color = "yellow") %>%
  flextable::highlight(j = "missing2", i = ~ missing2 < 50, color = "yellow") %>%
  flextable::highlight(j = "missing", i = ~ missing > 90, color = "lightcoral") %>%
  flextable::highlight(j = "missing1", i = ~ missing1 > 90, color = "lightcoral") %>%
  flextable::highlight(j = "missing2", i = ~ missing2 > 90, color = "lightcoral") %>%
  flextable::autofit()


## ----check NAs CO2 annex, warning=FALSE, message=FALSE, caption = "Percent of missing values of CO~2~ over time (Annex I)"-------------------------------------------------------------------------------------
table_00 <- unfccc_emissions %>% 
  dplyr::ungroup() %>% 
  dplyr::filter(group == "Annex I") %>% 
  dplyr::group_by(year) %>% 
  dplyr::summarise(missing = round(sum(is.na(co2))/length(co2) * 100, digits = 2)) %>%
  tibble::add_row(year = "2019", missing = NA)

table_01 <- cbind(table_00[table_00$year < 2000, ], table_00[table_00$year >= 2000 & table_00$year < 2010, ], table_00[table_00$year >= 2010 & table_00$year <= 2019, ]) %>%
  tibble::repair_names()


table_01 %>%
  flextable::flextable() %>%
  flextable::set_header_labels(year = "Year", missing = "Missing (%)", year1 = "Year", missing1 = "Missing (%)", year2 = "Year", missing2 = "Missing (%)") %>%
  flextable::font(fontname = "Times New Roman", part = "all") %>%
  flextable::set_caption("Percent of missing values of CO~2~ over time (Annex I)", autonum = autonum) %>%
  flextable::theme_vanilla() %>%
  flextable::autofit()


## ----check NAs CO2 by region non-annex, warning=FALSE, message=FALSE-------------------------------------------------------------------------------------------------------------------------------------------
missing_non_annex_i_region <- unfccc_emissions %>% 
  dplyr::ungroup() %>% 
  dplyr::filter(group == "Non-Annex I") %>%
  dplyr::mutate(time_period = floor(as.numeric(as.character(year))/10)*10) %>%
  dplyr::group_by(time_period, region) %>%
  dplyr::summarise(missing = sum(is.na(co2))/length(co2) * 100) %>%
  dplyr::mutate(time_period = as.factor(time_period))
  
missing_non_annex_i_region$time_period <- dplyr::recode_factor(missing_non_annex_i_region$time_period, `1990` = "1990-1999", `2000` = "2000-2009", `2010` = "2010-2018")


## ----barplot by decade Non-Annex I, warning=FALSE, message=FALSE, caption = "Percent of missing values of CO~2~ by region (Non-Annex I)", fig.width = 8--------------------------------------------------------
missing_non_annex_i_region %>%
  ggplot2::ggplot(aes(x = time_period, y = missing, fill = str_wrap(region, 15))) +
  ggplot2::geom_bar(stat="identity", position=position_dodge(), color = "black") +
  ggplot2::theme_classic() +
  ggplot2::ylab("Missing Values (%)") +
  ggplot2::xlab("Years") +
  ggplot2::coord_flip() +
  ggplot2::scale_fill_brewer(palette = "Paired", name = "Regions") +
  ggplot2::geom_text(aes(label = round(missing, digits = 0)), position=position_dodge(width=0.9), hjust = -0.25, size = 4) +
  ggplot2::theme(text=element_text(family = "Arial", size = 11), 
                 axis.title.x = element_text(family = "Arial", size = 12), 
                 axis.title.y = element_text(family = "Arial", size = 12), 
                 legend.text=element_text(family = "Arial", size=11))

ggplot2::ggsave(here("images", "missing-non-annex-i-01.svg"), device="svg", dpi=300)  

rm(autonum, table_00, table_01, missing_non_annex_i_region, unfccc_emissions)


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------------------------------------------------
## knitr::purl("unfccc-emissions-analysis.Rmd", "unfccc-emissions-analysis.R")
## knitr::write_bib(.packages(), "packages.bib")

