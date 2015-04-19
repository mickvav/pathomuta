CFLAGS?= -O2
EXEC_PREFIX?= .
FILE?= test.txt
FIELDWIDTH?= 1
help ::
	@echo -ne "Usage: \n  FILE=file.txt make file.gd - analise file.txt to produce graph in .gd format"
$(EXEC_PREFIX)/analise_file:: analise_file.c
		gcc -o $@ $(CFLAGS) $< 
$(EXEC_PREFIX)/gendistmatrix:: gendistmatrix.c Makefile  masked.c  masked.h  
		gcc -o $@ $(CFLAGS) -DFIELDWIDTH=$(FIELDWIDTH) gendistmatrix.c masked.c  masked.h

$(FILE).gd :: $(FILE) $(EXEC_PREFIX)/analise_file cluster_tree.c  Makefile  masked.c  masked.h
		W=`$(EXEC_PREFIX)/analise_file $(FILE)`; FIELDWIDTH="$$W" make $(EXEC_PREFIX)/clusteriser ; $(EXEC_PREFIX)/clusteriser $(FILE) > $(FILE).gd

$(EXEC_PREFIX)/clusteriser :: $(FILE) cluster_tree.c  Makefile  masked.c  masked.h
		gcc -o $@ $(CFLAGS) -DFIELDWIDTH=$(FIELDWIDTH) cluster_tree.c masked.c  masked.h
		
