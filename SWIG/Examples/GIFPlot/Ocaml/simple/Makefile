TOP        = ../../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -I../../Include
SRCS       = 
TARGET     = gifsimple
INTERFACE  = simple.i
LIBS       = -L../.. -lgifplot -lm
INCLUDE    = -I../../Include
MLFILE     = simple.ml
IOBJS      = simple_wrap.o simple.cmo runme.cmo
PROGFILE   = runme.ml

all:: static

static::
	$(MAKE) -f $(TOP)/Makefile TOP='$(TOP)' \
	IOBJS='$(IOBJS)' PROGFILE='$(PROGFILE)' \
	SRCS='$(SRCS)' SWIG='$(SWIG)' MLFILE='$(MLFILE)' \
	INCLUDE='$(INCLUDE)' LIBS='$(LIBS)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ocaml_static

clean::
	rm -f *_wrap* *.o *~ *.so *.cmo *.cmi gifsimple .~* core *.gif \
		simple.ml*

check: all
