


#Exclut ttestudines et reptilia > connaissances personelles faible en la matière donc exclusion 
##Selection dans catégorie Terrestre des classes avec cycle vital n'impliquant pas typiquement étape de vie aquatique à un certain stade parmi classe de banque de données;
#soit Aves, Mammalia et squamata 

#Selection dans catégorie aqua des classes avec cycle vital impliquant étape de vie aquatique à un certain stade parmi classe de banque de données;
#soit chondrostei,Elasmobranchii,Teleostei,Amphibia,Holostei,,Chondrichthyes,,Myxini et sans squamata ou Testudines( ici terrestre surtout) 
#Exclut Reptilia, Squamata,Mammalia, Aves et Testudines


InstantI<- dbGetQuery(connexion,Filtre_Aqua)


Filtre_Aqua <- "
WITH class_TSN AS (
  SELECT TSN, class
  FROM taxo
  WHERE class LIKE '%Petromyzonti%'
     OR class LIKE '%Myxini%'
     OR class LIKE '%Elasmobranchii%'
     OR class LIKE '%Chondrichthyes%'
     OR class LIKE '%Chondrostei%'
     OR class LIKE '%Holostei%'
     OR class LIKE '%Amphibia%'
)
SELECT 
  a.cle_pop,
  a.years,
  a.val,
  p.unit,
  t.class
FROM class_TSN t
JOIN population p ON t.TSN = p.TSN
JOIN abondance a ON p.cle_pop = a.cle_pop                                          ;
"

Data_aqua <- dbGetQuery(connexion, Filtre_Aqua)
View(Data_aqua)


#Section 2: Calcul de variation
#Boucle de calcul de variation de des population sur intervalle de temps 

#longueur boucle
a<-sort(unique(Data_aqua$cle_pop))

#Création vecteur vide pour stocker variation
percent_pop_var_aqua<-c()

#création objet boucle

i=1
for (i in 1:length(a)) {
  Intervalle_variant<-subset(Data_aqua,cle_pop==a[i],)
  
  Rmax<-which.max(Intervalle_variant$years)
  Val_F<-Intervalle_variant$val[Rmax]
  
  Rmin<-which.min(Intervalle_variant$years)
  Val_I<-Intervalle_variant$val[Rmin]
  
  if(Val_I!=0) {
    y<-((((Val_F-Val_I)/Val_I)
         *100)/length(Intervalle_variant))
    percent_pop_var_aqua<-c(percent_pop_var_aqua,y)
  }
  i=i+1
}

#Section pour voir données: Retirer # pourrun ensuite
#percent_var_<-data.frame(percent_pop_var_aqua)
#View(percent_var_)

#Section 3: Histogramme

Histoaqua<-hist(percent_pop_var_aqua,main = ' %variation pour population des classes animales aquatiques de 1985 à 1990', 
     xlab = 'Poucentage de variation',ylab = 'Nombre population aquatique',
     breaks = 50,freq = TRUE,xlim = c(-100, 1000))
Constante_aqua<-mean(percent_pop_var_aqua)
abline(v= Constante_aqua,col='blue' , lwd=2)


#Graphique terrestre
##Selcetion dans catégorie Terrestre des classes avec cycle vital n'impliquant pas typiquement étape de vie aquatique à un certain stade parmi classe de banque de données;
#soit Aves, Mammalia et squamata 

Filtre_TER <- 
"
WITH class_TSN_TER AS (
  SELECT TSN, class
  FROM taxo
  WHERE class LIKE '%Mammalia%'
     OR class LIKE '%Aves%'
)
SELECT 
  a.cle_pop,
  a.years,
  a.val,
  p.unit,
  t.class
FROM class_TSN_TER t
JOIN population p ON t.TSN = p.TSN
JOIN abondance a ON p.cle_pop = a.cle_pop;
"

Data_TER <- dbGetQuery(connexion, Filtre_TER)
View(Data_TER)

#Section 4: Calcul de variation TERrestre
#Boucle de calcul de variation de des population sur intervalle de temps 

#longueur boucle& et vecteur pour sélection par cle pop avec subset
b<-sort(unique(Data_TER$cle_pop))

#Création vecteur vide pour stocker variation
percent_pop_var_TER<-c()

#création objet boucle

i=1
for (i in 1:length(b)) {
Intervalle_variant<-subset(Data_TER,cle_pop==b[i],)

Rmax<-which.max(Intervalle_variant$years)
Val_F<-Intervalle_variant$val[Rmax]

Rmin<-which.min(Intervalle_variant$years)
Val_I<-Intervalle_variant$val[Rmin]

if(Val_I!=0) {
y<-((((Val_F-Val_I)/Val_I)
     *100)/length(Intervalle_variant))
percent_pop_var_TER<-c(percent_pop_var_TER,y)
}
i=i+1
}

View(percent_pop_var_TER)
percent_var_<-data.frame(percent_pop_var_TER)



#Section 3: Histogramme

Histo_Terrestre<-hist(percent_pop_var_TER,main = ' %variation abondance par an de populations des classes Aves et Mammalia',
     xlab = 'variation moyenne par an',ylab = 'Nombre population Terrestre',
     breaks = 50,freq = TRUE,xlim = c(-250, 600),ylim = c(0,175))

Constante_TER_pourcent<-mean(percent_pop_var_TER)
abline(v= Constante_TER_pourcent,col='brown' , lwd=2)


