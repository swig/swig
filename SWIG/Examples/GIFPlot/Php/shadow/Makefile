TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Interface -shadow
SRCS       =
TARGET     = libgifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDE    = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4

clean::
	rm -f *_wrap* *.o *~ *.so .~* core *.gif *.php *.h

check: all
