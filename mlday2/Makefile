CONTINUE ?=
TARGET = main
LATEXMKFLAG =-lualatex -synctex=1 -interaction=nonstopmode $(CONTINUE)

all:
	latexmk $(LATEXMKFLAG) $(TARGET)
continue:
	make CONTINUE=-pvc
clean:
	latexmk -C
	-rm $(TARGET).ltjruby
	-rm $(TARGET).nav
	-rm $(TARGET).snm
	-rm $(TARGET).vrb

