TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = 
TARGET     = libexample
INTERFACE  = example.i
SWIGOPT    = 

all::	java

java::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java

clean::
	rm -f *_wrap* *.o core *~ *.so *.class example.java

