FILES=$(shell ls | grep -v Makefile)
DESTPATH=/usr/lib/cgi-bin/
DESTFILES=$(patsubst %,$(DESTPATH)/%,$(FILES))
install :: $(DESTFILES)
        
$(DESTPATH)/% :: %
		@if perl -c $<; then diff $@ $<;cp -f $< $@; else cp -f $< $@; echo "Syntax error in $<. File Installed anyway."; fi

