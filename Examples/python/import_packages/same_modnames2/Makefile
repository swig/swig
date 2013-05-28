TOP        = ../../..
SWIG       = $(realpath $(TOP)/../preinst-swig)
SWIGOPT    =
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile python_run

build:
	cd pkg1 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build
	cd pkg1/pkg2 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build

static:
	cd pkg1 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static
	cd pkg1/pkg2 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile python_clean
	cd pkg1 && $(MAKE) clean
	cd pkg1/pkg2 && $(MAKE) clean
