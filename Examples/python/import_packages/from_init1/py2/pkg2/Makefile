TOP        = ../../../../..
SWIG       = $(realpath $(TOP)/../preinst-swig)
SWIGOPT    =
LIBS       =

build:
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' python_cpp

static:
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' python_cpp_static
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' python_cpp_static

clean::
	$(MAKE) -f $(TOP)/Makefile TARGET='foo' python_clean
	$(MAKE) -f $(TOP)/Makefile TARGET='bar' python_clean
