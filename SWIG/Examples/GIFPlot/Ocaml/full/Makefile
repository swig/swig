TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Include
SRCS       = 
TARGET     = gifcaml
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDES   = -I../../Include
MLFILE     = gifplot.ml
IOBJS      = runme.cmo
PROGFILE   = runme.ml

all:: static

static::
	$(MAKE) -f $(TOP)/Makefile TOP='$(TOP)' \
	IOBJS='$(IOBJS)' PROGFILE='$(PROGFILE)' \
	SRCS='$(SRCS)' SWIG='$(SWIG)' MLFILE='$(MLFILE)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ocaml_static

dynamic::
	$(MAKE) -f $(TOP)/Makefile TOP='$(TOP)' \
	IOBJS='$(IOBJS)' PROGFILE='$(PROGFILE)' \
	SRCS='$(SRCS)' SWIG='$(SWIG)' MLFILE='$(MLFILE)' \
	INCLUDES='$(INCLUDES)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ocaml_dynamic

clean::
	$(MAKE) -f $(TOP)/Makefile MLFILE='$(MLFILE)' ocaml_clean
	rm -f *.gif

check: all
