CONTINUE ?=
TARGET = main

all:
	latexmk -lualatex -synctex=1 -interaction=nonstopmode $(CONTINUE) $(TARGET)
continue:
	CONTINUE=-pvc make all
clean:
	latexmk -C
	-rm $(TARGET).ltjruby
	-rm $(TARGET).nav
	-rm $(TARGET).snm
	-rm $(TARGET).vrb

