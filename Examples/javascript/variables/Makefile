TOP = ../..
SWIG = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
JS_SCRIPT = runme.js
TARGET = example
INTERFACE = example.i

wrapper::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_wrapper_cpp

build:: wrapper
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_build

clean::
	$(MAKE) -f $(TOP)/Makefile javascript_clean

check:: build
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		TOP='$(TOP)' JS_SCRIPT='$(JS_SCRIPT)' javascript_run
