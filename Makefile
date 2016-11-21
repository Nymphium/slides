# CONTINUE ?=
TARGET = main
LATEXMKFLAG =-pdf -synctex=1 -interaction=nonstopmode

all:
	latexmk $(LATEXMKFLAG) $(TARGET)
continue:
	CONTINUE+= -pvc make all
clean:
	latexmk -C
	-rm $(TARGET).ltjruby
	-rm $(TARGET).nav
	-rm $(TARGET).snm
	-rm $(TARGET).vrb

