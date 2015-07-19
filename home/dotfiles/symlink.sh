#!/bin/sh
for f in `find . -type f -name ".*" | grep -vE "\.(svn|git)"`; do
  ln -s $f ~/
done
