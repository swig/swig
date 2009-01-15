TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -outcurrentdir
SRCS       =
TARGET     = gifplot
INTERFACEDIR = ../../Interface/
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot
INCLUDES   = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' ruby

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='myruby' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' ruby_static

clean::
	$(MAKE) -f $(TOP)/Makefile ruby_clean
	rm -f *.gif

check: all
