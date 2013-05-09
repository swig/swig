SRCS   = matrix.c vector.c
TARGET = matrix
IFILE  = example.i
MKDIR  = ..
TOP        = ../..

check: build
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' GUILE_RUNOPTIONS='-e do-test' guile_embedded_run

build:
	$(MAKE) -f $(MKDIR)/Makefile		\
		SRCS='$(SRCS)'			\
		TARGET=$(TARGET)		\
		IFILE=$(IFILE)			\
		MODULE=$(MODULE)		\
		LIBS="-lm"			\
	  sub-all

clean:
	$(MAKE) -f $(MKDIR)/Makefile TARGET='$(TARGET)' guile_clean
