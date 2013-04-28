TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
JAVASRCS   = *.java

check: build
	$(MAKE) -f $(TOP)/Makefile java_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java
	$(MAKE) -f $(TOP)/Makefile JAVASRCS='$(JAVASRCS)' JAVAFLAGS='$(JAVAFLAGS)' java_compile

clean:
	$(MAKE) -f $(TOP)/Makefile java_clean
