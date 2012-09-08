TOP = ../..
SWIG = $(TOP)/../preinst-swig
CXXSRCS    =
JS_SCRIPT = runme.js
TARGET = example
INTERFACE = example.i

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript

clean::
	$(MAKE) -f $(TOP)/Makefile javascript_clean

javascript_exe::
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		TOP='$(TOP)' javascript_exe

check:: all
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		TOP='$(TOP)' JS_SCRIPT='$(JS_SCRIPT)' javascript_run
