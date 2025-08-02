TOP        = ../../..
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_run

build:
	$(MAKE) -C pkg1 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build
	$(MAKE) -C pkg2 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build

static:
	$(MAKE) -C pkg1 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static
	$(MAKE) -C pkg2 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	$(MAKE) -C pkg1 clean
	$(MAKE) -C pkg2 clean
