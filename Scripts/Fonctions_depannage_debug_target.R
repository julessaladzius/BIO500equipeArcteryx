Nullify<-function(x){
x<-NULL  
}

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
  