TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Interface -shadow
SRCS       =
TARGET     = libgifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot
INCLUDE    = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java
	javac *.java

clean::
	mv runme.java runme.java.tmp
	rm -f *_wrap* *.o core *~ *.so *.class *.java *.gif
	mv runme.java.tmp runme.java

check: all
