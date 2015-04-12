
files04:: files
		split -n5 -d files files	
files::$(wildcard /opt/data/genomes/*.bz2)
		ls -la /opt/data/genomes/*.bz2 | sort -k 5 -n | awk '{if($$5>0){ print $$9; };}' > files

run:: run00 run01 run02 run03 run04
run00:: files04
		./annotate_files.sh files00
run01:: files04
		./annotate_files.sh files01
run02:: files04
		./annotate_files.sh files02
run03:: files04
		./annotate_files.sh files03
run04:: files04
		./annotate_files.sh files04

runbgrep:: runbgrep00 runbgrep01 runbgrep02 runbgrep03 runbgrep04
runbgrep00:: files04
		./bgrep.sh files00
runbgrep01:: files04
		./bgrep.sh files01
runbgrep02:: files04
		./bgrep.sh files02
runbgrep03:: files04
		./bgrep.sh files03
runbgrep04:: files04
		./bgrep.sh files04
runjoinbgrep:: files
		for i in `cat files`; do j=`basename $$i`;j=$${j%%.bz2}; f1=data/$$j.out.bgrep.head; f2=data/$$j.out.bgrep; if [ -f $$f1 -a -f $$f2 ];then cat $$f1 $$f2 > data/$$j.bgrep.joined;else echo $$f1; echo $$f2; fi; done
		ls data/*.bgrep.joined > files.joined
dlxmls:: clnsig-5.txt 
		if [ ! -d "data/xmls" ]; then mkdir data/xmls; fi
		s=1;for i in `cat $<`; do j=$${i#rs}; wget -q -b -O data/xmls/$$i "http://www.ncbi.nlm.nih.gov/snp/$$j?report=XML&format=text" ; s=$$((s+1)); if [ "$$s" = "10" ]; then sleep 5; s=1; fi; done
