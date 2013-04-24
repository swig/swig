SRCS   = 
TARGET = my-guile
IFILE  = example.i
MKDIR  = ..

check: build
	./my-guile -s constants.scm

build:
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
	    sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
