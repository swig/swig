TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = libexample
INTERFACE  = example.i
SWIGOPT    = -shadow

all::	java

java::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java
	javac *.java

clean::
	rm -f *_wrap* *.o core *~ *.so *.class example.java

check: all
