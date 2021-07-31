# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory

TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET     = swigexample
INTERFACE  = example.i
INCLUDES   = -I$(SRCDIR)

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' matlab_run

build:
ifneq (,$(SRCS))
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' INCLUDES='$(INCLUDES)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' matlab
else
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' INCLUDES='$(INCLUDES)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' matlab_cpp
endif
ifneq (,$(TARGET2)$(SWIGOPT2))
ifneq (,$(SRCS))
	$(MAKE) -f $(TOP)/Makefile PCHSUPPORT=no SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' INCLUDES='$(INCLUDES)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT2)' TARGET='$(TARGET2)' INTERFACE='$(INTERFACE)' matlab
else
	$(MAKE) -f $(TOP)/Makefile PCHSUPPORT=no SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' INCLUDES='$(INCLUDES)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT2)' TARGET='$(TARGET2)' INTERFACE='$(INTERFACE)' matlab_cpp
endif
endif


clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' matlab_clean
