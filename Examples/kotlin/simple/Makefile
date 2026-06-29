TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
KOTLINSRCS = *.kt
RUNME      = RunmeKt

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' RUNME='$(RUNME)' kotlin_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' kotlin
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' KOTLINSRCS='$(KOTLINSRCS)' KOTLINFLAGS='$(KOTLINFLAGS)' kotlin_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' kotlin_clean
