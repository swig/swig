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
	javac *.java

clean::
	rm -f *_wrap* example.java *.class *.o *~ .~* core *.so *.sl so_locations

check: all
