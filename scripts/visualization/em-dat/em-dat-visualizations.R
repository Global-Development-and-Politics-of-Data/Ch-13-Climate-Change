## ----setup, include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      knitr.duplicate.label = "allow",
                      tidy.opts = list(width.cutoff = 40), 
                      tidy = TRUE,
                      strip.white = FALSE)



## ----libraries, message=FALSE, warning=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(here)
library(readxl)
library(janitor)
library(dplyr)
library(stringr)
library(ggplot2)
library(hrbrthemes)
library(viridis)
library(scales)
library(extrafont)
loadfonts(device = "win")


## ----import dataset, warning=FALSE, message=TRUE----------------------------------------------------------------------------------------------------------------------------------------------------------------
em_dat <- utils::read.csv(here::here("scripts/cleaning/em-dat", "em-dat-clean.csv"), stringsAsFactors = TRUE)


## ----plot disasters over time, warning=FALSE, message=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------------
em_dat %>% 
  dplyr::select(-country, -iso) %>%
  dplyr::filter(as.numeric(year) >= 1990) %>% 
  dplyr::group_by(year, disaster_type) %>% 
  dplyr::summarise_all(funs(sum), na.rm = TRUE) %>%
  ggplot2::ggplot(aes(x = year, y = total_affected, fill = str_wrap(disaster_type, 15), group = disaster_type)) +
  ggplot2::geom_area(alpha=0.6 , size=.1, colour="white", position = "identity") +
  viridis::scale_fill_viridis(name = "Disaster type", discrete = TRUE) +
  hrbrthemes::theme_ipsum(base_size = 11) + 
  ggplot2::scale_y_continuous(labels = scales::unit_format(unit = "M", scale = 1e-6)) +
  ggplot2::ylab("Number of people affected") + 
  ggplot2::scale_x_discrete(name ="Year", breaks = seq(1990,2021,5)) +
  ggplot2::theme(text = element_text(family = "Arial", size = 11), 
                 axis.title.x = element_text(family = "Arial", size = 12), 
                 axis.title.y = element_text(family = "Arial", size = 12), 
                 legend.text = element_text(family = "Arial", size=10))

ggplot2::ggsave(here("images", "vulnerability-01.svg"), device="svg", dpi=300)

rm(em_dat)


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE--------------------------------------------------------------------------------------------------------------------------------------------
## knitr::purl("em-dat-visualizations.Rmd", "em-dat-visualizations.R")
## knitr::write_bib(.packages(), "packages.bib")

