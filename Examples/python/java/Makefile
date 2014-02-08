TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = 
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

check: build

build: Example.class
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' CXX="gcj"  \
	CXXSHARED="gcj -fpic -shared Example.class" DEFS='' LIBS="-lstdc++" python_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f $(TARGET).py
	rm -f *.class Example.h

Example.class: Example.java
	gcj -fPIC -C -c -g Example.java
	gcjh  Example

