#!/bin/ksh
#
# author : Quentin Rabineau
# commentaire : sed je t'aime ... moi non plus XD
#

##
#
# acces a la base ins pour récup ind
#
##
database_access() {
#TLS
ind=$(sqlplus -S << EOF
$user/$mdp$base
set heading off
whenever sqlerror exit sql.sqlcode
select * from (select TAG from DATABASECHANGELOG where TAG like 'INSTLS%' order by orderexecuted desc) where rownum=1;
quit
EOF
)

sql_return=$?

if [ $sql_return -ne 0 ]
  then 
    ind=""
    echo "Problème sql lors de la récupération d'ind tls"
fi

## on supprime les charactères genant en retour de sqlplus
echo "ind.tls=${ind//[[:space:]]/}" \
>> $FILENAME

#REQ
ind=$(sqlplus -S << EOF
$user/$mdp$base
set heading off
whenever sqlerror exit sql.sqlcode
select * from (select TAG from DATABASECHANGELOG where TAG like 'INSREQ%' order by orderexecuted desc) where rownum=1;
quit
EOF
)

sql_return=$?

if [ $sql_return -ne 0 ]
  then 
    ind=""
    echo "Problème sql lors de la récupération d'ind req"
fi
## on supprime les charactères genant en retour de sqlplus
echo "ind.req=${ind//[[:space:]]/}" \
>> $FILENAME

# Si le user contient INSREQ alors les informations de INSREF doivent être,
# dans une base portant un nom et mdp presque identique ( REQ -> REF )
# exemple: INSREQPBATCH/INSREQPBATCH#2 devient INSREFPBATCH/INSREFPBATCH#2
if [[ "$user" == INSREQ* ]];then
  user=$( echo $user | sed -e "s/REQ/REF/" )
  mdp=$( echo $mdp | sed -e "s/REQ/REF/" )
fi
#REF
ind=$(sqlplus -S << EOF
$user/$mdp$base
set heading off
whenever sqlerror exit sql.sqlcode
select * from (select TAG from DATABASECHANGELOG where TAG like 'INSREF%' order by orderexecuted desc) where rownum=1;
quit
EOF
)

sql_return=$?

if [ $sql_return -ne 0 ]
  then 
    ind=""
    echo "Problème sql lors de la récupération d'ind ref"
fi

## on supprime les charactères genant en retour de sqlplus
echo "ind.ref=${ind//[[:space:]]/}" \
>> $FILENAME

}

# tagada tsointsoin
FILENAME="$HOME/.$USER.properties"

ear=$(ls -t $HOME/wls10.3.6/dpo-domain/applications/*.ear | head -1)

## extraction des données ins, inc, ina, inx ,xmx, mdm situé dans le manifest de l'ear, ils sont déclaré dans le pom principal
## oh puré c'est beau ca <3
unzip -p $ear META-INF/MANIFEST.MF \
| egrep "^(ccp|in|xmx|mdm|Specification-Version)" \
| sed -e "s/: /=/g;s/Specification-Version/dpo.version/g" \
> $FILENAME

## dpo.properties
egrep "^DPO_ID_INSTANCE" ~/wls10.3.6/dpo-domain/conf/dpo.properties | sed "s/_/./g" \
>> $FILENAME

## ins.properties
egrep "^(fr.cnp.ins.cics.user.name=|fr.cnp.ins.mule.spa.actif=|fr.cnp.ins.mule.spa.protocol=|fr.cnp.ins.mule.spa.url=|fr.cnp.ins.mule.rcu.protocol=|fr.cnp.ins.mule.rcu.url=|fr.cnp.ins.mule.ctr.protocol=|fr.cnp.ins.mule.ctr.url=|fr.cnp.ins.mule.id1.protocol=|fr.cnp.ins.mule.id1.url)" ~/wls10.3.6/dpo-domain/conf/ins.properties | sed -e "s/fr.cnp.//g" \
>> $FILENAME

## xmx.properties
egrep "^(USER_IBM|USER_WS|CICS=|CICS_CE=|INS_CICS=|CICS_WS=|CICS_CE_WS=|INS_CICS_WS=)" ~/conf/xmx.properties | sed -e "s/_/./g;s/^[^=]*/\L&/g" \
>> $FILENAME

## dpo.cxf.properties
egrep "^(dpo.cxf.provider.url|dpo.cxf.cics.user.name|dpo.cxf.cics|dpo.cxf.esb.spa.url|dpo.cxf.mdi.url|dpo.cxf.med.url|dpo.cxf.ado.url)" ~/conf/dpo.cxf.properties \
>> $FILENAME

## properties avec maching jdbc deployé
## c'est beau ca aussi <3
tmp=$(egrep  "^req.jndi.name=" $HOME/conf/properties | sed "s/^[^=]*=//")
## on conserve la base extrait pour ind
base=$(egrep "jdbc:oracle:" $HOME/config/jdbc/$tmp* | sed -e "s/^[^@]*//g;s/<\/.*//g;")
echo "$base" | sed -e "s/^@*/base=/g" \
>> $FILENAME

# inb dans le repertoire des batch
ls $HOME/batch/lib/*main.jar | cut -d"/" -f8 | egrep -o --color "[0-9]+(.[0-9]+)*(-P[0-9])*" | sed -e "s/^/inb=/" \
>> $FILENAME

## version IND
src="/projets/dpo/home/dpoadm/confWiki/jspwiki/pages/Base+dossier.txt"
if [[ "$base" == @DDPODEV* ]];then
  user=$( echo "$base" | sed "s/^@D/A/" )
  mdp="adm"
  database_access
else
  if grep -q ${base:1} $src; then
    ## ATTENTION ce passage dépend de la mise en page de fichier Base-dossier.txt en cas de modification il faudra revoir les "cut"
    user_mdp=$(grep ${base:1} $src | cut -d'|' -f5)
    user=$(echo $user_mdp | cut -d'/' -f1)
    mdp=$(echo $user_mdp | cut -d'/' -f2)
    database_access
  else
    echo "la base n'est pas connu =("
 fi
fi


## Traitement final de formatage
sed -i -e  "s/\r//g;s/^/$USER./g;" $FILENAME
