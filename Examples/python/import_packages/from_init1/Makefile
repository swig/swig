TOP        = ../../..
LIBS       =

PKG1DIR  = "py3"

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_run

build:
	cd $(PKG1DIR) && $(MAKE) SWIGOPT='$(SWIGOPT) -relativeimport' LIBS='$(LIBS)' build

static:
	cd $(PKG1DIR) && $(MAKE) SWIGOPT='$(SWIGOPT) -relativeimport' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	cd py3 && $(MAKE) clean
