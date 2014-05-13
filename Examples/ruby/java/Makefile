TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    =
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' ruby_run

build: Example.class Example.h
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	CXXSHARED="gcj -fpic -shared Example.class" LIBS="-lstdc++" DEFS='' ruby_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' ruby_clean
	rm -f *.class Example.h

Example.class Example.h: $(SRCDIR)Example.java
	gcj -d . -fPIC -C -c -g $(SRCDIR)Example.java
	gcjh Example.class
