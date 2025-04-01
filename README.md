# BIO500equipeArcteryx
Avec les données de séries temporelles
modification par jules voici notre proejt

Le ciel est bleu et tout va bien!

Élaboration des clé primaires
Populations supprimées car differentes valeurs de cle_pop+years: 
1172 2463 1625 1257 1260 1968  688  205 1246 1245  211  973  969  970  971  972 1931 1807 1640  524 1170 2345
1974 1707

cle_source est unique c'est bien. 
cle_geom est unique c'est bien.
Observed_scientific_name est unique c'est bien.
TSN est pas bien, quelques lignes indiquent des noms d'espèces legerements différents (noms communs).
  Nous allons donc seulement garder une ligne par TSN. Pour en faire clé primaire. 