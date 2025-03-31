library(dplyr)
library(readr)
library(tidyverse)

#--------LOAD DONNEES----------

source("Scripts/fct_load_data.r")
# Option 1: Utiliser la fonction pour fusionner les données
  #donnees <- load_data("/Users/francoismartin/Desktop/BAC_Écologie/H25/BIO500/Projet_session/series_temporelles/donnees") 
# Option 2: read.csv() pour aller chercher le fichier donnees.csv, les données pré-fusionnées. 
donnees <- read.csv("data/raw/donnees.csv")
donnees$X <-  NULL
donnees <- unique(donnees)

#---------NETTOYAGE ET VALIDATION DES DONNÉES-----------------

#Fonction de nettoyage des colonnes (ex: colonne license)

source("Scripts/fct_cleanup_col.R")
donnees <- cleanup_col(donnees)

#Fonction de validation des données géographiques (met en longitude, latitude)

source("Scripts/fct_cleanup_geom.R")
donnees <- cleanup_geom(donnees)

summary(donnees)

#--------TABLEAU DONNEES--------

#Création de la clé population (ID unique pour chaque population/ligne) Remarqué qu'il y avait beaucoup de lignes similaires (donnees en double)

donnees <- data.frame(donnees %>%
group_by(observed_scientific_name,unit,latitude,longitude) %>%
mutate(cle_pop=cur_group_id()))

#Création de la clé source (ID unique pour chaque source)

donnees <- data.frame(donnees %>%
group_by(original_source,title,publisher,owner,license) %>%
mutate(cle_source=cur_group_id()))

#Création de la clé geom (ID unique pour chaque point géographique)

donnees <- data.frame(donnees%>%
group_by(latitude,longitude) %>%
mutate(cle_geom=cur_group_id()))

#--------TABLEAU SECONDAIRE ABONDANCES--------

#nouveau dataframe avec années, valeurs et clé pop
abondance <- subset(donnees, select=c(years,values,cle_pop))

#fonction pour conversion en valeurs numerique
convertion_array_list <- function(x) {
  x <- gsub("\\[|\\]", "", x)  
  as.numeric(unlist(strsplit(x, ","))) 
}

abondance$values <- lapply(abondance$values, convertion_array_list)
abondance$years <- lapply(abondance$years, convertion_array_list)
abondance <- data.frame(abondance%>%
unnest(c(years,values))) #déplier le dataframe et créer une ligne pour chaque valeur

#Fonction de validation des années

source("Scripts/fct_cleanup_years.r")
abondance <- cleanup_years(abondance)

summary(abondance)
head(abondance)

#--------TABLEAU SECONDAIRE SOURCE--------

source <- subset(donnees,select=c(cle_source,original_source,title,publisher,owner,license),subset=!duplicated(cbind(cle_source,original_source,title,publisher,owner,license)))

head(source)
summary(source)

#--------TABLEAU SECONDAIRE GEOM--------

geom <- subset(donnees,select=c(cle_geom,latitude,longitude),subset=!duplicated(cbind(cle_geom,latitude,longitude)))

head(geom)
summary(geom)

#--------TABLEAU SECONDAIRE TAXO--------
#La table "Table_taxo" à été produite à partir de la table "taxonomie" présente dans les données fournies, avec le script "Production Table_taxo.R"

taxo <- read.csv("data/Nettoyé/Table_taxo.csv")

head(taxo)

#--------INTÉGRER TAXO À DONNEES--------

donnees <- merge(taxo,donnees,by="observed_scientific_name")


#--------TABLEAU PRIMAIRE POPULATION--------

population <- subset(donnees, select=c(TSN,unit,cle_pop,cle_source,cle_geom),subset=!duplicated(cbind(TSN,unit,cle_pop,cle_source,cle_geom)))

head(population)

<<<<<<< HEAD

#--#--#--#--#--#--#--#--#--#--#--#--#--#

##- ##- ##- I N J E C T I O N ##- ##- ##

#--#--#--#--#--#--#--#--#--#--#--#--#--#

library(DBI)
library(RSQLite)

# je sais plus trop, il faut faire db.connect et tout, j'ai ajouté dans get.ignore le fichier sql alors on pourra refaire le code chq fois.
=======
##----CRÉATION DES TABLES EN SQL----##

library(RSQLite)

#Connexion au serveur

connexion <- dbConnect(SQLite(),db.name="donnees")

#Création de la table "abondance"

creer_abondance <- 
  "CREATE TABLE abondance(
years	INTEGER,
val		REAL, 
cle_pop	INTEGER,
PRIMARY KEY(cle_pop)
);"
dbSendQuery(connexion,creer_abondance) #****modifier la colonne "values" par "val", sinon erreur parce que c'est une commande SQL

# Création de la table "source"

creer_source <- 
  "CREATE TABLE source(
cle_source		INTEGER,
original_source VARCHAR(100),
title			VARCHAR(500),
publisher		VARCHAR(100),
owner			VARCHAR(100),
license			VARCHAR(100),
PRIMARY KEY(cle_source)
);"
dbSendQuery(connexion,creer_source)

# Création de la table "geom"

creer_geom <- 
  "CREATE TABLE geom(
cle_geom	INTEGER,
latitude	REAL,
longitude 	REAL,
PRIMARY KEY(cle_geom)
);"
dbSendQuery(connexion,creer_geom)




>>>>>>> 51ccf7eaf5f9ea9542e3a8ab838122a1ee4959bd



