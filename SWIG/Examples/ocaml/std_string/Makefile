TOP        = ../..
SWIG       = $(TOP)/../swig -I/usr/include/g++-3
SRCS       = 
TARGET     = example
INTERFACE  = example.i
PROGFILE   = runme.ml

default:: static

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ocaml_cpp

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	PROGFILE='$(PROGFILE)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	ocaml_static_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' ocaml_clean

check: all
