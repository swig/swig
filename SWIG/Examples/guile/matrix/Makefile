CC     = gcc
SRCS   = matrix.c vector.c
TARGET = matrix
IFILE  = package.i
MKDIR  = ..


all::
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		CC=$(CC)			\
		MODULE=$(MODULE)		\
	  sub-all

clean::
	rm -f matrix *_wrap* *~ .~* core

check: all
