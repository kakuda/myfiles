#!/bin/bash

if [ "$#" != "3" ]; then
  echo "Usage: rails-svn app_dir repository username"
  exit 1
fi

APPDIR=./$1
SVN_TRUNK=$2
SVN_USER=$3

function check_if_exist () {
  if [[ -e $1 ]]; then
    echo ""
    echo "$1 already exists, overwrite? y or n"
    echo ""
    read OVERWRITE
    case "$OVERWRITE" in
    y)
      echo "Overwriting..."
      ;;
    *)
      echo "Action canceled"
      exit 1
      ;;
    esac
  fi
}

check_if_exist ${APPDIR}
rails $APPDIR
svn import $APPDIR $SVN_TRUNK -m "Import" --username $SVN_USER
sudo rm -r $APPDIR
svn checkout $SVN_TRUNK $APPDIR
cd $APPDIR

svn remove log/*
svn commit -m "removing log files"
svn propset svn:ignore "*.log" log/
svn update log/
svn commit -m "Ignoring all files in /log/ ending in .log"
svn move config/database.yml config/database.example
svn commit -m "Moving database.yml to database.example to provide a template for anyone who checks out the code"
svn propset svn:ignore "database.yml" config/
svn update config/
svn commit -m "Ignoring database.yml"
svn remove tmp/*
svn propset svn:ignore "*" tmp/
svn update tmp/
svn commit -m "ignore tmp/ content from now"
svn propset svn:ignore ".htaccess" public/
svn update public/
svn commit -m "Ignoring .htaccess"
svn propset svn:ignore "dispatch.fcgi" public/
svn update public/
svn commit -m "Ignoring dispatch.fcgi"