TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
ARGS = SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)'

all::
	$(MAKE) -f $(TOP)/Makefile $(ARGS) r

clean::
	$(MAKE) -f $(TOP)/Makefile $(ARGS) r_clean

check: all
	R CMD BATCH runme.R
