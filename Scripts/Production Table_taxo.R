# ----------TABLE TAXONOMIQUE (ajout norme ITIS)----Longue à produire alors j'ai sauvegardé le résultat---jules--------
library(ritis)

Table_taxo <- read.csv("Taxonomie.csv")
#test de la fonction
terms(query=Table_taxo$species[5], "scientific")

# DÉBUT SCRIPT
TSN <- rep(NA, nrow(Table_taxo))

for (i in 1:402){
  
  TSN[i] <- terms(query=Table_taxo$species[i], "scientific")[1,5]
  print(i)
}
# ligne 146 et 214 n'ont pas marché
Table_taxo$TSN <- TSN
Table_taxo$TSN <- as.numeric(unlist(Table_taxo$TSN))
#write.csv(Table_taxo, file = "Table_taxo.csv")

#---------------FIN--------------------#