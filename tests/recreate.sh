#!/bin/bash
#*******************************************************#
#                      x.sh                             #
#                 written by Rahul Kumar                #
#                    2009/12/01                         #
#                 Does ...                              #
#*******************************************************#

oldfile="$1"
[ ! -f "$oldfile" ] && { echo "Could not find $oldfile"; exit -1 ; }

LOADSTR=
if grep -q CATEOF "$oldfile"; then
   sed -n '/<<CATEOF/,/^CATEOF/p' "$oldfile" | grep -v "CATEOF" > data.1
   LOADSTR='--load data.1'
   echo found data, saved as data.1
   wc -l data.1
fi
str=$( echo "$oldfile" | sed 's/^t[0-9]*-//;s/.sh$//' )
echo "Using suffix:$str"
read -p "press enter "
grep '^>>> ' "$oldfile" | sed 's/^>>> //' 
read -p "press enter "
grep '^>>> ' "$oldfile" | sed 's/^>>> //' | ./rtest2.sh $LOADSTR "$str"

echo
echo renaming old file
mv "$oldfile" O$oldfile
