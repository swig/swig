# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory

ifneq (, $(V8_VERSION))
	JSV8_VERSION=$(V8_VERSION)
else
	JSV8_VERSION=0x031110
endif

EXAMPLES_TOP   = ../..
SWIG_TOP       = ../../..
SWIGEXE        = $(SWIG_TOP)/swig
SWIG_LIB_DIR   = $(SWIG_TOP)/$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET         = example
INTERFACE      = example.i
SWIGOPT        =

ifneq (jsc, $(ENGINE))
SWIGOPT += -DV8_VERSION=$(JSV8_VERSION)
endif

check: build
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' javascript_run

build:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SRCS='$(SRCS)' SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_wrapper$(_CPP)
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SRCS='$(SRCS)' SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_build$(_CPP)

clean:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' javascript_clean
