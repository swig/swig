#
# Common Makefile code for building D examples.
#
# This file is supposed to be included from a Makefile in the subdirectory
# corresponding to a specific example.
#

EXAMPLES_TOP   = ../../..
SWIG_TOP       = ../../../..
SWIGEXE        = $(SWIG_TOP)/swig
SWIG_LIB_DIR   = $(SWIG_TOP)/$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
EXTRA_CPPFLAGS =
EXTRA_CFLAGS   =
EXTRA_CXXFLAGS =
EXTRA_LDFLAGS  =
TARGET         = example_wrap
SWIGOPT        = -outcurrentdir
DFLAGS         = -ofrunme

ifeq (,$(SRCDIR))
DSRCS          = *.d
else
DSRCS          = *.d $(addprefix ../$(SRCDIR)d2/,runme.d)
endif


check: build
	$(MAKE) -C d2/ -f $(EXAMPLES_TOP)/Makefile SRCDIR='../$(SRCDIR)' d_run

build:
	mkdir -p d2/
	if [ -f $(SRCDIR)example.cxx ]; then \
		$(MAKE) -C d2/ -f $(EXAMPLES_TOP)/Makefile SRCDIR='../$(SRCDIR)' EXTRA_CPPFLAGS='$(EXTRA_CPPFLAGS)' EXTRA_CXXFLAGS='$(EXTRA_CXXFLAGS)' EXTRA_LDFLAGS='$(EXTRA_LDFLAGS)' \
		SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
		SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='example.i' CXXSRCS='example.cxx' d_cpp; \
	elif [ -f $(SRCDIR)example.c ]; then \
		$(MAKE) -C d2/ -f $(EXAMPLES_TOP)/Makefile SRCDIR='../$(SRCDIR)' EXTRA_CPPFLAGS='$(EXTRA_CPPFLAGS)' EXTRA_CFLAGS='$(EXTRA_CFLAGS)' EXTRA_LDFLAGS='$(EXTRA_LDFLAGS)' \
		SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
		SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='example.i' SRCS='example.c' d; \
	else \
		$(MAKE) -C d2/ -f $(EXAMPLES_TOP)/Makefile SRCDIR='../$(SRCDIR)' EXTRA_CPPFLAGS='$(EXTRA_CPPFLAGS)' EXTRA_CFLAGS='$(EXTRA_CFLAGS)' EXTRA_LDFLAGS='$(EXTRA_LDFLAGS)' \
		SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
		SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='example.i' SRCS='' d; \
	fi
	$(MAKE) -C d2/ -f $(EXAMPLES_TOP)/Makefile SRCDIR='../$(SRCDIR)' DSRCS='$(DSRCS)' DFLAGS='$(DFLAGS)' d_compile

clean:
	if [ -d d2/ ]; then \
		$(MAKE) -C d2/ -f $(EXAMPLES_TOP)/Makefile SRCDIR='../$(SRCDIR)' d_clean; \
	fi
	test -f d2/runme.d || rm -rf d2/ # Only delete dir if out of source
