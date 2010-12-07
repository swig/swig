TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
MLFILE     = example.ml
PROGFILE   = example_prog.ml
OBJS       = example.o

all:: static 

dynamic::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MLFILE='$(MLFILE)' \
	PROGFILE='$(PROGFILE)' OBJS='$(OBJS)' \
	ocaml_dynamic

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MLFILE='$(MLFILE)' \
	PROGFILE='$(PROGFILE)' OBJS='$(OBJS)' \
	ocaml_static

toplevel::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MLFILE='$(MLFILE)' \
	PROGFILE='$(PROGFILE)' OBJS='$(OBJS)' \
	ocaml_static_toplevel

clean::
	$(MAKE) -f $(TOP)/Makefile MLFILE='$(MLFILE)' ocaml_clean

check: all
