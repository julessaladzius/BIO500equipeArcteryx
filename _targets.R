#### Répertoire - à modifier par l'utilisateur ####

setwd("/Users/francoismartin/Desktop/PROJETBIO500/BIO500equipeArcteryx")

#### Loading des packages et scripts nécessaires ####

library("targets")
library("tarchetypes")

source("Scripts/LE GRAND SCRIPT.R")

tar_option_set(
  packages = c("dplyr", "readr","ggplot2","tidyverse")
)

list(
  tar_target(
    donnees,
    read.csv("data/raw/donnees.csv")
    ),
    tarchetypes::tar_render(
      rapport_html,
      "Rapports/Rapport1_Pygargues.Rmd",
      output_format = "html_document",
      params = list(donnees = donnees)
    )
)




