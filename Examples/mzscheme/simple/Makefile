TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    = 
all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' mzscheme
clean::
	rm -f *_wrap* *.o core *~ *.so

check: all
