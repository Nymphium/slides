CONTINUE ?=
TARGET = main
MYLATEXFMTCACHE = cache
LATEXMKFLAG =-pdflatex='lualatex \&'$(MYLATEXFMTCACHE) -pdf -synctex=1 -interaction=nonstopmode $(CONTINUE)

$(MYLATEXFMTCACHE).fmt:
	lualatex -ini -jobname=$(MYLATEXFMTCACHE) \&lualatex mylatexformat.ltx main.tex

all: $(MYLATEXFMTCACHE).fmt
	latexmk $(LATEXMKFLAG) $(TARGET)
continue:
	make CONTINUE=-pvc
clean:
	latexmk -C
	-rm $(TARGET).ltjruby
	-rm $(TARGET).nav
	-rm $(TARGET).snm
	-rm $(TARGET).vrb

