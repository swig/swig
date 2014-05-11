ifeq (2,$(D_VERSION))
  WORKING_DIR = d2/
else
  WORKING_DIR = d1/
endif

TOP           = ../../..
SWIG          = $(TOP)/../preinst-swig
EXTRA_CFLAGS  = -I../ ../example.c example_wrap.c
EXTRA_LDFLAGS = example.o example_wrap.o
TARGET        = example_wrap
SWIGOPT       =
DSRCS         = *.d
DFLAGS        = -ofrunme

check: build
	cd $(WORKING_DIR); \
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' d_run

build:
	cd $(WORKING_DIR); \
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' EXTRA_CFLAGS='$(EXTRA_CFLAGS)' EXTRA_LDFLAGS='$(EXTRA_LDFLAGS)' EXTRA_LDFLAGS='$(EXTRA_LDFLAGS)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT) -outcurrentdir ../example.i' TARGET='$(TARGET)' d; \
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' DSRCS='$(DSRCS)' DFLAGS='$(DFLAGS)' d_compile

clean:
	cd $(WORKING_DIR); \
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' d_clean
