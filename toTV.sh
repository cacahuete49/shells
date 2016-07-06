#!/usr/bin/zsh

ip=#IP_RASPBERRY_PI

## L'hote est accessible
if ping -W 1 -c 1 $ip > /dev/null
  then
##   nothing
  else
   echo $ip inaccessible;
   exit 1;
fi

args=("${(@)@:#-*}");

local -a files

## test de l'existance des différents fichiers
for arg in $args; do 
  if [[ ( -r $arg ) ]]; then
    files+=$arg
  else
    echo "files doesn't exist"
  fi
done


for file in $files ; do
   scp $file root@$ip:/storage/videos;
done
