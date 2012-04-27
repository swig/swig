TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
OCTSCRIPTS = \
	runme_args.m \
	runme_gl_func.m \
	runme_gl_func_base.m \
	runme_nogl_func.m \
	runme_nogl_func_base.m

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' octave

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='myoctave' INTERFACE='$(INTERFACE)' octave_static

clean::
	$(MAKE) -f $(TOP)/Makefile octave_clean
	rm -f $(TARGET).m

check: all
	$(MAKE) -f $(TOP)/Makefile OCTSCRIPT="$(OCTSCRIPTS)" octave_run
