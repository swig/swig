TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = example
INTERFACE  = example.i
MLFILE     = example.ml
PROGFILE   = example_prog.ml
OBJS       =

check: build
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' ocaml_run

build: static

dynamic:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MLFILE='$(MLFILE)' \
	PROGFILE='$(PROGFILE)' OBJS='$(OBJS)' \
	ocaml_dynamic_cpp

static:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MLFILE='$(MLFILE)' \
	PROGFILE='$(PROGFILE)' OBJS='$(OBJS)' \
	ocaml_static_cpp

toplevel:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MLFILE='$(MLFILE)' \
	PROGFILE='$(PROGFILE)' OBJS='$(OBJS)' \
	ocaml_static_cpp_toplevel

clean:
	$(MAKE) -f $(TOP)/Makefile MLFILE='$(MLFILE)' ocaml_clean
