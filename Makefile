CONTINUE ?=

all:
	latexmk -lualatex -synctex=1 -interaction=nonstopmode $(CONTINUE) main.tex
continue:
	CONTINUE=-pvc make all
clean:
	latexmk -c
