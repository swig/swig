CC     = gcc
SRCS   = example.c
TARGET = my-guile
IFILE  = example.i
MKDIR  = ..

all::
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		CC=$(CC)			\
	    sub-all

clean::
	rm -f *_wrap* my-guile *~ .~* core


