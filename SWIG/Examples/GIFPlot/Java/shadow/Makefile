TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Interface -shadow
SRCS       =
TARGET     = gifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot
INCLUDE    = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java
	javac *.java

clean::
	$(MAKE) -f $(TOP)/Makefile java_clean
	rm -f *.gif

check: all
