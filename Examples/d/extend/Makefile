ifeq (2,$(D_VERSION))
  WORKING_DIR = d2/
else
  WORKING_DIR = d1/
endif

TOP           = ../../..
SWIG          = $(TOP)/../preinst-swig
EXTRA_CFLAGS  = -I../ ../example.cxx example_wrap.cxx
EXTRA_LDFLAGS = example.o example_wrap.o
TARGET        = example_wrap
SWIGOPT       =
DSRCS         = *.d
DFLAGS        = -ofrunme


all::	d

d::
	cd $(WORKING_DIR); \
	$(MAKE) -f $(TOP)/Makefile EXTRA_CFLAGS='$(EXTRA_CFLAGS)' EXTRA_LDFLAGS='$(EXTRA_LDFLAGS)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT) -outcurrentdir ../example.i' TARGET='$(TARGET)' d_cpp; \
	$(MAKE) -f $(TOP)/Makefile DSRCS='$(DSRCS)' DFLAGS='$(DFLAGS)' d_compile

clean::
	cd $(WORKING_DIR); \
	$(MAKE) -f $(TOP)/Makefile d_clean

check: all
	cd $(WORKING_DIR); \
	$(MAKE) -f $(TOP)/Makefile d_run
