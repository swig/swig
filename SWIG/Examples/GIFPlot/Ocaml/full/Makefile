TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Include
SRCS       = 
TARGET     = gifcaml
INTERFACE  = gifplot.i
LIBS       = -L../.. -lgifplot -lm
INCLUDE    = -I../../Include
MLFILE     = gifplot.ml
IOBJS      = gifplot_wrap.o gifplot.cmo runme.cmo
PROGFILE   = runme.ml

all:: static

static::
	$(MAKE) -f $(TOP)/Makefile TOP='$(TOP)' \
	IOBJS='$(IOBJS)' PROGFILE='$(PROGFILE)' \
	SRCS='$(SRCS)' SWIG='$(SWIG)' MLFILE='$(MLFILE)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ocaml_static

clean::
	rm -f *_wrap* *.o *~ *.so *.cmo *.cmi gifcaml .~* core *.gif \
		gifplot.ml*

check: all
