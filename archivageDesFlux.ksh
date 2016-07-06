#!/bin/ksh
# ******************************************************************************
# Nom		: archivageDesFlux.ksh
# Auteur	: Quentin Rabineau
# Date    	: 02/09/2015
# Cron		: Est exécuté toutes les semaines
# ******************************************************************************

set initPath=$(pwd)

#Liste des paths 
set -A PATHLOGS "/i/am/a/path"

date "+%d/%m/%Y"

for path in ${PATHLOGS[@]}; do
  cd $path;
 
  FILENAME="backup_$(date '+%y-%m-%d-%Hh%Mm%S').tar.gz"
 
  # taille des fichiers concerné 
  w=$(find . -maxdepth 1 -mtime +7 -type d -exec du -s {} \; | awk '{if ($2!=".") S+=$1}END{print S}')
 
  if [ -z $w ];
    then
      echo "Pas de fichier a archiver !";
      continue;
    else
      echo $path'/'$FILENAME
  fi
 
  # archivage
  find . -maxdepth 1 -mtime +7 -type d | tar zcf $FILENAME --remove-files -T -
 
  # taille de l'archive généré
  v=$(du -s $FILENAME | awk '{print $1}')
 
  # gain de la taille
  gain=$(echo "scale=2; 100-100*$v/$w" | bc)

  # log
  echo 'Taille initial : '$w'k'
  echo 'Taille de l archive : '$v'k'
  echo -e 'gain d espace de '$gain'%\n'

done

cd $initPath
