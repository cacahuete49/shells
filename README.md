# shells
## toTv.sh
Déplacement des fichiers directement en ligne de commande dans le bon rep du raspberry
TODO: ajouter la detection du type de contenu film, serie, musique

## extractData.ksh
Parse les différentes sources de données: filesystem, fichier, bdd pour extraire les données au format java .properties

## updatePlan.ksh
Met à jour le fichier de propriété généré pas extractData.sh avec un fichier généré à heure fixe par le serveur.

## updateWiki.ksh
Parse un fichier java .properties pour formater un fichier texte en wikicode.

## archivageDesFlux.ksh
A partir d'une liste de path, archive tous les fichiers de plus de deux semaines, avec affichage du gain d'espace obtenu

## purgeDesArchives.ksh
A partir d'une liste de path, supprime toutes les archives de plus d'un mois
