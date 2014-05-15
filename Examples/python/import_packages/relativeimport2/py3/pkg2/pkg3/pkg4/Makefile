TOP        = ../../../../../../..
SWIG       = $(realpath $(TOP)/../preinst-swig)
SWIGOPT    =
LIBS       =

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' python_cpp

static:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' python_cpp_static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='foo' python_clean
