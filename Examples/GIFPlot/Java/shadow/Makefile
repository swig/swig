TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -outcurrentdir
SRCS       =
TARGET     = gifplot
INTERFACEDIR = ../../Interface/
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot
INCLUDES   = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' java
	javac *.java

clean::
	$(MAKE) -f $(TOP)/Makefile java_clean
	rm -f *.gif

check: all
