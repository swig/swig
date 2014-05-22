TOP        = ../../../../../..
SWIG       = $(realpath $(TOP)/../preinst-swig)
SWIGOPT    =
LIBS       =

build:
	cd pkg4 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build

static:
	cd pkg4 && $(MAKE) SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	cd pkg4 && $(MAKE) clean
