#!/bin/ksh

echo "debut du chargement des données dans le wiki"

### variable global
## Nom du domaine
domain=$USER
## Le nom du fichier commence par une majuscule
file=$(echo "$domain" | sed 's/.*/\u&/')
## Chemin vers le dossier des pages wiki
path_wikipage="/projets/dpo/home/dpoadm/confWiki/jspwiki/pages"

## copie temporaire pour comparaison final
cp $path_wikipage/$file.txt  $path_wikipage/$file.txt.tmp

###
## $1 key
## $2 value
###
search_and_replace() {
    sed -i -r "s#($1=)'[^']*'#\1'$2'#" $path_wikipage/$file.txt
}


###
## $1 nom du fichier à deplacer (sans extension)
###
record() {
    FILENAME=$1

    TMPFILE="$path_wikipage/$FILENAME.txt.tmp"
    HISTORYDIR="$path_wikipage/OLD/$FILENAME"

    LAST=$(ls -1 -t $HISTORYDIR | egrep ^[0-9]+ | head -1 | sed -e 's/\..*$//')

    NEW=$((LAST+1))

    mv $TMPFILE $HISTORYDIR/$NEW.txt && echo "$(($NEW+1)).author=$USER" >>  $HISTORYDIR/page.properties
}

### main
data=$domain.ccp
search_and_replace CcpVersion $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins
search_and_replace InsIns $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.inc
search_and_replace InsInc $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.inx
search_and_replace InsInx $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.version
search_and_replace DpoVersion $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.mdm
search_and_replace MdmVersion $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.DPO.ID.INSTANCE
search_and_replace DpoCouloir $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.mule.spa.actif
search_and_replace EstSpaActif $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.mule.spa.url
protocol=$domain.ins.mule.spa.protocol
search_and_replace InsMuleSpa $(grep -Po "$protocol=\K.+" ~/.$domain.properties)$(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.mule.id1.url
protocol=$domain.ins.mule.id1.protocol
search_and_replace InsMuleIdd $(grep -Po "$protocol=\K.+" ~/.$domain.properties)$(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.mule.rcu.url
protocol=$domain.ins.mule.rcu.protocol
search_and_replace InsMuleRcu $(grep -Po "$protocol=\K.+" ~/.$domain.properties)$(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.mule.ctr.url
protocol=$domain.ins.mule.ctr.protocol
search_and_replace InsMuleCtr $(grep -Po "$protocol=\K.+" ~/.$domain.properties)$(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.user.ibm
search_and_replace UserIbm $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.cics
search_and_replace CcpCicsLbp $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.cics.ce
search_and_replace CcpCicsCe $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.cics
search_and_replace InsCicsXmx $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.user.ws
search_and_replace UserWsIbm $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.cics.ws
search_and_replace CcpCicsWsLbp $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.cics.ce.ws
search_and_replace CcpCicsWsCe $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ins.cics.ws
search_and_replace InsCicsXmxWs $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.provider.url
search_and_replace CxfCicsRcu $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.cics.user.name
search_and_replace InsUserCxf $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.cics
search_and_replace InsCicsCxf $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.esb.spa.url
search_and_replace CxfMuleSpa $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.mdi.url
search_and_replace CxfMuleMdi $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.ado.url
search_and_replace CxfMuleAdo $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.dpo.cxf.med.url
search_and_replace CxfMuleMed $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.base
search_and_replace InsBases $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.inb
search_and_replace InsInb $(grep -Po "$data=\K.+" ~/.$domain.properties)

data=$domain.ind.tls
search_and_replace IndTls $(grep -Po "$data=\K.+" ~/.$domain.properties)
data=$domain.ind.req
search_and_replace IndReq $(grep -Po "$data=\K.+" ~/.$domain.properties)
data=$domain.ind.ref
search_and_replace IndRef $(grep -Po "$data=\K.+" ~/.$domain.properties)


## on test si la conf à été modifié ou pas !!!
if cmp -s $path_wikipage/$file.txt  $path_wikipage/$file.txt.tmp
then
    echo "pas de changement de configuration entre deux  start"
else
    # on change la date
    data=$(date +%d/%m/%Y)
    search_and_replace ConfigurationMaj $data
    # On historise l'ancienne configuration
    record $file
    # On redémarre le server pour la prise en compte des modifs
    if [ $USER = "dpoadm" ]; then
        . restart
    else
        ssh adm@host "restart" 1> /dev/null
    fi
fi

echo "fin du chargement"
