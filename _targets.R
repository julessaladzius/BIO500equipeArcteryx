#### Répertoire - à modifier par l'utilisateur ####


library("targets")
library("tarchetypes")
library(dplyr)
library(readr)
library(tidyverse)
library(RSQLite)

#tar_option_set(
#packages = c("") # Packages that your targets need for their tasks.
# format = "qs", # Optionally set the default storage format. qs is fast.


#sources scripts
tar_source("Scripts/fct_load_data.R")
tar_source('Scripts/fct_cleanup_geom.R')
tar_source('Scripts/fct_cleanup_col.R')
tar_source('Scripts/fct_cleanup_years.R')
tar_source('Scripts/fct_load_data.R')

#tar_source('Scripts/Production Table_taxo.R') # Manque Taxonomie.csv, donc ajuster working directory ou changer l'emplacement du csv?
#tar_source('Scripts/Hist_aqua&Hist_TER.R')
tar_source('Scripts/Fonctions_depannage_debug_target.R')
#source("Scripts/LE GRAND SCRIPT.R")

tar_option_set(
  packages = c("dplyr", "readr","ggplot2","tidyverse","RSQLite")
)

#À ajouter après ajout table taxo sans passer par grand script à cause erreurs
    #tarchetypes::tar_render(
     # rapport_html,
      #"Rapports/Rapport1_Pygargues.Rmd",
      #output_format = "html_document",
      #params = list(donnees = donnees)
#),

list(
  tar_target(
    name = The_way,
    command = "data/raw/donnees.csv",
    format = "file"
    
  ),
  tar_target(
    name = donnees,
    command = read.csv(The_way) 
    
    
  ),
  tar_target(
    name = donnees_clean,
    command= modif_cleanup(donnees)
    
    
    
  ),
  tar_target(
    name = Keys,
    command= Keys_mold(donnees_clean)
    
  ),
  
  tar_target(
    name = donnees_pop_post_filter,
    command=filtre_SUS_pop(Keys) 
    
  ),
  tar_target(
    name = abondance_sec,
    command = corne_abondance(donnees_pop_post_filter)
      
    
  ),
  tar_target(
    name = source_sec,
    command= fct_source_sec(donnees_pop_post_filter)

),
  tar_target(
    name = geom_sec,
    command= fct_geom_sec(donnees_pop_post_filter)
      
  ),
  tar_target(
  name = taxo_path,
  command= "data/Nettoyé/Table_taxo.csv",
  format = "file"
  
  ),
  tar_target(
    name = taxo_read_setup,
    command= fct_taxo_sec(taxo_path)
    
  ),
  tar_target(
    name = donnees_pop_taxo,
    command = fct_integration(donnees_pop_post_filter,taxo_read_setup)
  ),
  tar_target(
    name = population_prim,
    command = fct_population_prim(donnees_pop_taxo)
  ),
  tar_target(
    name = donnees_sql_path,
    command = "database/donneessql",
    format = "file"
  ),
  tar_target(
    name = abondance_sql,
    command = fct_abondance_sql(donnees_sql_path,abondance_sec)
  ),
  tar_target(
    name = source_sql,
    command = fct_source_sql(donnees_sql_path,source_sec)
  ),
  tar_target(
    name = geom_sql,
    command = fct_geom_sql(donnees_sql_path,geom_sec)
  ),
  tar_target(
    name = taxo_sql,
    command = fct_taxo_sql(donnees_sql_path,taxo_read_setup)
  ),
  tar_target(
    name = population_sql,
    command = fct_population_sql(donnees_sql_path,population_prim)
  ),
  tarchetypes::tar_render(
  name = rapport_final,
  path = "Rapports/Rapport1_Pygargues.Rmd",
  params = list(db_path = donnees_sql_path)
)
)



