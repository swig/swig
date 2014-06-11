TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SWIGOPT    =
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' ruby_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='base' INTERFACE='base.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' ruby_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' ruby_clean
