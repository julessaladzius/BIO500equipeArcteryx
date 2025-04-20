
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
  #-----------------------------------------------#
  }
  
  corne_abondance<-function(Donnees_filtrees){
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
    abondance <- cleanup_years(abondance)
    
  }
  
  fct_source_sec<-function(Donnees_filtrees){
    source <- subset(donnees,select=c(cle_source,original_source,title,publisher,owner,license),subset=!duplicated(cbind(cle_source,original_source,title,publisher,owner,license)))
  }
  
  fct_geom_sec<-function(Donnees_filtrees){
    geom <- subset(donnees,select=c(cle_geom,latitude,longitude),subset=!duplicated(cbind(cle_geom,latitude,longitude)))  
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
  
  donnees <- merge(taxo,donnees,by="observed_scientific_name")
  }
  
  #--------TABLEAU PRIMAIRE POPULATION--------
  
  fct_population_prim <- function(Donnees_filtrees){
    population <- subset(donnees, select=c(TSN,unit,cle_pop,cle_source,cle_geom),subset=!duplicated(cbind(TSN,unit,cle_pop,cle_source,cle_geom)))
  }
  
  

  
  