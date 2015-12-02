CONTINUE ?=

all:
	# lualatex  lonely_advent_calender.tex -halt-on-error && lualatex lonely_advent_calender.tex -halt-on-errox
	latexmk -lualatex -synctex=1 -interaction=nonstopmode $(CONTINUE) lonely_advent_calender
continue:
	CONTINUE=-pvc make all
clean:
	latexmk -c
