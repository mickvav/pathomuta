#!/bin/bash
echo "DROP TABLE MUTATIONS; delete from files" | mysql -umutfreq -pmutfreq mutfreq
cat mutations_table.sql | mysql -umutfreq -pmutfreq mutfreq

counter=1
for i in data/*.vcf.bgrep.joined.out; do 
   echo $i
   j=${i}.nohead
   cat $i | grep -v '^#' > $j
   ./parse $j $counter | mysql -umutfreq -pmutfreq mutfreq
   echo "insert into files set FILEID=$counter,FILENAME='$j'"|  mysql -umutfreq -pmutfreq mutfreq
   counter=$((counter+1))
done
