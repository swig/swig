TOP        = ../../..
SWIG       = $(TOP)/../preinst-swig
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
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' python

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='mypython' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' python_static

clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f $(TARGET).py
	rm -f *.gif

check: all
	$(MAKE) -f $(TOP)/Makefile python_run
