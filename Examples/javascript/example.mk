# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory

EXAMPLES_TOP   = ../..
SWIG_TOP       = ../../..
SWIGEXE        = $(SWIG_TOP)/swig
SWIG_LIB_DIR   = $(SWIG_TOP)/$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET         = example
INTERFACE      = example.i
SWIGOPT        =

# Examples are always in sync by default mode
ifneq (,$(findstring async,$(SWIG_FEATURES)))
$(info Ignoring -async in SWIG_FEATURES, examples are always sync by default)
SWIGOPT += -sync
endif

# Examples are always built w/o code splitting
ifneq (,$(findstring split,$(SWIG_FEATURES)))
$(info Ignoring -split in SWIG_FEATURES, examples are always built w/o code splitting)
endif


check: build
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' javascript_run

build:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SRCS='$(SRCS)' SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIG_FEATURES='$(filter-out -split,$(SWIG_FEATURES))' \
	SWIGOPT='$(filter-out -split,$(SWIGOPT))' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_wrapper$(_CPP)
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SRCS='$(SRCS)' SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIG_FEATURES='$(filter-out -split,$(SWIG_FEATURES))' \
	SWIGOPT='$(filter-out -split,$(SWIGOPT))' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_build$(_CPP)

clean:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' javascript_clean
