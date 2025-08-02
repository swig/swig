TOP        = ../../../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
SWIGOPT    =
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_run

build:
	$(MAKE) -C pkg1 build

static:
	$(MAKE) -C pkg1 static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='foo' python_clean
	$(MAKE) -C pkg1 -f $(TOP)/../Makefile SRCDIR='$(SRCDIR)' TARGET='foo' python_clean
