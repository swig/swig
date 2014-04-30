TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SWIGOPT    =
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile lua_run

build:
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='base' INTERFACE='base.i' lua_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' lua_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' lua_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' lua_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile lua_clean
