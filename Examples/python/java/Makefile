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
	CXXSHARED="gcj -fPIC -shared Example.class" DEFS='' python_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f $(TARGET).py
	rm -f *.class Example.h

check: all


Example.class: Example.java
	gcj -v || exit 0
	gcj -fPIC -C -c -g Example.java
	gcjh  Example

