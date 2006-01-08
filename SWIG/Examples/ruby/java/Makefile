CXX        = gcj 
TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = 
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

all:: Example.class
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' CXX="gcj" CFLAGS="-fPIC" \
	CXXSHARED="gcj -fPIC -shared Example.class" DEFS='' ruby_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f *.class Example.h

check: all

run:
	ruby runme.rb

Example.class: Example.java
	gcj -fPIC -C -c -g Example.java
	gcjh  Example

