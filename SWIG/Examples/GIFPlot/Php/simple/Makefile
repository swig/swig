TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    =
SRCS       =
TARGET     = libsimple
INTERFACE  = simple.i
LIBS       = -L../.. -lgifplot
INCLUDE    = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4

clean::
	rm -f *_wrap* *.o *~ *.so *.h *.php .~* core *.gif

check: all
