# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory
EXAMPLES_TOP=../..
SWIG_TOP=../../..

SWIG = $(SWIG_TOP)/preinst-swig

# TODO: we could only set these only if not yet set...
JS_SCRIPT = runme.js
TARGET = example
INTERFACE = example.i

ifneq (, $(ENGINE))
	JSENGINE=$(ENGINE)
else
	JSENGINE=node
endif

SWIGOPT=-$(JSENGINE)

ifeq (node,$(JSENGINE))

build: wrapper
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile CXXSRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' JSENGINE='$(JSENGINE)' javascript_build_node

else

build: wrapper
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile CXXSRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' JSENGINE='$(JSENGINE)' javascript_build_cpp

endif

wrapper:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile CXXSRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_wrapper_cpp

ifeq (node,$(JSENGINE))

check: build
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile JSENGINE='$(JSENGINE)' javascript_run_node

else

check: build
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile JSENGINE='$(JSENGINE)' TARGET='$(TARGET)' javascript_run

endif

clean:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile javascript_clean
