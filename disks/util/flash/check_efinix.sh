#!/bin/bash

# This script makes sure the Efinix builds were assembled
# from multi.hex files properly.
#
# HOWTO: Move all the .zips to check into a subdir called 'latest'
# Run this script from one level up
#
# MAINLH Golden builds should have 0a 10 00 location bytes
# MAINLG Golden builds should have 0a 60 00 location bytes
# All Multiboot builds should have 00 00 00 location bytes

FILES=`ls -1 latest`

for f in $FILES
do
   rm -rf tmp
   mkdir -p tmp

   pushd tmp > /dev/null 2> /dev/null
   echo -n $f"," > report.txt
   unzip ../latest/$f > /dev/null 2> /dev/null
   strings flash.d81 | grep Generated | sed 's/Generated: //' | tr -d '\n' >> report.txt

   echo -n "," >> report.txt
   c1541 -attach flash1.d64 -read i000 > /dev/null 2> /dev/null
   od -t x1 i000 | grep 0000500 | sed 's/^0000500 .. .. .. .. .. .. .. .. .. .. //' | sed 's/.. .. ..$//' | tr -d '\n' >> report.txt

   echo >> report.txt

   cat report.txt
   popd > /dev/null 2> /dev/null
done
