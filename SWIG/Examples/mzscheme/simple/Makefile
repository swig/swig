TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
INCLUDE    = -I.
SWIGOPT    = 
all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' mzscheme
clean::
	rm -f *_wrap* *.o core *~ *.so

check: all
