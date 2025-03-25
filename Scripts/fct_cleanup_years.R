####Fonction de véfification et nettoyage des années####

library("tidyverse")

cleanup_years <- function(dataframe){
	fixed.dataframe=dataframe #crée un nouveau dataframe
	verif.years <- function(x,max=2025){
		replace(x,x>max,NA) #fonction qui vérifie si les années sont "impossibles" et remplace par un NA dans ce cas
	}
	fixed.dataframe[,"years"] <- verif.years(dataframe[,"years"])
	fixed.dataframe <- na.omit(fixed.dataframe) #retire les rangées du dataframe pour lesquelles il y a un NA
	fixed.dataframe
}






