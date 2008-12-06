TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Include -noproxy
SRCS       =
TARGET     = php_gifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDES   = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php

clean::
	$(MAKE) -f $(TOP)/Makefile php_clean
	rm -f *.gif
	rm -f php_gifplot.h

check: all
