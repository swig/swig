TOP        = ../../..
LIBS       =

PKG1DIR  = "py3"

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_run

build:
	$(MAKE) -C $(PKG1DIR) SWIGOPT='$(SWIGOPT) -relativeimport' LIBS='$(LIBS)' build

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	$(MAKE) -C py3 clean
