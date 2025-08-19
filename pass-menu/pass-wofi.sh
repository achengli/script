#!/usr/bin/env bash
## **********************************************************************************
## *                             Pass with wofi menu                                *
## **********************************************************************************
## Executes pass application using wofi to list the available password in .password-store.
## ----------------------------------------------------------------------------------
## * Script made by Yassin Achengli - Copyright (c) 2025 BY-NC
## * Licensed under MIT terms.
## ----------------------------------------------------------------------------------


shopt -s nullglob globstar

typeit=0
if [[ $1 == "--type" ]]; then
	typeit=1
	shift
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

password=$(printf '%s\n' "${password_files[@]}" | wofi --dmenu  "$@")

if ! [ -d $HOME/.local/tmp ]; then
  mkdir -p $HOME/.local/tmp
  echo 50 > $HOME/.local/tmp/newid
fi

newid=$(cat $HOME/.local/tmp/newid | xargs)
password_in=0

for p in ${password_files[@]}; do
  if [[ "$p" == "$password" ]]; then
    password_in=1
  fi
done

if [[ $password_in == 0 ]]; then
  newid=$(notify-send -t 2500 -a "Password Store" --icon dialog-password\
    --replace-id=$newid --print-id "❌ Password not selected"\
    "Empty password" )
  echo $newid > $HOME/.local/tmp/newid
  exit
fi

if [[ $typeit -eq 0 ]]; then
	pass show -c "$password" 2>/dev/null
else
	pass show "$password" | { IFS= read -r pass; printf %s "$pass"; } |
		ydotool type --clearmodifiers --file -
fi

newid=$(notify-send -t 2500 -a "Password Store" --icon dialog-password\
  --replace-id=$newid --print-id "✅ Password copied"\
  "<b>$password</b> is in clipboard" )

echo $newid > $HOME/.local/tmp/newid
