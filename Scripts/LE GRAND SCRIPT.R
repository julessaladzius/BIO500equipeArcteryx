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

#------SUPPRESSION DES DONNÉES SUSPECTES--------#
# voir fichier read.me pour les détails
a_exclure <- c(1172, 2463, 1625, 1257, 1260, 1968, 688, 205, 1246, 1245,
               211, 973, 969, 970, 971, 972, 1931, 1807, 1640, 524,
               1170, 2345, 1974, 1707)
donnees <- donnees %>%
  filter(!cle_pop %in% a_exclure)
#-----------------------------------------------#

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


head(abondance)


#--------TABLEAU SECONDAIRE SOURCE--------

source <- subset(donnees,select=c(cle_source,original_source,title,publisher,owner,license),subset=!duplicated(cbind(cle_source,original_source,title,publisher,owner,license)))

head(source)


#--------TABLEAU SECONDAIRE GEOM--------

geom <- subset(donnees,select=c(cle_geom,latitude,longitude),subset=!duplicated(cbind(cle_geom,latitude,longitude)))

head(geom)


#--------TABLEAU SECONDAIRE TAXO--------
#La table "Table_taxo" à été produite à partir de la table "taxonomie" présente dans les données fournies, avec le script "Production Table_taxo.R"

taxo <- read.csv("data/Nettoyé/Table_taxo.csv")
#Supprimer les quelques lignes avec des informations différentes pour un même TSN
taxo <- taxo %>%
  group_by(TSN) %>%
  slice(1) %>%  # garde la première ligne par TSN
  ungroup()
head(taxo)

#--------INTÉGRER TAXO À DONNEES--------

donnees <- merge(taxo,donnees,by="observed_scientific_name")


#--------TABLEAU PRIMAIRE POPULATION--------

population <- subset(donnees, select=c(TSN,unit,cle_pop,cle_source,cle_geom),subset=!duplicated(cbind(TSN,unit,cle_pop,cle_source,cle_geom)))

head(population)



#--#--#--#--#--#--#--#--#--#--#--#--#--#

##- ##- ##- I N J E C T I O N ##- ##- ##

#--#--#--#--#--#--#--#--#--#--#--#--#--#

#taxo %>%
  #group_by(TSN) %>%
  #filter(n() > 1)
#names(taxo)


##----CRÉATION DES TABLES EN SQL----##

library(RSQLite)

library(dplyr)




#Connexion au serveur

#connexion <- dbConnect(SQLite(),dbname="database/donneessql")

# Contrainte de clé étrangère
dbExecute(connexion, "PRAGMA foreign_keys = ON;")



#Création de la table "abondance"
creer_abondance <- 
  "CREATE TABLE abondance(
years	  INTEGER,
val		  REAL, 
cle_pop	INTEGER,
PRIMARY KEY(cle_pop, years)
);"
dbSendQuery(connexion,creer_abondance) 

#****modifier la colonne "values" par "val", sinon erreur parce que c'est une commande SQL
colnames(abondance)[2] <- "val"


# Création de la table "source"
creer_source <- 
  "CREATE TABLE source(
cle_source		  INTEGER,
original_source VARCHAR(100),
title			      VARCHAR(500),
publisher		    VARCHAR(100),
owner			      VARCHAR(100),
license			VARCHAR(100),
PRIMARY KEY(cle_source,original_source,title,publisher,owner,license)
);"
dbSendQuery(connexion,creer_source)


# Création de la table "geom"
creer_geom <- 
  "CREATE TABLE geom(
cle_geom	INTEGER,
latitude	REAL,
longitude 	REAL,
PRIMARY KEY(cle_geom,latitude,longitude)
);"
dbSendQuery(connexion,creer_geom)


# Création de la table "taxo"
creer_taxo <- 
  "CREATE TABLE taxo(
observed_scientific_name VARCHAR(100),
valid_scientific_names	 VARCHAR(100),
rank					 VARCHAR(100),
vernacular_fr			 VARCHAR(100),
kingdom					 VARCHAR(100),
phylum 					 VARCHAR(100),
class 					 VARCHAR(100),
ord 					 VARCHAR(100),
family					 VARCHAR(100),
genus 					 VARCHAR(100),
species				     VARCHAR(100),
TSN 					 INTEGER,
PRIMARY KEY(TSN)
);"
dbSendQuery(connexion,creer_taxo)


# Création de la table finale "population"
creer_population <- "
CREATE TABLE population (
  cle_pop INTEGER,
  TSN INTEGER,
  unit VARCHAR(50),
  cle_source INTEGER,
  cle_geom INTEGER,
  PRIMARY KEY(cle_pop),
  FOREIGN KEY (TSN) REFERENCES taxo(TSN),
  FOREIGN KEY (cle_geom) REFERENCES geom(cle_geom),
  FOREIGN KEY (cle_source) REFERENCES source(cle_source)
);"
dbSendQuery(connexion, creer_population)
colnames(taxo)[9] <- "ord" #modification colonne "order" par "ord" sinon erreur
taxo <- subset(taxo,select=-c(X)) # enlève colonne "X" 

# Création de la table "population"

creer_population <- 
  "CREATE TABLE population(
TSN			INTEGER,
unit		VARCHAR(100),
cle_pop		INTEGER,
cle_source	INTEGER,
cle_geom 	INTEGER,
PRIMARY KEY (cle_pop,cle_geom),
FOREIGN KEY (TSN) REFERENCES taxo(TSN),
FOREIGN KEY (cle_pop) REFERENCES abondance(cle_pop),
FOREIGN KEY (cle_source) REFERENCES source(cle_source),
FOREIGN KEY (cle_geom) REFERENCES geom(cle_geom) 
);"
dbSendQuery(connexion,creer_population)

dbDisconnect(connexion)

##---- INJECTION DES DONNÉES ----##

#abondance
dbWriteTable(connexion,append=T,name="abondance",value=abondance_check,row.names=F)

#source
dbWriteTable(connexion,append=T,name="source",value=source,row.names=F)

#geom
dbWriteTable(connexion,append=T,name="geom",value=geom,row.names=F)

#taxo
dbWriteTable(connexion,append=T,name="taxo",value=taxo,row.names=F)

#population
dbWriteTable(connexion,append=T,name="population",value=population,row.names=F)

