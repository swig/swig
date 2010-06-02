SRCS   = matrix.c vector.c
TARGET = matrix
IFILE  = package.i
MKDIR  = ..


all::
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		MODULE=$(MODULE)		\
	  sub-all

clean::
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean

check: all
