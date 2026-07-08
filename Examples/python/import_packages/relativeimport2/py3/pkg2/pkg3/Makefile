TOP        = ../../../../../..
SWIGOPT    =
LIBS       =

build:
	$(MAKE) -C pkg4 SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' build

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	$(MAKE) -C pkg4 clean
