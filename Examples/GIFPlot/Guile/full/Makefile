TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Include
SRCS       =
TARGET     = gifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDE    = -I../../Include

all:: static

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='gifguile' INTERFACE='$(INTERFACE)' guile_static

clean::
	rm -f *_wrap* *.o *~ *.so gifguile .~* core *.gif

check: all
