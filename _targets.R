setwd("/Users/francoismartin/Desktop/PROJETBIO500/BIO500equipeArcteryx")
library("targets")

tar_option_set(
  packages = c("dplyr", "readr","ggplot2","tidyverse")
)

list(
  tar_target(
    donnees,
    read.csv("data/raw/donnees.csv")
  )
)
