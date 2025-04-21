
modif_cleanup<-function(donnees){
  #Ajustement données préalables
  donnees$X <-  NULL
  donnees <- unique(donnees)
  #Fonction de nettoyage des colonnes (ex: colonne license)
  donnees <- cleanup_col(donnees)
  #Fonction de validation des données géographiques (met en longitude, latitude)
  donnees <- cleanup_geom(donnees)
}

#Création clés de base 
Keys_mold<-function(donnees){
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
}

  #Filtrer populations suspectes de donnees

  filtre_SUS_pop<-function(donnees){
  #------SUPPRESSION DES DONNÉES SUSPECTES--------#
  # voir fichier read.me pour les détails
  a_exclure <- c(1172, 2463, 1625, 1257, 1260, 1968, 688, 205, 1246, 1245,
                 211, 973, 969, 970, 971, 972, 1931, 1807, 1640, 524,
                 1170, 2345, 1974, 1707, 102, 1800)
  donnees <- donnees %>%
    filter(!cle_pop %in% a_exclure)

  }
  
  corne_abondance<-function(Donnees_filtrees){
    #nouveau dataframe avec années, valeurs et clé pop
    abondance <- subset(Donnees_filtrees, select=c(years,values,cle_pop))
    
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
    abondance <- cleanup_years(abondance)
    
  }
  
  fct_source_sec<-function(Donnees_filtrees){
    source <- subset(Donnees_filtrees,select=c(cle_source,original_source,title,publisher,owner,license),subset=!duplicated(cbind(cle_source,original_source,title,publisher,owner,license)))
  }
  
  fct_geom_sec<-function(Donnees_filtrees){
    geom <- subset(Donnees_filtrees,select=c(cle_geom,latitude,longitude),subset=!duplicated(cbind(cle_geom,latitude,longitude)))  
  }
  
  #--------TABLEAU SECONDAIRE TAXO--------
  #La table "Table_taxo" à été produite à partir de la table "taxonomie" présente dans les données fournies, avec le script "Production Table_taxo.R"
  
  fct_taxo_sec<-function(Tab_taxo){
    
    taxo <- read.csv(Tab_taxo)
    #Supprimer les quelques lignes avec des informations différentes pour un même TSN
    taxo <- taxo %>%
      group_by(TSN) %>%
      slice(1) %>%  # garde la première ligne par TSN
      ungroup()  
  }
  
  #--------INTÉGRER TAXO À DONNEES--------
  
  fct_integration <- function(Donnees_filtrees,Tab_taxo){
  donnees <- merge(Donnees_filtrees,Tab_taxo,by="observed_scientific_name")
  }
  
  #--------TABLEAU PRIMAIRE POPULATION--------
  
  fct_population_prim <- function(Donnees_avec_taxo){
    population <- subset(Donnees_avec_taxo, select=c(TSN,unit,cle_pop,cle_source,cle_geom),subset=!duplicated(cbind(TSN,unit,cle_pop,cle_source,cle_geom)))
  }
  
  
  #Création de la table "abondance" et injection des donnees
  
  fct_abondance_sql <- function(db_path, df) {
    conn <- dbConnect(RSQLite::SQLite(), db_path)
    on.exit(dbDisconnect(conn))
    if ("values" %in% colnames(df)) {
      colnames(df)[colnames(df) == "values"] <- "val"
    }
    creer_abondance <- 
      "CREATE TABLE abondance(
years	  INTEGER,
val		  REAL, 
cle_pop	INTEGER,
PRIMARY KEY(cle_pop, years)
);"
    dbSendQuery(conn,creer_abondance) 
  
    dbWriteTable(conn,append=T,name="abondance",value=df,row.names=F,overwrite = TRUE)
  }
  
  # Création de la table "source"
  
  fct_source_sql <- function(db_path, df){
    conn <- dbConnect(RSQLite::SQLite(), db_path)
    on.exit(dbDisconnect(conn))
  creer_source <- 
    "CREATE TABLE source(
cle_source		  INTEGER,
original_source VARCHAR(100),
title			      VARCHAR(500),
publisher		    VARCHAR(100),
owner			      VARCHAR(100),
license			VARCHAR(100),
PRIMARY KEY(cle_source)
);"
  dbSendQuery(conn,creer_source) 
  dbWriteTable(conn,append=T,name="source",value=df,row.names=F,overwrite = TRUE)
  }
  
  # Création de la table "geom"
  
  fct_geom_sql <- function(db_path, df){
    conn <- dbConnect(RSQLite::SQLite(), db_path)
    on.exit(dbDisconnect(conn))
  creer_geom <- 
    "CREATE TABLE geom(
cle_geom	INTEGER,
latitude	REAL,
longitude 	REAL,
PRIMARY KEY(cle_geom)
);"
  dbSendQuery(conn,creer_geom)
  
  dbWriteTable(conn,append=T,name="geom",value=df,row.names=F,overwrite = TRUE) 
  }
  
  # Création de la table "taxo"
  
  fct_taxo_sql <- function(db_path, df){
    conn <- dbConnect(RSQLite::SQLite(), db_path)
    on.exit(dbDisconnect(conn))
    if ("X" %in% colnames(df)) {
      df <- subset(df, select = -c(X))
    }
    if ("order" %in% colnames(df)) {
      colnames(df)[colnames(df) == "order"] <- "ord"
    }
    creer_taxo <- 
    "CREATE TABLE taxo(
observed_scientific_name VARCHAR(100),
valid_scientific_name	 VARCHAR(100),
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
  dbSendQuery(conn,creer_taxo) 
  dbWriteTable(conn,append=T,name="taxo",value=df,row.names=F,overwrite = TRUE) 
  }
  
  # Création de la table finale "population"
  
  fct_population_sql <- function(db_path, df){
    conn <- dbConnect(RSQLite::SQLite(), db_path)
    on.exit(dbDisconnect(conn))
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
  dbSendQuery(conn, creer_population)
  dbWriteTable(conn,append=T,name="population",value=df,row.names=F,overwrite = TRUE) 
  }
  