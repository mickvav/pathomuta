#!/bin/bash
for i in `cat $1`; do
   j=`basename $i`;
   n=data/${j%%.bz2}
   if [ ! -f ${n}.out.bgrep -o "$i" -nt ${n}.out ]; then
#     bzip2 -dc $i > $n
#     java -Xmx4g -jar snpEff.jar GRCh38.78 $n > ${n}.out
#     rm -f $n
      bzfgrep -f /home/kappa/clnsig-5.txt $i > ${n}.out.bgrep
   fi
done
