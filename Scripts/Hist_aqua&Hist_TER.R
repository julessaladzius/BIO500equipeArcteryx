


#Exclut ttestudines et reptilia > connaissances personelles faible en la matière donc exclusion 
##Selection dans catégorie Terrestre des classes avec cycle vital n'impliquant pas typiquement étape de vie aquatique à un certain stade parmi classe de banque de données;
#soit Aves, Mammalia et squamata 

#Selection dans catégorie aqua des classes avec cycle vital impliquant étape de vie aquatique à un certain stade parmi classe de banque de données;
#soit chondrostei,Elasmobranchii,Teleostei,Amphibia,Holostei,,Chondrichthyes,,Myxini et sans squamata ou Testudines( ici terrestre surtout) 
#Exclut Reptilia, Squamata,Mammalia, Aves et Testudines

unique(taxo$class)
#Aqua<- dbGetQuery(connexion, 'SELECT TSN,class 
#                      FROM taxo 
#                  WHERE class LIKE %Petromyzonti% 
#                  OR class LIKE '%Myxini%'
#                  OR class LIKE '%Myxini%'
#                  OR class LIKE '%Elasmobranchii%''
#                  OR class LIKE '%Chondrichthyes%' 
#                  OR class LIKE '%Chondrostei%'
#                  OR class LIKE '%Holostei%' 
#                  OR class LIKE '%Amphibia%' );
              



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
JOIN abondance a ON p.cle_pop = a.cle_pop;
"

InstantI <- dbGetQuery(connexion, Filtre_Aqua)
View(InstantI)

#Section 2: Calcul de variation

#Hist: obtient intervalle annéeIII
hist(InstantI$years)

#Sélection manuelle par subset pour éviter Bug:À optimiser
I<-subset(InstantI,InstantI$years==1985)
II<-subset(InstantI,InstantI$years==1986)
III<-subset(InstantI,InstantI$years==1987)
IV<-subset(InstantI,InstantI$years==1988)
V<-subset(InstantI,InstantI$years==1989)
VI<-subset(InstantI,InstantI$years==1990)
1985-1990<-cbind()
Intervalle85_90<-rbind(I,II,III,IV,V,VI)


#Boucle de calcul de variation de des population sur intervalle de temps 

#longueur boucle
a<-sort(unique(Intervalle85_90$cle_pop))
#création objet boucle
i=1
Time<-Intervalle85_90$years
A_Cible<-Intervalle85_90$val
Pop_cible<-Intervalle85_90$cle_pop

#Création vecteur vide pour stocker variation
percent_pop_var<-c()


for (i in 1:length(a)) {
Rmax<-which(Pop_cible==a[i]&Time==max(Time))
Val_F<-A_Cible[Rmax]
Rmin<-which(Pop_cible==a[i]&Time==min(Time))
Val_I<-A_Cible[Rmin]

#calculpourcentage variation
if(length(Val_F)!=0&length(Val_I)!=0){
y<-((Val_F/Val_I)-1)*100
percent_pop_var<-c(percent_pop_var,y)
}

i=i+1
}
View(percent_pop_var)
percent_var_<-data.frame(percent_pop_var)

#Section 3: Histogramme

hist(percent_pop_var,main = ' %variation pour population des classes animales aquatiques de 1985 à 1990', 
     xlab = 'Poucentage de variation',ylab = 'Nombre population aquatique',
     breaks = 50,freq = TRUE,xlim = c(-100, 2000))
?hist()
axis(1,2500,100)


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

#Hist: obtient intervalle annéeIII
hist(Data_TER$years)

#Sélection manuelle par subset pour éviter Bug:À optimiser

T_Ter<-Data_TER$years
VII<-subset(Data_TER,T_Ter==1985)
VIII<-subset(Data_TER,T_Ter==1986)
IX<-subset(Data_TER,T_Ter==1987)
X<-subset(Data_TER,T_Ter==1988)
XI<-subset(Data_TER,T_Ter==1989)
XII<-subset(Data_TER,T_Ter==1990)

Intervalle85_90_TER<-rbind(VII,VIII,IX,X,XI,XII)


#Boucle de calcul de variation de des population sur intervalle de temps 

#longueur boucle
b<-sort(unique(Intervalle85_90_TER$cle_pop))


#simplification écriture par objet

Time<-Intervalle85_90_TER$years
A_Cible<-Intervalle85_90_TER$val
Pop_cible<-Intervalle85_90_TER$cle_pop

#Création vecteur vide pour stocker variation
percent_pop_var_TER<-c()

#création objet boucle
i=1
for (i in 1:length(b)) {
  Rmax<-which(Pop_cible==b[i]&Time==max(Time))
  Val_F<-A_Cible[Rmax]
  Rmin<-which(Pop_cible==b[i]&Time==min(Time))
  Val_I<-A_Cible[Rmin]
  
  #calculpourcentage variation
  if(length(Val_F)!=0&length(Val_I)!=0){
    y<-((Val_F/Val_I)-1)*100
    percent_pop_var_TER<-c(percent_pop_var_TER,y)
  }
  
  i=i+1
}
View(percent_pop_var_TER)
percent_var_<-data.frame(percent_pop_var_TER)

#Section 3: Histogramme

Histo_Terrestre<-hist(percent_pop_var_TER,main = ' %variation pour population des classes Aves et Mammalia de 1985 à 1990',
     xlab = 'Poucentage de variation',ylab = 'Nombre population aquatique',
     breaks = 50,freq = TRUE,xlim = c(-100, 500),ylim = c(0,25))






