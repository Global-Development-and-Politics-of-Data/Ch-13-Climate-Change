## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE,
                      purl = TRUE,
                      out.extra = '',
                      tab.cap.pre = "Table ", tab.cap.sep = ": ",
                      knitr.duplicate.label = "allow",
                      tidy.opts = list(width.cutoff = 40), 
                      tidy = TRUE,
                      strip.white = FALSE)



## ----eval=FALSE, warning=FALSE, message=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------
## install.packages("here")
## install.packages("janitor")
## #install.packages("tidyverse")
## install.packages("dplyr")
## install.packages("stringr")
## install.packages("ggplot2")
## install.packages("treemapify")
## install.packages("knitr")
## install.packages("extrafont")
## # font_import() # Only do this once


## ----load libraries, warning=FALSE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
library(here)
library(janitor)
#library(tidyverse)
library(dplyr)
library(stringr)
library(ggplot2)
library(scales)
library(treemapify)
library(knitr)
library(extrafont)
loadfonts(device = "win")


## ----import dataset, warning=FALSE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------
unfccc_emissions <- utils::read.csv(here("scripts/cleaning/unfccc-emissions", "unfccc-emissions-clean.csv"), stringsAsFactors = TRUE)


## ----ghg 2018 by region, warning=FALSE, message=TRUE, caption = "Annex I GHG emissions without LULUCF (2018)"--------------------------------------------------------------------------------------------------
unfccc_emissions %>%
  dplyr::filter(year == "2018", group == "Annex I", !(country %in% c("European Union (Convention)", "European Union (KP)"))) %>%
  dplyr::group_by(region, type) %>%
  dplyr::summarise(total = sum(ghg)) %>%
  ggplot2::ggplot(aes(x = as.factor(region), y = total, fill = stringr::str_wrap(as.factor(type), 12))) +
  ggplot2::scale_fill_brewer(palette = "Paired", name = "Type") +
  ggplot2::geom_bar(stat="identity", position=position_dodge(), width = 1) +
  ggplot2::geom_text(aes(label = round(total/1000000, digits = 2)), vjust = -0.2, position=position_dodge(width=0.9)) +
  ggplot2::theme_minimal() +
  ggplot2::xlab("Regions") +
  ggplot2::ylab("GHG (Gt)") +
  ggplot2::scale_y_continuous(labels = scales::unit_format(unit = "", scale = 1e-6)) +
  ggplot2::scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 15)) +
#  theme(legend.position = "none") +
  ggplot2::theme(text=element_text(family = "Arial", size = 11), 
                 axis.title.x = element_text(family = "Arial", size = 12), 
                 axis.title.y = element_text(family = "Arial", size = 12), 
                 legend.text=element_text(family = "Arial", size=10))


## ----ghg 2018 by region treemap, warning=FALSE, message=TRUE, caption = "Annex I GHG emissions without LULUCF (2018)"------------------------------------------------------------------------------------------
unfccc_emissions %>%
  dplyr::filter(year == "2018", group == "Annex I", type == "Total GHG emissions without LULUCF", !(country %in% c("European Union (Convention)", "European Union (KP)"))) %>%
  dplyr::mutate(percent = round(ghg/sum(ghg) * 100, digits = 2)) %>%
  dplyr::group_by(region, type) %>%
  ggplot2::ggplot(aes(area = ghg, fill = region, subgroup = region, label = paste(country, paste(round(ghg/1000000, digits = 2), " Gt (", percent, "%)", sep = ""), sep = "\n"))) +
  ggplot2::scale_fill_brewer(palette = "Paired") +
  treemapify::geom_treemap() +
  treemapify::geom_treemap_subgroup_border(size = 0) +
  treemapify::geom_treemap_subgroup_text(grow = FALSE, place = "bottomleft", size = 14, color = "grey20", reflow = TRUE, family = "Arial") +
  ggplot2::theme_void() + 
  treemapify::geom_treemap_text(colour = "white", place = "topleft", reflow = T, size = 8, family = "Arial") +
  ggplot2::theme(legend.position = "none")

ggplot2::ggsave(here("images", "annex-i-ghg-2018.svg"), device="svg", dpi=300)


## ----ghg cumulative by region treemap, warning=FALSE, message=TRUE, caption = "Annex I cumulative GHG emissions without LULUCF (1990-2018)"--------------------------------------------------------------------
unfccc_emissions %>%
  dplyr::filter(year != "base_year", group == "Annex I", type == "Total GHG emissions without LULUCF", !(country %in% c("European Union (Convention)", "European Union (KP)"))) %>%
  dplyr::group_by(iso, country, region) %>%
  dplyr::summarise_if(is.numeric, sum, na.rm = TRUE) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(percent = round(ghg/sum(ghg) * 100, digits = 2)) %>%
  dplyr::group_by(country, region) %>%
  ggplot2::ggplot(aes(area = ghg, fill = region, subgroup = region, label = paste(country, paste(round(ghg/1000000, digits = 2), " Gt (", percent, "%)", sep = ""), sep = "\n"))) +
  ggplot2::scale_fill_brewer(palette = "Paired") +
  treemapify::geom_treemap() +
  treemapify::geom_treemap_subgroup_border(size = 0) +
  treemapify::geom_treemap_subgroup_text(grow = FALSE, place = "bottomleft", size = 14, color = "grey20", reflow = TRUE, family = "Arial") +
  ggplot2::theme_void() + 
  treemapify::geom_treemap_text(colour = "white", place = "topleft", reflow = T, size = 8, family = "Arial") +
  ggplot2::theme(legend.position = "none")

ggplot2::ggsave(here("images", "annex-i-ghg-cumulative.svg"), device="svg", dpi=300)
rm(unfccc_emissions)


## ----export as an R script, eval=FALSE, message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------------------------------------------------
## knitr::purl("unfccc-emissions-visualization.Rmd", "unfccc-emissions-visualization.R")
## knitr::write_bib(.packages(), "packages.bib")

