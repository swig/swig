TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' r

clean::
	$(MAKE) -f $(TOP)/Makefile INTERFACE='$(INTERFACE)' r_clean

check: all
	R CMD BATCH runme.R
