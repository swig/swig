TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = php_example
INTERFACE  = example.i
SWIGOPT    = -noproxy

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4

clean::
	rm -f *_wrap* *.o core *~ *.so *.php php_example.h

check: all
