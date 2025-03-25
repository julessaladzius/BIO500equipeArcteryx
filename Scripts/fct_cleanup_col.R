#Fonction de nettoyage des noms de colonnes#

library("tidyverse") #nécessite l'installation du package 'tidyverse'

cleanup_col <- function(dataframe){	
							
	data.removed <- dataframe[,!(names(dataframe)%in%c("license","lisense","geom","geometry","creator","intellectual_rights"))] #enlève les colonnes doublées à cause d'erreurs dans les noms et les colonnes inutiles (creator et intellectual_rights n'ont que des NA)
	fixed.dataframe=NULL #crée un nouveau dataframe pour insérer les colonnes "réparées"
	license <- coalesce(dataframe$license,dataframe$lisense) #la fonction coalesce permet de combiner les colonnes dédoublées en une seule en éliminant les NA
	geom <- coalesce(dataframe$geom,dataframe$geometry)
	fixed.dataframe <- cbind(data.removed,license,geom) #ajoute les colonnes réparées au reste du tableau
}





















