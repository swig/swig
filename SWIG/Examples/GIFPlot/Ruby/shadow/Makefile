TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Interface
SRCS       =
TARGET     = gifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot
INCLUDE    = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ruby

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='myruby' INTERFACE='$(INTERFACE)' ruby_static

clean::
	rm -f *_wrap* *.o *~ *.so myruby .~* core *.gif

check: all
