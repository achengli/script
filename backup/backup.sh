#!/usr/bin/env bash
## **********************************************************************************
## *                                Backup generator                                *
## **********************************************************************************
## Generates a backup regarding the files staged in backup.txt. The file backup.txt
## must be a list of all wanted directories and files to be stored.
##
## Output can be tar gzip file 'tgz' or zip depending if --zip or --tgz was set.
##
## ----------------------------------------------------------------------------------
## * Script made by Yassin Achengli - Copyright (c) 2025 BY-NC
## * Licensed under MIT terms.
## ----------------------------------------------------------------------------------

function trim(){
  local o=$(echo $1 | grep -Eo '^[^[:blank:]].+$' | grep -Eo '.+[^[:blank:]]*$')
  echo $o
}

# TODO
function parse-arguments(){
  local args
  declare -A args
  local last_arg=''
  local last_key=''
  for i=($@); do
    if [ "${i:0:2}" == "--" ] || [ "${i:0:1}" == "-" ]; then
      if [ -z "${last_arg}" ];then
        args["$last_arg"]=1
      else
        args["$last_arg"]
      fi
    else
      if [ -z "$last_key" ]; then
        last
      fi
    fi
  done
}

function backup(){
  local backup_dir=backup-$(date +'%d_%m_%Y')

  mkdir -p $backup_dir 
  while read line
  do
    line=$(trim $line)
    if [ -n "${line}" ] && [ ${line:0:1} != '#' ]; then
      cp -r $line $backup_dir
    fi
  done < backup.txt
}
