#!/bin/ksh
# ******************************************************************************
# Nom		: purgeDesFlux.ksh
# Auteur	: Quentin Rabineau
# Date    	: 30/03/2016
# Cron		: Est exécuté toutes les semaines
# ******************************************************************************

set initPath=$(pwd)

#Liste des serveurs dpo
set -A PATHLOGS "/i/am/a/path"

date "+%d/%m/%Y"
echo "Purge des archives de plus de 30 jours"

for path in ${PATHLOGS[@]}; do
    cd $path;
    find . -maxdepth 1 -type f -name "*.tar.gz" -mtime +30 -exec rm {} \;
done

cd $initPath
