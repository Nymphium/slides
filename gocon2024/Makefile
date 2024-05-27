CONTINUE ?=
TARGET = main

all:
	-latexmk $(CONTINUE) $(TARGET)

continue:
	make CONTINUE=-pvc

clean:
	latexmk -C
	-rm $(TARGET).ltjruby
	-rm $(TARGET).nav
	-rm $(TARGET).snm
	-rm $(TARGET).vrb
