TOP        = ../..
SWIG       = $(TOP)/../swig -shadow
SWIGOPT    = -I../Include
SRCS       =
TARGET     = libjgifplot
INTERFACE  = gifplot.i
LIBS       = -L.. -lgifplot -lm
INCLUDE    = -I../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java

clean::
	rm -f *_wrap* *.o *~ *.so .~* core *.gif *.class ColorMap.java FrameBuffer.java Plot2D.java Plot3D.java gifplot.java

check: all
