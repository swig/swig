TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Interface
SRCS       =
TARGET     = gifplot
INTERFACE  = mandel.i
LIBS       = -L../.. -lgifplot
INCLUDES   = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tcl

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='mywish' INTERFACE='$(INTERFACE)' wish

clean::
	$(MAKE) -f $(TOP)/Makefile tcl_clean
	rm -f *.gif

check: all
