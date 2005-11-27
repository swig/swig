TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = 
TARGET     = example
INTERFACE  = example.i
PROGFILE   = runme.ml

all default:: static top

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	PROGFILE='$(PROGFILE)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	ocaml_static_cpp

dynamic::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	PROGFILE='$(PROGFILE)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	ocaml_static_cpp

top::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	PROGFILE='$(PROGFILE)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	ocaml_static_cpp_toplevel

clean::
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' ocaml_clean

check: all
