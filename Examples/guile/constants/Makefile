SRCS   = 
TARGET = my-guile
IFILE  = example.i
MKDIR  = ..

all::
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
	    sub-all

clean::
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean

check: all
	./my-guile -s constants.scm
