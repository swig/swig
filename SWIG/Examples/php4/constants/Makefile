TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       =
TARGET     = libexample
INTERFACE  = example.i
SWIGOPT    =
all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4

clean::
	rm -f *_wrap* *.o core *~ *.so *.php *.h

check: all
