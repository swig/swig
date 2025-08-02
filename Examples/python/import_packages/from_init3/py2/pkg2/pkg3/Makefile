TOP        = ../../../../../..
SWIGOPT    =
LIBS       =

build:
	$(MAKE) -C pkg4 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build

static:
	$(MAKE) -C pkg4 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	$(MAKE) -C pkg4 clean
