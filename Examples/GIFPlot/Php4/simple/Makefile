TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -noproxy
SRCS       =
TARGET     = php_simple
INTERFACE  = simple.i
LIBS       = -L../.. -lgifplot
INCLUDES   = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4

clean::
	$(MAKE) -f $(TOP)/Makefile php4_clean
	rm -f *.gif
	rm -f php_simple.h

check: all
