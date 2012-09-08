TOP = ../..
SWIG = $(TOP)/../preinst-swig
SRCS = example.c
JSCXXSRCS = $(TOP)/../Tools/javascript/javascript.cxx
JAVASCRIPT_EXE = $(TOP)/../Tools/javascript/javascript
JAVASCRIPT_MODULE = example
JS_SCRIPT = runme.js
TARGET = example
INTERFACE = example.i
SWIGOPT = -I$(TOP)/../Lib/javascript -I$(TOP)/../Lib/javascript/jsc

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript

clean::
	$(MAKE) -f $(TOP)/Makefile javascript_clean

check:: all
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		JAVASCRIPT_EXE='$(JAVASCRIPT_EXE)' javascript_exe
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		JAVASCRIPT_EXE='$(JAVASCRIPT_EXE)' JAVASCRIPT_MODULE='$(JAVASCRIPT_MODULE)' JS_SCRIPT='$(JS_SCRIPT)' javascript_run

