#!/bin/bash
for i in `cat $1`; do
   j=`basename $i`;
   n=data/${j%%.bz2}
   if [ ! -f ${n}.out -o "$i" -nt ${n}.out ]; then
     if [ "$i" != "$n" ]; then
        bzip2 -dc $i > $n
     fi
     echo $n
     java -Xmx4g -jar snpEff.jar GRCh38.78 $n > ${n}.out
     rm -f $n
   fi
done
