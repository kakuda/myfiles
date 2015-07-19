#!/bin/sh
for i in m4a/*.m4a
do
  echo $i
  faad -o /tmp/tmp.wav "$i"
  new=`echo $i | sed -e 's/aac.p.m4a/mp3/' | sed -e 's/aac.m4a/mp3/' | sed -e 's/m4a\///'`
  lame --silent -b 192k -h /tmp/tmp.wav "mp3/$new"
done
