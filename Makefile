CONTINUE ?=
TARGET = main
LATEXMKFLAG =-pdf -synctex=1 -interaction=nonstopmode $(CONTINUE)

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

