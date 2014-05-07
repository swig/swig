TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    =
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

check: build
	$(MAKE) -f $(TOP)/Makefile python_run

build: Example.class Example.h
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	CXXSHARED="gcj -fpic -shared Example.class" DEFS='' LIBS="-lstdc++" python_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f $(TARGET).py
	rm -f *.class Example.h

Example.class Example.h: Example.java
	gcj -fPIC -C -c -g Example.java
	gcjh Example.class
