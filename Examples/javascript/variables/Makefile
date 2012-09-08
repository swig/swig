TOP = ../..
SWIG = $(TOP)/../preinst-swig
JAVASCRIPT_EXE = $(TOP)/../Tools/javascript/javascript
CXXSRCS    = example.cpp
JSCXXSRCS = $(TOP)/../Tools/javascript/javascript.cxx
JS_SCRIPT = runme.js
TARGET = example
INTERFACE = example.i
SWIGOPT = -I$(TOP)/../Lib/javascript -I$(TOP)/../Lib/javascript/jsc

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile javascript_clean

check:: all
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		JAVASCRIPT_EXE='$(JAVASCRIPT_EXE)' javascript_exe
	$(MAKE) -f $(TOP)/Makefile JSCXXSRCS='$(JSCXXSRCS)' TARGET='$(TARGET)' \
		JAVASCRIPT_EXE='$(JAVASCRIPT_EXE)' JS_SCRIPT='$(JS_SCRIPT)' javascript_run

