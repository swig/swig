TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Include
SRCS       =
TARGET     = gifplot
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDES   = -I../../Include

all:: static

dynamic:: 
	$(MAKE) -f $(TOP)/Makefile TOP='$(TOP)' \
	SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' guile

static::
	$(MAKE) -f $(TOP)/Makefile TOP='$(TOP)' \
	SRCS='$(SRCS)' SWIG='$(SWIG)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' guile_static

clean::
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' guile_clean
	rm -f *.gif

check: all
