TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    =
SRCS       = 
TARGET     = libexample
INTERFACE  = example.i

all::	java

java::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java

clean::
	rm -f *_wrap* example.java *.class *.o *~ .~* core *.so *.sl so_locations

check: all
