# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory

ifneq (, $(ENGINE))
	JSENGINE=$(ENGINE)
else
	JSENGINE=node
endif

EXAMPLES_TOP=../..
SWIG_TOP=../../..
SWIG = $(SWIG_TOP)/preinst-swig
TARGET = example
INTERFACE = example.i
SWIGOPT=-$(JSENGINE)

check: build
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile JSENGINE='$(JSENGINE)' TARGET='$(TARGET)' javascript_run

build:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile CXXSRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_wrapper_cpp
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile CXXSRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' JSENGINE='$(JSENGINE)' javascript_build_cpp

clean:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile javascript_clean
