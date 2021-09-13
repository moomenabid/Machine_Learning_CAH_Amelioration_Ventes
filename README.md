# Machine_Learning_CAH_Amelioration_Ventes

Ceci est un algorithme de remplissage des canaux de ventes amélioré qui se base sur la technique de clustering hiérarchique de ward CAH pour savoir quels produits sont les plus liés à un certain produit cible.  

La démarche suivie consiste à déterminer pour chaque couple (client,produit) cible les produits les plus proches de lui en appliquant la technique de clustering hiérarchique de ward CAH, ensuite de prendre ce groupe de produits et de réappliquer la même technique de clustering au sein de ce groupe pour déterminer les clients les plus proches du couple cible (client,produit).  

On obtient ainsi pour ce couple, une dataframe constitué de lignes de clients et de colonnes de produits les plus proches du couple cible, et on prend ensuite la médiane des produits proches pour estimer la valeur des ventes pour ce couple de (client,produit).  

