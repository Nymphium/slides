CONTINUE ?=
TARGET = main
LATEXMKFLAG =-lualatex -interaction=nonstopmode $(CONTINUE)

all:
	latexmk $(LATEXMKFLAG) $(TARGET).tex
continue:
	make CONTINUE=-pvc
clean:
	latexmk -C
	-rm $(TARGET).ltjruby
	-rm $(TARGET).nav
	-rm $(TARGET).snm
	-rm $(TARGET).vrb
	-rm $(TARGET).pyg
	-rm $(TARGET).bbl*
	-rm $(TARGET).bcf
	-rm -rf _minted
	-rm indent.log

