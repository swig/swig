TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.cxx
TARGET     = php_example
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = -noproxy

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' SWIGOPT='$(SWIGOPT)' \
	php4_cpp

clean::
	rm -f *_wrap* *.o *~ *.so  .~* core *.php php_example.h

check: all
