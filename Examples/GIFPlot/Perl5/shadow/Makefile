TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -outcurrentdir
SRCS       =
TARGET     = gifplot
INTERFACEDIR = ../../Interface/
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDES   = -I../../Include

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' perl5

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='myperl' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' perl5_static

clean::
	$(MAKE) -f $(TOP)/Makefile perl5_clean
	rm -f *.gif

check: all
