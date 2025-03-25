####Fonction de vérification de la validité des données géographiques####

library("tidyverse") #nécessite l'installation du package 'tidyverse'

# Description de la fonction
# 1) Séparation des coordonnées (latitude et longitude)
# 2) Conversion des coordonnées en valeurs numériques
# 3) Vérification et correction de la latitude
# 4) Vérification et correction de la longitude
# 5) Retour du dataframe nettoyé

cleanup_geom <- function(dataframe){
	fixed.dataframe=NULL
	fixed.dataframe <- tidyr::extract(dataframe,geom,c("latitude","longitude"),"\\(\\((.*)\\s(.*)\\)\\)") #sépare la latitude et la longitude en deux colonnes distinctes
	fixed.dataframe[,c("latitude","longitude")] <- sapply(fixed.dataframe[,c("latitude","longitude")],as.numeric) #converti en valeurs numériques
	verif.latitude <- function(x,max=90,min=-90){
		replace(x,x>max|x<min,NA)
	}
	fixed.dataframe[,"latitude"] <- verif.latitude(fixed.dataframe[,"latitude"]) #fonction qui vérifie si les valeurs de latitude sont valides (+-90), sinon remplace par un NA
	verif.longitude <- function(x,max=180,min=-180){
		replace(x,x>max|x<min,NA)
	}
	fixed.dataframe[,"longitude"] <- verif.longitude(fixed.dataframe[,"longitude"]) #fonction qui vérifie si les valeurs de longitude sont valides (+-180), sinon remplace par un NA
	fixed.dataframe
}
