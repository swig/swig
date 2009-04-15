TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SWIGOPT    = -I../Include
SRCS       =
TARGET     = gifplot
INTERFACE  = gifplot.i
LIBS       = -L.. -lgifplot
INCLUDES   = -I../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)'  LIBS='$(LIBS)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' c

clean:
	rm -f *.o *.out *.so *.a *.dll  *.dylib *.exe *_wrap* *_proxy* *~ runme

check: all
