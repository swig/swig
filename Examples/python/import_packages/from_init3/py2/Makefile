TOP        = ../../../..
SWIG       = $(realpath $(TOP)/../preinst-swig)
SWIGOPT    =
LIBS       =

build:
	cd pkg2 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build

static:
	cd pkg2 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile python_clean
	cd pkg2 && $(MAKE) clean
