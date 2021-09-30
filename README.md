# Remplissage-des-canaux-de-vente-par-clustering-CAH-Ward

Ceci est un algorithme de __remplissage des canaux de ventes__ amélioré qui se base sur la technique de clustering hiérarchique de ward CAH pour savoir quels produits sont les plus liés à un certain produit cible.  

La démarche suivie consiste à déterminer pour chaque couple (client,produit) cible les produits __les plus proches__ de lui en appliquant la technique de __clustering hiérarchique de ward CAH__, ensuite de prendre ce groupe de produits et de réappliquer la même technique de clustering au sein de ce groupe pour déterminer les clients les plus proches du couple cible (client,produit).  
On obtient ainsi pour ce couple, une __dataframe__ constitué de lignes de clients et de colonnes de produits __les plus proches__ du couple cible, et on prend ensuite la médiane des produits proches pour estimer la valeur des ventes pour ce couple de (client,produit). L'algorithme est expliqué aussi dans le pdf __ChannelFill Code Explanation.pdf__

Le code est constitué de plusieurs étapes parmi lesquelles on peut trouver:  
-Data préparation pour que les données soient dans le format attendu en effectuant des __opérations d'aggrégation__  
-Preprocessing des données ce qui donne des données __centrées réduites__  
-Application du __clustering hiérarchique de ward CAH__ pour créer des sous groupes de produits semblables  
-Application du clustering hiérarchique de ward CAH dans chaque groupe de produits semblables pour créer des sous groupes de clients semblables  
-Définition d'une __métrique__ et affectation d'un score noté __PotentialScore__ dans chaque sous groupe qui mesure le degré d'homogénité d'un sous groupe  
-Affectation de la médiane du produit pour le couple (client, produit) si le score __PotentialScore__ est supérieur à un certain seuil __score_threshold__  
-__Réglage des paramètres__ de clustering pour une meilleure répartition et homogénéité des groupes et ainsi __une optimisation des prédictions__  
