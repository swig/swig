TOP          = ../..
SWIGEXE      = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
SRCS         = example.c
TARGET       = example
INTERFACE    = example.i
KOTLINSRCS   = example_test.kt
KOTLINTARGET = example_test

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' \
	KOTLINTARGET='$(KOTLINTARGET)' kotlinnative_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' kotlinnative

	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' kotlinnative_cinterop

	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' \
	KOTLINSRCS='$(KOTLINSRCS)' KOTLINTARGET='$(KOTLINTARGET)' kotlinnative_build

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' kotlinnative_clean
