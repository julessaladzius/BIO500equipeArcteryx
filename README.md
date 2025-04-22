Équipe Arcteryx
Projet final - BIO500
Ce projet vise à nettoyer, structurer et analyser les données de séries temporelles de suivi de populations 

Jules Saladzius
Nathan Bousquet
François Martin

-------------------
Dépendances utilisées
- tidyverse
- targets
- tarchetypes
- RSQLite
- rmarkdown
-------------------

Toute la lecture, traitement et l'analyse des données se fait avec un pipeline _target executable avec la fonction
tar_make()

Celle-ci génère un HTML du rapport final dans le dossier Rapports/

-------------------

Les données sources sont stockées dans :
- `data/raw/Données/` 
- `data/Nettoyé/Table_taxo.csv` -> table taxonomique standardisée (produite via l'API de ITIS)
La base SQLite est générée automatiquement : `database/donneessql`


------------------
Merci




--- Info pour Validation des données ---

Élaboration des clé primaires
Populations supprimées car differentes valeurs de cle_pop+years: 
1172 2463 1625 1257 1260 1968  688  205 1246 1245  211  973  969  970  971  972 1931 1807 1640  524 1170 2345
1974 1707
102 1800

cle_source est unique c'est bien. 
cle_geom est unique c'est bien.
Observed_scientific_name est unique c'est bien.
TSN est pas bien, quelques lignes indiquent des noms d'espèces legerements différents (noms communs).
  Nous allons donc seulement garder une ligne par TSN. Pour en faire clé primaire. 