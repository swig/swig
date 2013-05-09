SRCS   = example.c
TARGET = port
IFILE  = example.i
MKDIR  = ..

check: build
	./$(TARGET) -s runme.scm

build:
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		MODULE=$(MODULE)		\
	  sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
	rm -f test.out
