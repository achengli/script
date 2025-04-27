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

function echoerr(){
  echo "Error: :$1"
  exit -1
}

function trim(){
  local o=$(echo $1 | grep -Eo '^[^[:blank:]].+$' | grep -Eo '.+[^[:blank:]]*$')
  echo $o
}

function backup(){
  local backup_dir=backup-$(date +'%d_%m_%Y')
  local format='zip'
  local backup='backup.txt'
  local others=""

  for i in "$@"; do
    if [ "${i:0:1}" == "-" ]; then
      local key=$(echo $i | grep -Eo "[^\-]*")
      if [ -n "$last_arg" ]; then
        echoerr "bad arguments"
      fi
      last_arg=$key
    else
      if [ -n "$last_arg" ]; then
        case "$last_arg" in
          -f|--format)
            format="$i"
            ;;
          -b|--backup)
            backup="$i"
            ;;
        esac;
      else
        others="$others $i"
      fi
      last_arg=""
    fi
  done

  mkdir -p $backup_dir 
  while read line
  do
    line=$(trim $line)
    if [ -n "${line}" ] && [ ${line:0:1} != '#' ]; then
      cp -r $line $backup_dir
    fi
  done < $backup

  if [ "$format" == "zip" ]; then
    zip -r "${backup_dir}.zip" $backup_dir
  elif [ "$format" == "tgz" ]; then
    tar czvf "${backup_dir}.tar.gz" $backup_dir
  else
    echo "Compression $format not supported. Will be compressed with gzip"
  fi
}

backup $@
