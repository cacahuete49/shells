#!/bin/ksh

## GLOBAL
pathfile=$HOME/
pathfile+=$(ls -a1 $HOME | egrep "^\.*\.properties")

###
## $1 user
## s2 cics
## return plan
###
get_plan() {
  if [[ "$#" -ne 2 ]]; then
    exit 1
  else
    grep "$1 $2" ficui10.txt | awk '{print substr($3,0,8)}'
  fi
}

###
## $1 key : key in property file
## return value
###
get_value() {
   grep -Po "$1=\K.+" $pathfile
}


###
## Search and replace in wiki code
## $1 key
## $2 value
###
search_and_replace() {
   sed -i -r "s#($1=)'[^']*'#\1'$2'#" confWiki/jspwiki/pages/$(echo "$USER" | sed 's/.*/\u&/').txt
}



user=$(get_value "$USER.user.ibm")
cics=$(get_value "$USER.cics")
search_and_replace PlanCcpLbp $(get_plan $user $cics)


user=$(get_value "$USER.cics.user.name")
cics=$(get_value "$USER.cics")
search_and_replace PlanIns $(get_plan $user $cics)

user=$(get_value "$USER.user.ibm")
cics=$(get_value "$USER.cics.ce")
search_and_replace PlanCcpCe $(get_plan $user $cics)

user=$(get_value "$USER.user.ws")
cics=$(get_value "$USER.cics.ws")
search_and_replace PlanCcpWsLbp $(get_plan $user $cics)

user=$(get_value "$USER.user.ws")
cics=$(get_value "$USER.cics.ce.ws")
search_and_replace PlanCcpWsCe  $(get_plan $user $cics)

user=$(get_value "$USER.user.ws")
cics=$(get_value "$USER.cics.ws")
search_and_replace PlanInsWs  $(get_plan $user $cics)

user=$(get_value "$USER.cxf.cics.user.name")
cics=$(get_value "$USER.cxf.cics")
search_and_replace PlanInsCxf $(get_plan $user $cics)
